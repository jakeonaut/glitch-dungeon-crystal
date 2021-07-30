extends "GameMover.gd"

onready var meshInstance = get_node("MeshInstance")
var flipTimer = 0
var flipTimeLimit = 4

onready var dieSound = get_node("Sounds/DieSound")

export var behavior_walking = false
export var walk_direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    walk_speed = 5

func _process(delta):
    if behavior_walking and horizontal_collision:
        horizontal_collision = false
        walk_direction = -walk_direction

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500
    pass

# @override
func pressingMoveLeft():
    return behavior_walking and walk_direction == -1

# @override
func pressingMoveRight():
    return behavior_walking and walk_direction == 1

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