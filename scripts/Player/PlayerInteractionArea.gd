extends Area

func _ready():
    set_process(true)

func _process(_delta):
    var has_done_fallthrough_object_collision = false
    var shortest_dist = 999 # zero escape saga
    var nearest_area = null
    var fallthrough_collision_area = null
    var player = get_node("..")

    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("fallthrough"):
            if global.doFallthroughObjectCollision(player, area, true):
                has_done_fallthrough_object_collision = true
                # this makes the last fallthrough object we meet
                fallthrough_collision_area = area
            
        if area.is_in_group("playerActivation") and area.has_method("playerActivationAreaPassiveActivate"):
            area.playerActivationAreaPassiveActivate()

        if area.has_method("isActive") and area.isActive():
            var dist = area.global_transform.origin.distance_to(global_transform.origin)            
            if area.has_method("InteractActivate"):
                if dist < shortest_dist:
                    shortest_dist = dist
                    nearest_area = area

    if global.activeInteractor != null and Input.is_action_just_pressed("sub_action_button"):
        if global.activeInteractor != null:
            global.activeInteractor.InteractActivate()      
    elif Input.is_action_just_pressed("interact_button"):
        # short circuit to textbox if one exists
        if global.activeInteractor != null:
            global.activeInteractor.InteractActivate()
        # give priority to active area if user pressing interact action
        elif nearest_area and not global.pauseMoveInput:
            nearest_area.InteractActivate()
        # Give secondary priority to held objects action.
        elif global.activeThrowableObject:
            global.activeThrowableObject.activate()
        # if no nearby active area, and no held object, use primary player action
        # else:
        #     player.tryBroom()

    if has_done_fallthrough_object_collision:
        if fallthrough_collision_area and fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionActivate"):
            fallthrough_collision_area.get_node("..").fallthroughCollisionActivate()
    else:
        player.should_do_fallthrough_area_collision = false
