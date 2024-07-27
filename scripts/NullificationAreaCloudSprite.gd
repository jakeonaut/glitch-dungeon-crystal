extends "Sprite.gd"

var original_pos = null
var target_pos = null

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

# Called when the node enters the scene tree for the first time.
func _ready():
    # is_static_in_level = false # TODO(jaketroweR): :-)

    set_process(true)
    original_pos = global_transform.origin
    randomizeTargetPos()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*5)

    var diff = target_pos - global_transform.origin
    var step = 0.2
    if stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
      randomizeTargetPos()
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-0.5, 0.5),
        original_pos.y + rand_range(-0.5, 0.5),
        original_pos.z
    )
    
var is_active = true
func isActive(_debug=false):
    return visible and is_active