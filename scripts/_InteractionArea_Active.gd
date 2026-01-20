extends Area

var prev_fallthrough_collision_area = null
var prev_prev_fallthrough_collision_area = null
var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_waterfall = false

func _ready():
    set_process(true)
        
func isActive(_debug=false):
    return get_parent().has_method("isActive") and get_parent().isActive()

func InteractActivate(is_player=true, is_local_broom=false):
    if get_parent().has_method("activate"):
        # if you want to check from the area if it is a SummonedBroom or Thrown, just check is_local_broom = false
        return get_parent().activate(is_player, is_local_broom)
    return false

func playerActivationAreaPassiveActivate():
    touchingPlayer = true

func _process(_delta):
    wasTouchingPlayer = touchingPlayer
    touchingPlayer = false

    var areas = get_overlapping_areas()
    is_touching_water = false
    is_touching_waterfall = false
    for area in areas:
        if area.is_in_group("water"):
            is_touching_water = true
            if area.is_in_group("waterfall"):
                is_touching_waterfall = true
