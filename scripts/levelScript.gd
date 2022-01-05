extends Node

onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var gameCamera = get_node("GameCamera")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type

var grey_palette = preload("res://assets/palettes/grey_palette.png")
var red_palette = preload("res://assets/palettes/red_palette.png")
var green_palette = preload("res://assets/palettes/green_palette.png")
var black_palette = preload("res://assets/palettes/black_palette.png")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")
var white_palette = preload("res://assets/palettes/white_palette.png")

func _ready():
    # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
    _ready_impl()

func _ready_impl():
    set_process_input(true)
    set_process(true)

    if not global.memory.has("spellbookPage"):
        player.applyGlitch(starting_glitch_type)
    else:
        player.applyGlitch(global.memory["current_glitch"])

    if global.memory.has("player_costume"):
        player.wearCostume(global.memory["player_costume"])

    # update music
    musicPlayer.conductFromScenePath(getLevelName())
    
    tryToRespawn()

    global.activeThrowableObject = null
    if global.activeThrowableObjectPath != null:
        # resource is loaded at compile time
        var carriedThrowableObject = load(global.activeThrowableObjectPath).instance() 
        add_child(carriedThrowableObject)
        carriedThrowableObject.activate()
        carriedThrowableObject.spawn_origin = carriedThrowableObject.global_transform.origin
    else:
        pass
    global.activeThrowableObjectPath = null

# TODO(jaketrower): Remove this level edit stuff in final cut ?!?
func _process(delta):
    if Input.is_action_just_pressed("ui_place_tile"):
        var player_position = player.global_transform.origin + (player.facing * 2)
        var grid_cell = levelTiles.world_to_map(player_position)
        levelTiles.set_cell_item(grid_cell.x, grid_cell.y, grid_cell.z, 0)

    if Input.is_action_just_pressed("ui_save"):
        var packed_scene = PackedScene.new()
        packed_scene.pack(get_tree().get_current_scene())
        ResourceSaver.save("res://saved_scene.tscn", packed_scene)

func overrideLevelRespawnEvent():
    pass

func getLevelName():
    return get_tree().get_root().get_node("Game").get_filename()

func tryToRespawn():
    if global.activeInteractor != null:
        global.activeInteractor.stopInteract()
    global.activeInteractor = null
    global.pauseMoveInput = false
    global.pauseGame = false

    var found_door = null
    if global.memory.has("active_save_point_x") and global.isRespawning \
       and global.memory["roomPath"] == getLevelName():
        player.global_transform.origin = Vector3(
            global.memory["active_save_point_x"], 
            global.memory["active_save_point_y"], 
            global.memory["active_save_point_z"])
        player.getCamera().rotation_degrees.y = global.cameraRotation
        player.last_grounded_y = player.global_transform.origin.y 
    elif global.memory.has("lastDoor") and global.memory["roomPath"] != getLevelName():
        var door_path = global.memory["roomPath"]
        var doors = get_tree().get_nodes_in_group("doors")
        for door in doors:
            print(str(door.path) + ", " + str(door_path) + " ==? " + str(door.path == door_path))
            if door.path == door_path:
                found_door = door
                break
        # if no door found, pick the first door in the level!
        if not found_door and doors.size() > 0:
            found_door = doors[0]
    else:
        player.global_transform.origin = player.spawn_origin

    if found_door:
        found_door.land()
    elif not global.memory.has("roomPath") or global.memory["roomPath"] != getLevelName():
        player.global_transform.origin = player.spawn_origin

    global.isRespawning = false

    self.overrideLevelRespawnEvent()


func normalGlitch():
    levelTiles.normalGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", grey_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", grey_palette)

func floorGlitch():
    levelTiles.floorGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", red_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", red_palette)

func featherGlitch():
    levelTiles.featherGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", green_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", green_palette)

func ladderGlitch():
    levelTiles.ladderGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", yellow_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", yellow_palette)

func invisibleGlitch():
    levelTiles.invisibleGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", black_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", black_palette)

func walkThroughWallsGlitch():
    levelTiles.walkThroughWallsGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", white_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", white_palette)
