extends Area


func _ready():
    set_process(true)

func _process(delta):
    var shortest_dist = 999 # zero escape saga
    var nearest_area = null
    var shortest_passive_dist = 999
    var nearest_passive_area = null

    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.has_method("isActive") and area.isActive():
            var dist = area.global_transform.origin.distance_to(global_transform.origin)
            # always interact with passive interaction areas
            if area.has_method("PassiveInteractActivate"):
                area.PassiveInteractActivate(delta)
            
            if area.has_method("InteractActivate"):
                if dist < shortest_dist:
                    shortest_dist = dist
                    nearest_area = area

    if Input.is_action_just_pressed("ui_interact"):
        # can short circuit and just immediately interact with "activeInteractor" AKA TextBox if 
        # I am already looking at one (e.g. if global.activeInteractor exists   )
        if global.activeInteractor != null:
            global.activeInteractor.InteractActivate()
        # give priority to active area if user pressing interact action
        elif nearest_area:
            nearest_area.InteractActivate()
        # Give secondary priority to held objects action.
        elif global.activeThrowableObject:
            global.activeThrowableObject.activate()
        # if no nearby active area, and no held object, use primary player action
        else:
            get_node("..").tryBroom()