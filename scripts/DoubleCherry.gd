extends Spatial


onready var crunchSound = get_node("CrunchSound")


# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if not visible and not crunchSound.is_playing():
        queue_free() # can we respawn it after used by the player..., need to keep a store?

func passiveActivate(delta):
    visible = false
    global.num_cherries_eaten += 1
    crunchSound.play()

func isActive():
    return visible