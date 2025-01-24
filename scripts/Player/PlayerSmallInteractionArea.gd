extends Area

onready var parent = get_parent()
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var is_touching_enemy = false
var is_touching_water = false
var is_touching_waterfall = false
var is_touching_door = false
var is_touching_passive_door = false
var is_touching_npc = false
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
    is_touching_door = false
    is_touching_passive_door = false
    is_touching_npc = false
    touched_water_area = null
    is_touching_ladder = false
    is_touching_carcass = false
    is_touching_save_point = false

    var areas = get_overlapping_areas()
    var non_malware_areas = []

    for area in areas:
        if area.is_in_group("save_point"):
            is_touching_save_point = true

        if not area.is_in_group("malware") and not area.get_node("..") == parent:
            non_malware_areas.push_back(area)
        # always interact with passive interaction areas
        if area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"):
            area.PassiveInteractActivate(delta)
        if area.has_method("PassivePassiveInteractActivate"):
            area.PassivePassiveInteractActivate(delta)

        if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            var enemy = area.get_node("..")
            is_touching_enemy = true
            if enemy.has_method("doSomethingElseToPlayer"):
                enemy.doSomethingElseToPlayer(parent)
            elif parent.visible:
                parent.tryDieToEnemy(delta, true, enemy.kill_invis, enemy.kill_immediately)
        if area.is_in_group("water"):
            var collision_shape = area.get_node("CollisionShape")
            is_touching_water = true
            water_y = collision_shape.global_transform.origin.y + (collision_shape.get_shape().get_extents().y) + 1
            touched_water_area = area
            if area.is_in_group("waterfall"):
                is_touching_waterfall = true
        if area.is_in_group("ladder"):
            is_touching_ladder = true
        if area.is_in_group("door"):
            var temp = true
            var door = area.get_node("..")
            if door.is_unlocking or door.is_passive or not door.visible or not door.isActive(true):
                temp = false

            if temp:
                is_touching_door = true
            if door.is_passive:
                is_touching_passive_door = true
        if area.is_in_group("true_small_door"):
            var temp = true
            var door = area.get_node("..")
            if door.is_unlocking or door.is_passive or not door.visible or not door.isActive():
                temp = false
                
            if temp:
                is_touching_door = true
        if area.is_in_group("carcass"):
            is_touching_carcass = true
        if area.is_in_group("return_recover"):
            parent.tryToRecover()
        if area.is_in_group("npc"):
            is_touching_npc = true

    if parent.physics_state == parent.PhysicsState.BEING_TOSSED:
        global.broomSmackStuff(non_malware_areas, true, parent.global_transform, null, level, null)

    parent.interactPromptSprite.visible = is_touching_door and \
                                          not global.isEnteringRoom and not global.pauseGame
