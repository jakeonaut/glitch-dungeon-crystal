extends "GameMover.gd"

var flipTimer = 0
var flipTimeLimit = 4

onready var dieSound = get_node("Sounds/DieSound")

export var behavior_walking = false
export var behavior_jumping = false
export var behavior_flip_on_land = false
export var behavior_stop_on_land = false
export var behavior_was_thrown = false
export var behavior_thrower = false
export var walk_direction = 1

var glitch_switch_timer = 0
var glitch_switch_time_limit = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	set_process(true)
	set_physics_process(true)
	walk_speed = 5
	
	#if behavior_walking:
	#    mySprite.frame_delay = 0.2
	#    mySprite.updateBaseFrame(0, 1)
	if behavior_jumping:
		grav = 60

	glitch_switch_time_limit = rand_range(30.0, 50.0)
	mySprite.frame_delay = rand_range(0.1, 0.2)

func _process(delta):
	glitch_switch_timer += (delta*22)
	if glitch_switch_timer > glitch_switch_time_limit:
		mySprite.updateBaseFrame(randi() % 6, randi() % 3)
		glitch_switch_time_limit = rand_range(30.0, 50.0)
		glitch_switch_timer = 0

	if behavior_walking and horizontal_collision:
		horizontal_collision = false
		walk_direction = -walk_direction

	var modAmt = 0.5
	mySprite.global_transform.origin.x = int(round(self.global_transform.origin.x))
	mySprite.global_transform.origin.y = int(round(self.global_transform.origin.y))
	smallInteractionArea.global_transform.origin.x = int(round(self.global_transform.origin.x))
	smallInteractionArea.global_transform.origin.y = int(round(self.global_transform.origin.y))

func _physics_process(delta):
	# ._process_physics(delta) #NOTE: this super method is called automatically 
	# https://github.com/godotengine/godot/issues/6500
	pass

# @override
func pressingMoveLeft():
	return walk_direction == -1 and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
	return walk_direction == 1 and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func justPressedJump():
	return behavior_jumping
# @override
func pressingJump():
	return behavior_jumping
	
# @override
func landed():
	.landed()
	if behavior_flip_on_land:
		walk_direction = -walk_direction
	if behavior_stop_on_land:
		behavior_was_thrown = false
		behavior_jumping = false


# @override
func getHitByBroom():
	if visible:
		visible = false
		dieSound.play()

func isActive():
	return visible

func activate():
	pass

func passiveActivate(delta):
	pass

func stopPassiveActivate():
	pass
