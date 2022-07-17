extends KinematicBody

onready var mySprite = get_node("Sprite3D")
onready var aniPlayer = get_node("AnimationPlayer")
onready var appearSound = get_node("AppearSound")
onready var popSound1 = get_node("PopSound")
onready var popSound2 = get_node("PopSound2")
var original_pos_x = null
var target_pos_x = null
var opacity = 0.5
var target_opacity = 1.0
var didja_get_me = false
var y_speed = 2


onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var levelTiles = null
func getLevelTiles():
	if level == null:
		level = get_tree().get_root().get_node("Game/Viewport/level")
	if levelTiles == null:
		levelTiles = level.levelTiles
	return levelTiles

var player = null
func getPlayer():
	if level == null:
		level = get_tree().get_root().get_node("Game/Viewport/level")
	if player == null:
		player = level.player
	return player
	
var gameCamera = null
func getGameCamera():
	if level == null:
		level = get_tree().get_root().get_node("Game/Viewport/level")
	if gameCamera == null:
		gameCamera = level.gameCamera
	return gameCamera

func _ready():
	popSound1.play()
	popSound2.play()
	appearSound.play()
	mySprite.material_override = mySprite.material_override.duplicate()
	aniPlayer.queue("bubbleGrow")
	aniPlayer.queue("bubble")
	
	original_pos_x = global_transform.origin.x
	randomizeTargetPos()
	y_speed = rand_range(2, 3.5)

func _process(delta):
	delta = delta * global.time_dilation_multiplier
	
	if didja_get_me:
		if not mySprite.visible:
			queue_free()
	else:
		global_transform.origin.y += delta*y_speed

		global_transform.origin.x = global_transform.origin.x + (target_pos_x - global_transform.origin.x) * (delta*5)
		if stepify(global_transform.origin.x, 0.1) == target_pos_x:
			randomizeTargetPos()

		opacity = opacity + (target_opacity - opacity) * (delta * 5)
		mySprite.material_override.set_shader_param("opacity", opacity)
		if stepify(opacity, 0.1) == target_opacity:
			if target_opacity == 1.0:
				target_opacity = 0.5
			else:
				target_opacity = 1.0

		tryDieToOffscreenCamera()
		bulletTryDieToSolids()

func isActive():
	return true

func passiveActivate(_delta):
	if not didja_get_me:
		bubbleStartPop()
		getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y
		getPlayer().should_magic_jump = true
		getPlayer().was_just_on_ground_timer = -8
		if getPlayer().linear_velocity.y < 0:
			getPlayer().linear_velocity.y = -0.01
		getPlayer().jump_press_timer = 0

func bubbleStartPop():
	popSound1.play()
	popSound2.play()
	mySprite.frame_delay = 0.1
	mySprite.should_randomize_frame_delay = false
	mySprite.updateBaseFrame(2, 2)
	mySprite.should_soft_fizzle_out = true
	didja_get_me = true
	global_transform.origin.y += .625


func randomizeTargetPos():
	target_pos_x = original_pos_x + rand_range(-2, 2)

func bulletTryDieToSolids():
	for x in range(global_transform.origin.x - 2, global_transform.origin.x + 2):
		var y = global_transform.origin.y + 1
		var z = global_transform.origin.z
		
		var coords_a = getLevelTiles().world_to_map(Vector3(x, y, z))
		var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
		var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

		if isTileSolid(tile_type_a, true, 1, tile_pos_a):
			bubbleStartPop()
			break

func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
	var checking_for_floor_collisions = is_vertical and sensor_direction == -1
	if tile_type == GridMap.INVALID_CELL_ITEM:
		return false
	var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
	return tileCollisionShape is BoxShape or (checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords))
	
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
	var y = global_transform.origin.y
	var tb = get_node("CollisionShape").shape.height/2
	var bb = -tb
	var is_above_top_of_tile = y + bb > tile_pos_coords.y
	
	var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
	return is_above_top_of_tile and (tileCollisionShape is PlaneShape)

func tryDieToOffscreenCamera():
	var DEATH_MARGIN = 5
	if getGameCamera().rightmost_x > -999:
		if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
		global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
		global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
		global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
			queue_free()
