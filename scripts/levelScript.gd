extends Node

onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var gameCamera = get_node("GameCamera")

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

	player.applyGlitch(starting_glitch_type)

	if global.memory.has("player_costume"):
		player.wearCostume(global.memory["player_costume"])
	
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

	# update music
	musicPlayer.conductFromScenePath(self.get_filename())

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

func tryToRespawn():
	if global.activeInteractor != null:
		global.activeInteractor.stopInteract()
	global.activeInteractor = null
	global.pauseMoveInput = false
	global.pauseGame = false

	var found_door = null
	if global.memory.has("active_save_point") and global.isRespawning \
	   and global.memory["roomPath"] == self.get_filename():
		player.global_transform.origin = Vector3(
			global.memory["active_save_point_x"], 
			global.memory["active_save_point_y"], 
			global.memory["active_save_point_z"])
		player.getCamera().rotation_degrees.y = global.cameraRotation
		player.last_grounded_y = player.global_transform.origin.y 
	elif global.memory.has("lastDoor"):
		var door_id = global.memory["lastDoor"]
		var doors = get_tree().get_nodes_in_group("doors")
		for door in doors:
			if door.id == door_id:
				found_door = door
				break
		# if no door found, pick the first door in the level!
		if not found_door and doors.size() > 0:
			found_door = doors[0]

	########### (not anymore!) # camera update ... if player has never visited this room.. give it the "default" perspective
	if not global.memory.has(self.get_filename()):
		global.memory[self.get_filename()] = true
		if found_door:
			found_door.land()
			# player.getCamera().rotateTo(found_door.rotation_degrees.y + 180, true)
	elif found_door:
		found_door.land()
		# player.getCamera().rotateTo(global.cameraRotation + found_door.rotation_degrees.y + 180, true)
	# elif global.cameraRotation:
		# player.getCamera().rotateTo(global.cameraRotation, true)

	global.isRespawning = false

	# final global memory management
	# only treat new rooms as "save points" until we introduce save points.
	if not global.memory.has("active_save_point"):
		global.memory["roomPath"] = self.filename
		global.saveGame()

# TODO(jaketrower): Really bad performance?
func normalGlitch():
	levelTiles.normalGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", grey_palette)

func floorGlitch():
	levelTiles.floorGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", red_palette)

func featherGlitch():
	levelTiles.featherGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", green_palette)

func ladderGlitch():
	levelTiles.ladderGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", yellow_palette)

func invisibleGlitch():
	levelTiles.invisibleGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", black_palette)

func walkThroughWallsGlitch():
	levelTiles.walkThroughWallsGlitch()
	get_tree().call_group("sprite","changeSpriteColorPalette", white_palette)
