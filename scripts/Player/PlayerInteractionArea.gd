extends Area

func _ready():
    set_process(true)

var prev_fallthrough_collision_area = null
func _process(_delta):
    var shortest_dist = 999 # zero escape saga
    var nearest_area = null
    var was_nearest_area_door = false
    var fallthrough_collision_area = null
    var player = get_node("..")

    if global.hasJustEnteredRoom or global.isEnteringRoom:
        return

    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("fallthrough"):
            if player.glitch_form == global.GlitchForm.FLOOR and player.on_ground and prev_fallthrough_collision_area == null:
                continue
            if global.doFallthroughObjectCollision(player, area):
                # last fallthrough object overrides this value
                fallthrough_collision_area = area
            
        if area.is_in_group("playerActivation") and area.has_method("playerActivationAreaPassiveActivate"):
            area.playerActivationAreaPassiveActivate()

        if area.has_method("isActive") and area.isActive() and not area.is_in_group("noplayer"):
            var dist = area.global_transform.origin.distance_to(global_transform.origin)            
            if area.has_method("InteractActivate"):
                if (dist < shortest_dist or area.is_in_group("door")) and not was_nearest_area_door:
                    shortest_dist = dist
                    nearest_area = area
                    if area.is_in_group("door"):
                        was_nearest_area_door = true

    if global.activeInteractor != null and is_instance_valid(global.activeInteractor) and Input.is_action_just_pressed("sub_action_button"):
        global.activeInteractor.InteractActivate()
        player.can_smack_npc = false
    elif Input.is_action_just_pressed("ui_down"):
        # short circuit to textbox if one exists
        if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
            if global.activeInteractor.is_in_group("door_textbox") and nearest_area != null and nearest_area.is_in_group("door"):
                nearest_area.InteractActivate()
            if global.activeInteractor != null and is_instance_valid(global.activeInteractor): # need to recheck cuz the above line might have cleared
                global.activeInteractor.InteractActivate()
        # give priority to active area if user pressing interact action
        elif nearest_area and not global.pauseMoveInput:
            nearest_area.InteractActivate()
        # Give secondary priority to held objects action.
        elif global.activeThrowableObject:
            global.activeThrowableObject.activate(true)
        # if no nearby active area, and no held object, use primary player action
        # else:
        #     player.tryBroom()

    postProcessFallthroughCollisionArea(fallthrough_collision_area)

func postProcessFallthroughCollisionArea(fallthrough_collision_area):
    var player = get_node("..")
    if fallthrough_collision_area != null:
        if fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionActivate"):
            fallthrough_collision_area.get_node("..").fallthroughCollisionActivate(player)
    else:
        player.should_do_fallthrough_area_collision = false


    if prev_fallthrough_collision_area != null and \
       prev_fallthrough_collision_area != fallthrough_collision_area and \
       prev_fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionClear"):
        # prev_fallthrough_collision_area.get_node("..").fallthroughCollisionClear(player)
        pass
    prev_fallthrough_collision_area = fallthrough_collision_area
