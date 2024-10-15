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
var animation_speed_multiplier = 1.0

func _ready():
    if not is_in_group("savepoints"):
        add_to_group("savepoints")
    id = self.generateId()

    set_process(true)
    saveDiskSprite.set_material_override(saveDiskSprite.get_material_override().duplicate())

var was_on_save_point = false
func _process(delta):
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier * animation_speed_multiplier
    if global.pauseGame:
        return
    
    if isOnSavePoint():
        triangleContainer.rotation_degrees.y -= delta*22*5
        if not is_active or not was_on_save_point:
            enablePaletteCycle()
            spawn_timer = spawn_time_limit
            triangleContainer.scale.x = 1.5
            triangleContainer.scale.y = 1.5
            if triangleContainer.visible and not global.isEnteringRoom:
                level.saveTheGame()
            aniPlayer.play("sporeGrow")
        is_active = true
        was_on_save_point = true
    else:
        triangleContainer.scale.x = 1
        triangleContainer.scale.y = 1
        was_on_save_point = false
        triangleContainer.rotation_degrees.y += delta*22*inactive_triangle_rotation_direction
        if triangleContainer.rotation_degrees.y >= 45 and inactive_triangle_rotation_direction == 1:
            inactive_triangle_rotation_direction = -1
        elif triangleContainer.rotation_degrees.y <= -45 and inactive_triangle_rotation_direction == -1:
            inactive_triangle_rotation_direction = 1
        disablePaletteCycle()
        is_active = false
        aniPlayer.play("default")

    # if is_active and triangleContainer.visible:
    #     spawn_timer += (delta*22)
    #     if spawn_timer >= spawn_time_limit:
    #         var children = self.get_children()
    #         var num_children = 0
    #         for i in children:
    #             num_children += 1

    #         if num_children < 20:
    #             var newSprite = sparkleSprite.duplicate()
    #             newSprite.should_fizzle_out = true
    #             newSprite.visible = true
    #             newSprite.transform.origin = Vector3(
    #                 stepify(rand_range(-1.0, 1.0), 0.125),
    #                 stepify(rand_range(0.5, 1.5), 0.125),
    #                 0
    #             )
    #             newSprite.updateBaseFrame(0, 0)
    #             newSprite.max_frames = 2
    #             add_child(newSprite)
    #             spawn_timer = 0

func isOnSavePoint():
    if global.memory.has("savePoint") and global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] == level.getLevelName():
        var relativePathFromLevelToSavePoint = global.memory["savePoint"]
        return self == level.get_node(relativePathFromLevelToSavePoint)

    if not global.memory.has("active_save_point_x"):
        return false

    var origin = self.global_transform.origin
    var x = origin.x
    var y = origin.y
    var z = origin.z
    return int(round(x)) == int(round(global.memory["active_save_point_x"])) and \
            int(round(y) - 1) == int(round(global.memory["active_save_point_y"])) and \
            int(round(z)) == int(round(global.memory["active_save_point_z"]))

func enablePaletteCycle():
    saveDiskSprite.material_override.set_shader_param("enable_palette_cycle", true)
    saveDiskSprite.material_override.set_shader_param("target_palette", global.base_palette)

func disablePaletteCycle():
    saveDiskSprite.material_override.set_shader_param("enable_palette_cycle", false)
    saveDiskSprite.material_override.set_shader_param("target_palette", global.grey_palette)

func generateId():
    return get_tree().get_root().get_node("Game/Viewport/level").getLevelName() + ":" + get_name()

var is_currently_on_save_point = false
func passiveActivate(_delta, _is_player):
    # global.memory["hearts_recovering"] = true
    # level.player.restoreGlitchAndMP()
    # if level.player.is_mushroom_infected:
    #     level.player.is_mushroom_infected = false
    #     level.player.summonSmokeClouds(2, true, true)
    #     musicPlayer.changeSongPitch(1.0)
    #     if not global.memory["broom"]:
    #         level.player.getABroom()
    global.memory["hp"] = global.memory["max_hp"]
    if not global.isRespawning and (not is_currently_on_save_point or not isOnSavePoint()):
        
        was_on_save_point = false
        if not saveSound.is_playing():
            if isOnSavePoint():
                saveSound.volume_db = -38
            else:
                saveSound.volume_db = -32
            saveSound.play()
        global.saveMySpot(global.getNameRelativeToLevel(level, self), global_transform.origin + Vector3(0, -1, 0), level)
        
        global.memory.erase("player_y_offset")
    is_currently_on_save_point = true

func justStopPassiveActivate():
    is_currently_on_save_point = false

func isActive(_debug=false):
    return true
