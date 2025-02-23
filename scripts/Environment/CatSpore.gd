extends Spatial

onready var mySprite = weakref(get_node("Sprite3D"))
var target_pos = null
var delta_multiplier = 1.0

func _ready():
    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    global_transform.origin.x = global_transform.origin.x + (target_pos.x - global_transform.origin.x) * (delta * delta_multiplier)
    global_transform.origin.y = global_transform.origin.y + (target_pos.y - global_transform.origin.y) * (delta * delta_multiplier)
    if mySprite.get_ref() == null:
        queue_free()