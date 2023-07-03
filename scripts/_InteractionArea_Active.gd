extends Area

var is_touching_water = false

func _ready():
    set_process(true)
        
func isActive():
    return get_parent().has_method("isActive") and get_parent().isActive()

func InteractActivate(is_player=true):
    if get_parent().has_method("activate"):
        get_parent().activate(is_player)

func _process(_delta):
    var areas = get_overlapping_areas()
    is_touching_water = false
    for area in areas:
        if area.is_in_group("water"):
            is_touching_water = true
