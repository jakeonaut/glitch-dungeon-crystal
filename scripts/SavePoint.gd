extends Spatial

onready var sparkleSprite = get_node("SparkleSprite3D")
onready var triangleContainer = get_node("TriangleContainer")
onready var saveDiskSprite = get_node("TriangleContainer/Sprite3D")
onready var saveSound = get_node("SaveSound")
onready var aniPlayer = get_node("AnimationPlayer")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var is_weird_soul_spore_save = false

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
var spin_dir = 1
func _process(delta):
    # delta = delta * global.time_dilation_multiplier # i'm exempt!
    # aniPlayer.playback_speed = global.time_dilation_multiplier * animation_speed_multiplier # i'm excempt!
    
    if global.pauseGame or not visible or global.isEnteringRoom:
        return
    
    if isOnSavePoint():
        triangleContainer.rotation_degrees.y -= delta*22*5*spin_dir
        if not is_active or not was_on_save_point:
            enablePaletteCycle()
            spawn_timer = spawn_time_limit
            triangleContainer.scale.x = 1.5
            triangleContainer.scale.y = 1.5
            aniPlayer.play("sporeGrow")
        is_active = true
        was_on_save_point = true
    else:
        if is_weird_soul_spore_save and was_on_save_point:
            global_transform.origin = Vector3(999, 999, 999)
        
        triangleContainer.rotation_degrees.y += delta*22*inactive_triangle_rotation_direction
        if triangleContainer.rotation_degrees.y >= 45 and inactive_triangle_rotation_direction == 1:
            inactive_triangle_rotation_direction = -1
        elif triangleContainer.rotation_degrees.y <= -45 and inactive_triangle_rotation_direction == -1:
            inactive_triangle_rotation_direction = 1
        is_active = false
        aniPlayer.play("default")
        if global.memory.has("weird_active_save_point_x") and was_on_save_point:
            return
        triangleContainer.scale.x = 1
        triangleContainer.scale.y = 1
        disablePaletteCycle()
        was_on_save_point = false

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
    if is_weird_soul_spore_save:
        if not global.memory.has("weird_active_save_point_x"):
            return false
        var origin = self.global_transform.origin
        var x = origin.x
        var y = origin.y
        var z = origin.z
        return int(round(x)) == int(round(global.memory["weird_active_save_point_x"])) and \
                int(round(y) - 1) == int(round(global.memory["weird_active_save_point_y"])) and \
                int(round(z)) == int(round(global.memory["weird_active_save_point_z"]))
    elif not is_weird_soul_spore_save and global.memory.has("weird_active_save_point_x"):
        return false

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
func passiveActivate(_delta, is_player, _is_local_broom = false):
    if not visible: return false

    if is_player:
        if level.player.malware_infected:
            level.player.malwareCured()
        if level.player.nesting_doll_state == global.NestingDoll.BABY:
            level.player.shroomAniPlayer.stop()
            level.player.shroomAniPlayer.clear_queue()
            level.player.shroomAniPlayer.play("RESET")
            level.player.shroomAniPlayer.queue("grow")
            level.player.shroomAniPlayer.queue("adjust")
            level.player.nesting_doll_state = global.NestingDoll.GRANDMA
            global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
            level.player.updateNestingDoll(global.NestingDoll.GRANDMA)
            level.player.getABroom()

    if not global.isRespawning and (not isOnSavePoint() or not is_player):
        was_on_save_point = false
        if not saveSound.is_playing():
            if isOnSavePoint():
                saveSound.volume_db = -38
            else:
                saveSound.volume_db = -32
            if is_weird_soul_spore_save:
                saveSound.volume_db -= 16
            saveSound.play()
        if is_weird_soul_spore_save:
            if not is_player:
                return
            global.saveMySpot("SporeSavePoint", level.player.global_transform.origin + Vector3(0, -1, 0), level, is_weird_soul_spore_save)
        else:
            global.memory["hp"] = global.memory["max_hp"]
            global.saveMySpot(global.getNameRelativeToLevel(level, self), global_transform.origin + Vector3(0, -1, 0), level, false)
            global.memory.erase("player_y_offset")
            level.saveTheGame()
    is_currently_on_save_point = true

func justStopPassiveActivate():
    is_currently_on_save_point = false

func isActive(_debug=false):
    return visible
