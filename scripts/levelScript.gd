extends Node

onready var uiLayer = get_node("UILayer")
onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var fakeLevelTiles = get_node("FakeLevelTiles") if has_node("FakeLevelTiles") else null
onready var gameCamera = get_node("GameCamera")
onready var crtScreenEffect = get_node("../../ScreenEffects/CrtEffectRect")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")
var current_sprite_palette = global.grey_palette

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type
# IFNDEF FakeLevelTiles.gd (if we get much more scripts doing this, put it in global)
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH") var tileset_type 

export var spellbook_forbidden = false
# TODO(jaketrower): Make a debug global section???
export var has_spellbook_page = false
export var has_broom = false
var has_ever_set_camera_position = false

export var display_title = "???"

func _ready():
	# stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
	_ready_impl()

func _ready_impl():
	global.activeInteractor = null # somewhat of a failsafe
	set_process_input(true)
	set_process(true)

	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	levelTiles.my_tileset_type = tileset_type
	levelTiles.buildRandomTiles()
	levelTiles.setTileset(tileset_type)
	
	if has_spellbook_page and not global.memory.has("spellbookPage"):
		print("gimme a spellbook page!!")
		global.memory["spellbookPage"] = []
		
	if has_broom and not global.memory.has("broom"):
		print("gimme the broom!")
		global.memory["broom"] = true

	if global.memory.has("current_glitch"):
		player.applyGlitch(global.memory["current_glitch"], true)
	else:
		player.applyGlitch(starting_glitch_type, true)
		
	if global.memory.has("spellbookPage") and global.memory["spellbookPage"].size() > 0:
		player.applyObeliskGlitch(global.memory["spellbookPage"][0], true)

	if global.memory.has("player_costume"):
		player.wearCostume(global.memory["player_costume"])

	restartMusic()
	tryShowUIElements()
	tryToRespawn()
	setUpRoomInitializationOverride()

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
	delta = delta * global.time_dilation_multiplier

	if Input.is_action_just_pressed("ui_accept") and getLevelName().find("MainMenu") < 0:
		global.canChangeSongPitch = not global.canChangeSongPitch
		global.canGlitchScreen = not global.canGlitchScreen
		global.crtScreenEffects = not global.crtScreenEffects
		crtScreenEffect.visible = global.crtScreenEffects
	
	var amt = 6.0
	crtScreenEffect.material.set_shader_param("g_mult", 1.0 + (amt - amt*global.time_dilation_multiplier))
	crtScreenEffect.material.set_shader_param("b_mult", -1.0 - (amt - amt*global.time_dilation_multiplier))
	# if Input.is_action_just_pressed("place_tile_button"):
	#     var player_position = player.global_transform.origin + (player.facing * 2)
	#     var grid_cell = levelTiles.world_to_map(player_position)
	#     levelTiles.set_cell_item(grid_cell.x, grid_cell.y, grid_cell.z, 0)

func saveTheGame():
	uiLayer.displaySavingText()
	global.saveGame()
		
func restartMusic():
	# update music
	musicPlayer.conductFromScenePath(getLevelName())
	
func tryShowUIElements():
	# TODO(jaketrower): Could be better method to fetch this without a weird node search in the ready_impl()
	uiLayer.setDisplayTitle(display_title)

	if global.memory.has("spellbookPage"):
		# TODO(jaketrower): you have to know how stupid this is right?
		uiLayer.get_node("EquipmentRect").visible = true
		uiLayer.get_node("EquipmentStatusRect").visible = true
	else:
		# TODO(jaketrower): you have to know how stupid this is right?
		uiLayer.get_node("EquipmentRect").visible = false
		uiLayer.get_node("EquipmentStatusRect").visible = false

func overrideLevelRespawnEvent():
	pass
	
func setUpRoomInitializationOverride():
	pass

func getLevelName():
	return get_tree().get_root().get_node("Game").get_filename()
	
func getShortLevelName():
	var longLevelName = getLevelName()
	return longLevelName.substr(13, longLevelName.length() - 18)

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
	else:
		player.global_transform.origin = player.spawn_origin

	if found_door:
		found_door.land()
	elif not global.memory.has("roomPath") or global.memory["roomPath"] != getLevelName():
		player.global_transform.origin = player.spawn_origin
	if not has_ever_set_camera_position:
		gameCamera.setCameraPositionNow()
		has_ever_set_camera_position = true

	global.isRespawning = false

	self.overrideLevelRespawnEvent()


func normalGlitch():
	levelTiles.normalGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.normalGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
	current_sprite_palette = levelTiles.grey_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 4

func floorGlitch():
	levelTiles.floorGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.floorGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
	current_sprite_palette = levelTiles.red_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 9

func featherGlitch():
	levelTiles.featherGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.featherGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
	current_sprite_palette = levelTiles.green_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 14

func ladderGlitch():
	levelTiles.ladderGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.ladderGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
	current_sprite_palette = levelTiles.yellow_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 19

func invisibleGlitch():
	levelTiles.invisibleGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.invisibleGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
	current_sprite_palette = levelTiles.black_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 24

func walkThroughWallsGlitch():
	levelTiles.walkThroughWallsGlitch()
	if fakeLevelTiles:
		fakeLevelTiles.walkThroughWallsGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
	get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
	current_sprite_palette = levelTiles.white_palette
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		door.get_node("Sprite3D2").frame = 29
