extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    
    original_pos = global_transform.origin
    randomizeTargetPos()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*5)

    var diff = target_pos - global_transform.origin
    var step = 0.1
    if stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
        randomizeTargetPos()
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )

    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    
func isActive():
    return true

func passiveActivate(_delta):
    pass
