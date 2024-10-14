extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_waterfall = false
var is_touching_ladder = false
var stupid_timer = 0
var stupid_time_limit = 2
onready var parent = get_parent()

func _ready():
    set_process(true)

func isActive(_debug=false):
    if parent.has_method("isPlayerPassiveActive"):
        return parent.isPlayerPassiveActive()
    return parent.has_method("isActive") and \
           parent.isActive()

func playerActivationAreaPassiveActivate():
    if parent.has_method("playerActivationAreaPassiveActivate"):
        parent.playerActivationAreaPassiveActivate()
    touchingPlayer = true
    stupid_timer = 0

func _process(delta):
    wasTouchingPlayer = touchingPlayer
    # if touchingPlayer:
    #     wasTouchingPlayer = touchingPlayer
    # else:
    #     stupid_timer += (delta*11)
    #     if stupid_timer >= stupid_time_limit:
    #         wasTouchingPlayer = false
    #         stupid_timer = 0
    # print(str(touchingPlayer) + ", " + str(wasTouchingPlayer))
    touchingPlayer = false
