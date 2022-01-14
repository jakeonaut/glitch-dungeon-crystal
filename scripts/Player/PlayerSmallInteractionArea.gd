extends Area

onready var parent = get_parent()

var is_touching_enemy = false
var is_touching_water = false
var water_y = 0

func _ready():
    set_process(true)

func _process(delta):
    is_touching_enemy = false
    is_touching_water = false
    var areas = get_overlapping_areas()
    for area in areas:
        # always interact with passive interaction areas
        if area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"):
            area.PassiveInteractActivate(delta)

        if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            is_touching_enemy = true
            parent.tryDieToEnemy(true)
        if area.is_in_group("water"):
            var collision_shape = area.get_node("CollisionShape")
            is_touching_water = true
            water_y = collision_shape.global_transform.origin.y + (collision_shape.get_shape().get_extents().y) + 1
                    
