extends Area

onready var parent = get_parent()
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var prev_fallthrough_collision_area = null
var prev_prev_fallthrough_collision_area = null
var is_touching_enemy = false
var is_touching_water = false
var is_touching_waterfall = false
var touched_water_area = null
var is_touching_ladder = false
var is_touching_carcass = false
var is_touching_save_point = false
var water_y = 0 # what does it do? nothing.y

func _ready():
    set_process(true)

func isActive(_debug=false):
    return true

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if global.hasJustEnteredRoom or global.isEnteringRoom:
        return
    
    is_touching_enemy = false
    is_touching_water = false
    is_touching_waterfall = false
    touched_water_area = null
    is_touching_ladder = false
    is_touching_carcass = false
    is_touching_save_point = false

    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("save_point"):
            is_touching_save_point = true

        # always interact with passive interaction areas
        if parent.isActive() and area.has_method("isActive") and area.isActive() and area.has_method("OtherPassiveInteractActivate"):
            area.OtherPassiveInteractActivate(delta, parent)

        if area.is_in_group("water"):
            var collision_shape = area.get_node("CollisionShape")
            is_touching_water = true
            water_y = collision_shape.global_transform.origin.y + (collision_shape.get_shape().get_extents().y) + 1
            touched_water_area = area
            if area.is_in_group("waterfall"):
                is_touching_waterfall = true
        if area.is_in_group("ladder"):
            is_touching_ladder = true
        if area.is_in_group("carcass"):
            is_touching_carcass = true
