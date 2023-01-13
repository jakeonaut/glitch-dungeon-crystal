extends Spatial

onready var sparkleSprite = get_node("SparkleSprite3D")
onready var triangleContainer = get_node("TriangleContainer")
onready var saveDiskSprite = get_node("TriangleContainer/Sprite3D")
onready var saveSound = get_node("SaveSound")
onready var aniPlayer = get_node("AnimationPlayer")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var inactive_triangle_rotation_direction = 1
var id = null
var is_active = false

var spawn_timer = 0
var spawn_time_limit = 5
var has_grown_spores = false
var animation_speed_multiplier = 1.0

func _ready():
    if not is_in_group("savepoints"):
        add_to_group("savepoints")
    id = self.generateId()

    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier * animation_speed_multiplier
    
    if isOnSavePoint():
        triangleContainer.rotation_degrees.y -= delta*22*5
        if not is_active:
            enablePaletteCycle()
            spawn_timer = spawn_time_limit
            if triangleContainer.visible:
                level.saveTheGame()
            if not has_grown_spores:
                aniPlayer.play("sporeGrow")
                has_grown_spores = true
        is_active = true
    else:
        triangleContainer.rotation_degrees.y += delta*22*inactive_triangle_rotation_direction
        if triangleContainer.rotation_degrees.y >= 45 and inactive_triangle_rotation_direction == 1:
            inactive_triangle_rotation_direction = -1
        elif triangleContainer.rotation_degrees.y <= -45 and inactive_triangle_rotation_direction == -1:
            inactive_triangle_rotation_direction = 1
        if is_active:
            disablePaletteCycle()
        is_active = false

    if is_active and triangleContainer.visible:
        spawn_timer += (delta*22)
        if spawn_timer >= spawn_time_limit:
            var children = self.get_children()
            var num_children = 0
            for i in children:
                num_children += 1

            if num_children < 20:
                var newSprite = sparkleSprite.duplicate()
                newSprite.should_fizzle_out = true
                newSprite.visible = true
                newSprite.transform.origin = Vector3(
                    stepify(rand_range(-1.0, 1.0), 0.125),
                    stepify(rand_range(0.5, 1.5), 0.125),
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

func enablePaletteCycle():
    setPaletteCycle(saveDiskSprite, true)

func disablePaletteCycle():
    setPaletteCycle(saveDiskSprite, false)

func setPaletteCycle(sprite, value):
    var my_material = sprite.get_material_override()
    if my_material is ShaderMaterial:
        var new_material = my_material.duplicate()
        new_material.set_shader_param("enable_palette_cycle", value)
        sprite.set_material_override(new_material)

func generateId():
    return get_tree().get_root().get_node("Game/Viewport/level").getLevelName() + ":" + get_name()

func passiveActivate(_delta):
    # global.memory["hearts_recovering"] = true
    # level.player.restoreGlitchAndMP()
    if not isOnSavePoint():
        saveSound.play()
        global.memory["active_save_point_x"] = self.translation.x
        global.memory["active_save_point_y"] = self.translation.y
        global.memory["active_save_point_z"] = self.translation.z
        global.memory["roomPath"] = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
        
        global.memory.erase("player_y_offset")

func isActive():
    return true
