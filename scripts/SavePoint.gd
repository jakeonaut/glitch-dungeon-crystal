extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var myOtherSprite = get_node("Sprite3D2")
onready var saveSound = get_node("SaveSound")

var MIN_STEP = 1
var MAX_STEP = -4
var step = MIN_STEP
var id = null
var is_active = false

var spawn_timer = 0
var spawn_time_limit = 5

func _ready():
    add_to_group("savepoints")
    id = self.generateId()

    set_process(true)

func _process(delta):
    if isOnSavePoint():
        if not is_active:
            myOtherSprite.max_frames = 0
            myOtherSprite.updateBaseFrame(0, 0)
            var my_material = myOtherSprite.get_material_override()
            if my_material is ShaderMaterial:
                var new_material = my_material.duplicate()
                new_material.set_shader_param("enable_palette_cycle", true)
                myOtherSprite.set_material_override(new_material)
            spawn_timer = spawn_time_limit
        is_active = true
    else:
        if is_active:
            myOtherSprite.max_frames = 2
            myOtherSprite.updateBaseFrame(0, 0)
            var my_material = myOtherSprite.get_material_override()
            if my_material is ShaderMaterial:
                var new_material = my_material.duplicate()
                new_material.set_shader_param("enable_palette_cycle", false)
                myOtherSprite.set_material_override(new_material)
        is_active = false

    if is_active:
        spawn_timer += (delta*22)
        if spawn_timer >= spawn_time_limit:
            var children = self.get_children()
            var num_children = 0
            for i in children:
                num_children += 1

            if num_children < 20:
                var newSprite = mySprite.duplicate()
                newSprite.should_fizzle_out = true
                newSprite.visible = true
                newSprite.transform.origin = Vector3(
                    stepify(rand_range(-1.0, 1.0), 0.12),
                    stepify(rand_range(0.5, 1.5), 0.12),
                    0
                )
                newSprite.updateBaseFrame(0, 0)
                newSprite.max_frames = 2
                add_child(newSprite)
                spawn_timer = 0

func isOnSavePoint():
    if not global.memory.has("active_save_point_x"):
        return false

    var origin = self.global_transform.origin
    var x = origin.x
    var y = origin.y
    var z = origin.z
    return int(round(x)) == int(round(global.memory["active_save_point_x"])) and \
            int(round(y)) == int(round(global.memory["active_save_point_y"])) and \
            int(round(z)) == int(round(global.memory["active_save_point_z"]))

func generateId():
    return get_tree().get_root().get_node("Game/Viewport/level").getLevelName() + ":" + get_name()

func passiveActivate(delta):
    if not isOnSavePoint():
        saveSound.play()
        global.memory["active_save_point_x"] = self.translation.x
        global.memory["active_save_point_y"] = self.translation.y
        global.memory["active_save_point_z"] = self.translation.z
        global.memory["roomPath"] = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
        global.saveGame()

func isActive():
    return true
