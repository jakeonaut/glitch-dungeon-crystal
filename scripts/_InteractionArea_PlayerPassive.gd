extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_waterfall = false
var is_touching_ladder = false
onready var parent = get_parent()

func _ready():
    set_process(true)

func isActive():
    return parent.has_method("isActive") and \
           parent.isActive()

func playerActivationAreaPassiveActivate():
    if parent.has_method("playerActivationAreaPassiveActivate"):
        parent.playerActivationAreaPassiveActivate()
    touchingPlayer = true

func _process(_delta):
    pass
