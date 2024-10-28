extends Area

func _ready():
    set_process(true)

var prev_fallthrough_collision_area = null
var has_activated_something = false
var prev_nearest_area = null
func _process(_delta):
    var shortest_dist = 999 # zero escape saga
    var nearest_area = null
    var was_nearest_area_door = false
    var fallthrough_collision_area = null
    var player = get_node("..")
    has_activated_something = false
    var can_activate = not global.pauseMoveInput and player.on_ground

    if global.hasJustEnteredRoom or global.isEnteringRoom or global.isPauseMenuOpen:
        return

    # allow interaction with the textbox, but skip it if no textbox
    if (global.pauseGame or global.pauseMoveInput) and global.activeInteractor == null:
        return


    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("fallthrough"):
            var fallthroughParent = area.get_node("..")
            if Input.is_action_pressed("ui_down"):
                continue
            if fallthroughParent.has_method("isFallthroughCollisionActive") and not fallthroughParent.isFallthroughCollisionActive():
                continue
            if player.glitch_form == global.GlitchForm.FLOOR and player.on_ground and (prev_fallthrough_collision_area == null or not prev_fallthrough_collision_area.get_ref()):
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

    if nearest_area != null and not was_nearest_area_door:
        var player_x = player.global_transform.origin.x
        var player_flip_h = player.mySprite.flip_h
        var area_x = nearest_area.get_node("..").global_transform.origin.x
        var is_player_facing_area = (player_x < area_x and not player_flip_h) or \
                                    (player_x > area_x and player_flip_h) or \
                                    (player_x - 1 < area_x and player_x + 1 > area_x)
        can_activate = can_activate and is_player_facing_area

    if global.activeInteractor == null and Input.is_action_just_pressed("ui_up"):
        # short circuit to textbox if one exists
        if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
            if global.activeInteractor.is_in_group("door_textbox") and nearest_area != null and nearest_area.is_in_group("door"):
                nearest_area.InteractActivate()
            elif nearest_area and not global.pauseMoveInput and nearest_area.is_in_group("door"):
                nearest_area.InteractActivate() 
            # if global.activeInteractor != null and is_instance_valid(global.activeInteractor): # need to recheck cuz the above line might have cleared
            #     global.activeInteractor.InteractActivate()
        # give priority to active area if user pressing interact action
        elif nearest_area and not global.pauseMoveInput and nearest_area.is_in_group("door"):
            nearest_area.InteractActivate()
    if Input.is_action_just_pressed("sub_action_button"):
        # var activated_something = false
        if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
            global.activeInteractor.InteractActivate()
    # no.
    #     # give priority to active area if user pressing interact action
    #     elif nearest_area and can_activate and not nearest_area.is_in_group("door"):
    #         if fallthrough_collision_area == null or fallthrough_collision_area.get_node("..") != nearest_area.get_node(".."):
    #             activated_something = nearest_area.InteractActivate()
            
    #     if activated_something and player.summonedBroom != null:
    #         player.broomStop()
    #         has_activated_something = true
    #     # Give secondary priority to held objects action.
    #     # elif global.activeThrowableObject:
    #     #     global.activeThrowableObject.activate(true)
    #     # if no nearby active area, and no held object, use primary player action
    #     # else:
    #     #     player.tryBroom()
    if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
        if (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")) or Input.is_action_just_pressed("ui_start"):
            if Input.is_action_just_pressed("ui_start"):
                global.activeInteractor.selectedYesNoOption = false
            var activatedSomething = global.activeInteractor.InteractActivate()
            if activatedSomething and player.summonedBroom != null:
                player.broomStop()
                has_activated_something = true
    elif global.activeInteractor == null and nearest_area != null and nearest_area.get_node("..").has_method("tryShowInteractPrompt") and can_activate:
        if fallthrough_collision_area == null or fallthrough_collision_area.get_node("..") != nearest_area.get_node(".."):
            nearest_area.get_node("..").tryShowInteractPrompt(true)

    postProcessFallthroughCollisionArea(fallthrough_collision_area)
    if prev_nearest_area != null and prev_nearest_area.get_ref() and (nearest_area != prev_nearest_area.get_ref() or not can_activate) and prev_nearest_area.get_ref().get_node("..").has_method("tryHideActiveInteractPrompt"):
        prev_nearest_area.get_ref().get_node("..").tryHideActiveInteractPrompt()
    prev_nearest_area = weakref(nearest_area)

func postProcessFallthroughCollisionArea(fallthrough_collision_area):
    var player = get_node("..")
    if fallthrough_collision_area != null:
        if fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionActivate"):
            fallthrough_collision_area.get_node("..").fallthroughCollisionActivate(player)
    else:
        player.should_do_fallthrough_area_collision = false

    prev_fallthrough_collision_area = weakref(fallthrough_collision_area)
