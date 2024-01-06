extends Area

onready var parent = get_parent()

var is_touching_enemy = false
var is_touching_water = false
var is_touching_door = false
var touched_water_area = null
var is_touching_ladder = false
var water_y = 0 # what does it do? nothing.y

func _ready():
    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if global.hasJustEnteredRoom or global.isEnteringRoom:
        return
    
    is_touching_enemy = false
    is_touching_water = false
    is_touching_door = false
    touched_water_area = null
    is_touching_ladder = false
    var areas = get_overlapping_areas()
    for area in areas:
        # always interact with passive interaction areas
        if area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"):
            area.PassiveInteractActivate(delta)

        if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            is_touching_enemy = true
            parent.tryDieToEnemy(delta, true, false)
        if area.is_in_group("water"):
            var collision_shape = area.get_node("CollisionShape")
            is_touching_water = true
            water_y = collision_shape.global_transform.origin.y + (collision_shape.get_shape().get_extents().y) + 1
            touched_water_area = area
        if area.is_in_group("ladder"):
            is_touching_ladder = true
        if area.is_in_group("door") and parent.nesting_doll_state != global.NestingDoll.MATRIARCH:
            is_touching_door = true
            var door = area.get_node("..")
            if door.is_unlocking or door.is_passive or not door.visible:
                is_touching_door = false

    parent.interactPromptSprite.visible = is_touching_door and \
                                          (global.activeInteractor == null or global.activeInteractor.is_tiny) and \
                                          not global.isEnteringRoom and not global.pauseGame and parent.on_ground   
