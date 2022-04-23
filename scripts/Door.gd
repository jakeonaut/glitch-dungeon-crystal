extends Spatial

var id = null
onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
export var should_lock = false
# String is a path to a file.
export(String, FILE) var path

export var is_passive = false
export var is_vertical = false
export var num_cubes_unlock = 999

onready var npc = get_node("NPC")

onready var doorCloseSound = get_node("DoorCloseSound")
onready var doorOpenSound = get_node("DoorCloseSound")
onready var lockedSound = get_node("LockedSound")

var hasPlayedDoorSound = false

var spawn_timer = 0
var spawn_time_limit = 5

onready var mySprite = get_node("Sprite3D")
onready var landing = get_node("landing")
onready var sparkleSprite = get_node("SparkleSprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var is_on_main_menu = false

var player = null
func getPlayer():
	if player == null:
		player = level.player
	return player

func _ready():
	set_process(true)
	landing.visible = false

	if is_passive:
		mySprite.visible = false

	id = self.generateId()

	animationPlayer.clear_queue()
	animationPlayer.stop()
	if is_locked:
		animationPlayer.play("locked")
	elif should_lock:
		is_locked = true
		doorCloseSound.play()
		animationPlayer.queue("doorOpen")
		animationPlayer.queue("doorClose")
		animationPlayer.queue("locked")
	else: 
		animationPlayer.play("doorOpen")

	if is_locked or should_lock:
		npc.textBoxContainer.bbText = str(num_cubes_unlock) + " cube to unlock"
		npc.textBoxContainer.setVars()
		
func _process(delta):
	delta = delta * global.time_dilation_multiplier
	animationPlayer.playback_speed = global.time_dilation_multiplier
	
	if global.pauseGame: return

	if is_passive:
		spawnParticles(delta)

func spawnParticles(delta):
	spawn_timer += (delta*22)
	if spawn_timer >= spawn_time_limit:
		var x_y_min_max = calculateXYMinMax()
		var x_min = x_y_min_max[0]
		var x_max = x_y_min_max[1]
		var y_min = x_y_min_max[2]
		var y_max = x_y_min_max[3]
		var target_x_add = x_y_min_max[4]
		var target_y_add = x_y_min_max[5]

		var children = self.get_children()
		var num_children = 0
		for i in children:
			num_children += 1

		if num_children < 20:
			var newSprite = sparkleSprite.duplicate()
			newSprite.should_fizzle_out = true
			newSprite.visible = true
			newSprite.transform.origin = Vector3(
				stepify(rand_range(x_min, x_max), 0.12),
				stepify(rand_range(y_min, y_max), 0.12),
				0
			)
			newSprite.updateBaseFrame(0, 0)
			newSprite.max_frames = 2
			add_child(newSprite)
			newSprite.target_x = newSprite.global_transform.origin.x + target_x_add
			newSprite.target_y = newSprite.global_transform.origin.y + target_y_add
			newSprite.fade_out_opacity = true
			newSprite.curr_opacity = 0.4
			newSprite.start_frame = randi() % 100
			newSprite.restart()
			newSprite.opacity_fade_rate = 6
			spawn_timer = 0
			
func calculateXYMinMax():
	var x_min = -1.0
	var x_max = 1.0
	var y_min = 0.5
	var y_max = 2.5
	var target_x_add = 0
	var target_y_add = 0
	if not is_vertical:
		if landing.global_transform.origin.x < self.global_transform.origin.x:
			x_min = -4
			x_max = -3
			target_x_add = rand_range(-3, -1.5)
		else:
			x_min = 3
			x_max = 4
			target_x_add = rand_range(1.5, 3)
	else:
		x_min = -1.0
		x_max = 1.0
		if landing.global_transform.origin.y < self.global_transform.origin.y:
			y_min = -2
			y_max = -0.5
			target_y_add = rand_range(-3, -1.5)
		else:
			y_min = 2.5
			y_max = 4.0
			target_y_add = rand_range(1.5, 3)
	# okay.... I wish godot allowed multiple return values like javascript
	return [x_min, x_max, y_min, y_max, target_x_add, target_y_add] 

func isActive():
	return true

func generateId():
	return get_name()

func activate():
	if not is_passive:
		if not is_locked and not should_lock and global.activeInteractor == null:
			goThroughDoor()
		elif is_locked:
			if not lockedSound.is_playing():
				lockedSound.play()
				npc.activate()
			if global.num_mini_crystal_cubes >= num_cubes_unlock:
				animationPlayer.clear_queue()
				animationPlayer.stop()
				doorOpenSound.play()
				animationPlayer.queue("doorOpen")
				is_locked = false

func passiveActivate(delta):
	if is_passive:
		goThroughDoor()
	else:
		getPlayer().showInteractPrompt()
		
func justStopPassiveActivate():
	getPlayer().hideInteractPrompt()

func goThroughDoor(start_of_game = false):
	if not global.isRespawning and not hasPlayedDoorSound:
		global.doorSound.play()
		hasPlayedDoorSound = true

	global.activeInteractor = null
	if start_of_game:
		transition.long_fade_to(self.path)
		return
		
	global.memory["cameraSize"] = level.gameCamera.initial_size
	global.memory["lastDoor"] = id
	global.memory["roomPath"] = level.getLevelName()
	global.pauseGame = true

	global.isRespawning = true
	if is_passive:
		global.memory["player_flip_h"] = getPlayer().mySprite.flip_h
		if is_vertical:
			global.memory["feather_jump_timer"] = getPlayer().feather_jump_timer
		else:
			global.memory["player_y_offset"] = getPlayer().global_transform.origin.y - global_transform.origin.y - 1
		global.memory["linear_velocity"] = getPlayer().linear_velocity
		transition.fade_to(self.path)
	else:
		transition.long_fade_to(self.path)

func land():
	global.pauseGame = false
	# TODO(jaketrower): Oh...
	global.memory.erase("active_save_point_x")
	global.memory.erase("active_save_point_y")
	global.memory.erase("active_save_point_z")
	
	getPlayer().global_transform.origin.x = landing.global_transform.origin.x
	getPlayer().global_transform.origin.y = landing.global_transform.origin.y

	getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", false)

	if is_passive:
		if global.memory.has("player_flip_h"):
			getPlayer().mySprite.flip_h = global.memory["player_flip_h"]
			global.memory.erase("player_flip_h")
		if global.memory.has("player_y_offset"):
			print(str(getPlayer().global_transform.origin.y) + ", " + str(global.memory["player_y_offset"]))
			getPlayer().global_transform.origin.y += global.memory["player_y_offset"]
		if global.memory.has("feather_jump_timer"):
			getPlayer().feather_jump_timer = global.memory["feather_jump_timer"]
			global.memory.erase("feather_jump_timer")
		if global.memory.has("linear_velocity"):
			getPlayer().linear_velocity = global.memory["linear_velocity"]
			global.memory.erase("linear_velocity")

		if is_vertical:
			getPlayer().on_ground = false
			
	getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y
