extends Spatial

onready var cylinder = get_node("Cylinder")

func _ready():
    set_process(true)

var pre_purification_rotate_amt = 1

func _process(delta):
    cylinder.rotation_degrees.y -= delta*22 * pre_purification_rotate_amt