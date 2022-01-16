extends "../GameMover.gd"

onready var interactionArea = get_node("InteractionArea")

var broom_timer = 0
var broom_time_limit = 2
var broom_state = 0
var can_broom = global.can_broom
var jump_press_timer = 999
var jump_press_time_limit = 5

var has_played_fall_sound = false

func _ready():
	set_physics_process(true)
	set_process(true)
	
func _process(delta):
	if jump_press_timer <= jump_press_time_limit:
		jump_press_timer += 1

	if justPressedJump():
		jump_press_timer = 0
		
	# this is a little weird but fixes the fallthrough area situation:
	if linear_velocity.y < 0:
		interactionArea.transform.origin.y = -2
	else:
		interactionArea.transform.origin.y = 0

	if global.memory.has("fishingRod") and on_ground and justPressedDown():
		aniPlayer.stop()
		aniPlayer.clear_queue()
		aniPlayer.queue("fishingSit")

	

# @override
func respawn():
	playerRespawn("long_fade")

# param transition name only used as a crappy enum
func playerRespawn(transition_name):
	if transitioning: return
		
	if not has_played_fall_sound:
		if not fallSound.is_playing():
			fallSound.play()
		has_played_fall_sound = true
	global.isRespawning = true
	# global transition scene, see res://scripts/transition.gd
	var currLevelPath = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
	transitioning = true

	if transition_name == "long_fade":
		transition.long_fade_to(currLevelPath)
	elif transition_name == "blink_fade":
		transition.blink_fade_to(currLevelPath)
	else:
		transition.fade_to(currLevelPath)

# @override
func justPressedDown():
	return Input.is_action_just_pressed("ui_down")

# @override
func pressingDown():
	return Input.is_action_pressed("ui_down")

# @override
func justPressedJump():
	return Input.is_action_just_pressed("jump_button") or should_magic_jump
	
# @override
func recentlyJustPressedJump():
	return jump_press_timer < jump_press_time_limit

# @override
func pressingJump():
	return Input.is_action_pressed("jump_button")

# @override
func pressingMoveForward():
	return Input.is_action_pressed("ui_up")
	
# @override
func pressingMoveDown():
	return Input.is_action_pressed("ui_down")
	
# @override
func pressingMoveLeft():
	return Input.is_action_pressed("ui_left")

# @override
func pressingMoveRight():
	return Input.is_action_pressed("ui_right")

func magicJump():
	should_magic_jump = true

# @override
func handleSpikeCollisions():
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var rb = get_node("CollisionShape").shape.radius
	var lb = -rb
	var tb = get_node("CollisionShape").shape.height/2
	var bb = -tb
	
	var TILE_WIDTH = levelTiles.cell_size.x
	var TILE_HEIGHT = levelTiles.cell_size.y
	
	var margin = 0.12

	for i in range(int(round(y+bb-0.24))-1, int(round(y+tb))+1):
		for j in range(int(round(x+lb))-1, int(round(x+rb))+1):
			var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
			var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
			var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
			var tile_x = tile_pos.x - TILE_WIDTH/2
			var tile_y = tile_pos.y - TILE_HEIGHT/2
			if isTileSpikes(tile_type) and isRectColliding(
				tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
				x + lb + margin, y + tb - margin, x + rb - margin, y + bb + margin
			):
				tryDieToEnemy(false)
				return

# @override
func landed():
	if is_falling:
		transition.interrupt()
		is_falling = false
		fallSound.stop()
		transitioning = false
		global.isRespawning = false
	.landed() #super
