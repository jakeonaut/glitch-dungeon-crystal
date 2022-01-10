extends Node

onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var fakeLevelTiles = get_node("FakeLevelTiles") if has_node("FakeLevelTiles") else null
onready var gameCamera = get_node("GameCamera")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type
export var has_spellbook_page = false
# IFNDEF FakeLevelTiles.gd (if we get much more scripts doing this, put it in global)
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD") var tileset_type 

export var display_title = "???"

func _ready():
    # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
    _ready_impl()

func _ready_impl():
    set_process_input(true)
    set_process(true)
    
    if tileset_type == global.TilesetType.HOUSE:
        levelTiles.set_mesh_library(levelTiles.red_tiles)
        levelTiles.grey_palette = global.grey_palette_town
        levelTiles.green_palette = global.green_palette_town
        levelTiles.properlySetTiles()
    elif tileset_type == global.TilesetType.FOREST:
        levelTiles.set_mesh_library(levelTiles.green_tiles)
        levelTiles.properlySetTiles()
    
    if has_spellbook_page and not global.memory.has("spellbookPage"):
        print("gimme a spellbook!!")
        global.memory["spellbookPage"] = []

    if not global.memory.has("spellbookPage"):
        player.applyGlitch(starting_glitch_type, true)
    else:
        if global.memory.has("current_glitch"):
            player.applyGlitch(global.memory["current_glitch"], true)
        else:
            player.applyGlitch(starting_glitch_type, true)
            
        if global.memory["spellbookPage"].size() > 0:
            player.applyObeliskGlitch(global.memory["spellbookPage"][0], true)

    if global.memory.has("player_costume"):
        player.wearCostume(global.memory["player_costume"])

    restartMusic()
    tryShowUIElements()
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

func _process(delta):
    if Input.is_action_just_pressed("place_tile_button"):
        var player_position = player.global_transform.origin + (player.facing * 2)
        var grid_cell = levelTiles.world_to_map(player_position)
        levelTiles.set_cell_item(grid_cell.x, grid_cell.y, grid_cell.z, 0)
        
func restartMusic():
    # update music
    musicPlayer.conductFromScenePath(getLevelName())
    
func tryShowUIElements():
    # TODO(jaketrower): Could be better method to fetch this without a weird node search in the ready_impl()
    get_node("UILayer").setDisplayTitle(display_title)

    if global.memory.has("spellbookPage"):
        # TODO(jaketrower): you have to know how stupid this is right?
        get_node("UILayer/ColorRect").visible = true
        get_node("UILayer/ColorRect2").visible = true
    else:
        # TODO(jaketrower): you have to know how stupid this is right?
        get_node("UILayer/ColorRect").visible = false
        get_node("UILayer/ColorRect2").visible = false

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
        gameCamera.rotation_degrees.y = global.cameraRotation
        player.last_grounded_y = player.global_transform.origin.y 
    elif global.memory.has("lastDoor") and global.memory["roomPath"] != getLevelName():
        var door_path = global.memory["roomPath"]
        var doors = get_tree().get_nodes_in_group("doors")
        for door in doors:
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
    if fakeLevelTiles:
        fakeLevelTiles.normalGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.grey_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.grey_palette)

func floorGlitch():
    levelTiles.floorGlitch()
    if fakeLevelTiles:
        fakeLevelTiles.floorGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.red_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.red_palette)

func featherGlitch():
    levelTiles.featherGlitch()
    if fakeLevelTiles:
        fakeLevelTiles.featherGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.green_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.green_palette)

func ladderGlitch():
    levelTiles.ladderGlitch()
    if fakeLevelTiles:
        fakeLevelTiles.ladderGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.yellow_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.yellow_palette)

func invisibleGlitch():
    levelTiles.invisibleGlitch()
    if fakeLevelTiles:
        fakeLevelTiles.invisibleGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.black_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.black_palette)

func walkThroughWallsGlitch():
    levelTiles.walkThroughWallsGlitch()
    if fakeLevelTiles:
        fakeLevelTiles.walkThroughWallsGlitch()
    get_tree().call_group("sprite","changeSpriteColorPalette", global.white_palette)
    get_tree().call_group("glitchSprite","changeSpriteColorPalette", global.white_palette)
