extends Area

func _ready():
    set_process(true)

func _process(delta):
    var shortest_dist = 999 # zero escape saga
    var nearest_area = null

    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("fallthrough"):
            doFallthroughObjectCollision(area)
            
        if area.has_method("playerActivationAreaPassiveActivate"):
            area.playerActivationAreaPassiveActivate()
        elif area.get_parent().has_method("playerActivationAreaPassiveActivate"):
            area.get_parent().playerActivationAreaPassiveActivate()

        if area.has_method("isActive") and area.isActive():
            var dist = area.global_transform.origin.distance_to(global_transform.origin)            
            if area.has_method("InteractActivate"):
                if dist < shortest_dist:
                    shortest_dist = dist
                    nearest_area = area
            
    if Input.is_action_just_pressed("interact_button"):
        # short circuit to textbox if one exists
        if global.activeInteractor != null:
            global.activeInteractor.InteractActivate()
        # give priority to active area if user pressing interact action
        elif nearest_area:
            nearest_area.InteractActivate()
        # Give secondary priority to held objects action.
        elif global.activeThrowableObject:
            global.activeThrowableObject.activate()
        # if no nearby active area, and no held object, use primary player action
        # else:
        #     get_node("..").tryBroom()

func doFallthroughObjectCollision(area):
    if area.get_node("..").has_method("fallthroughCollisionActivate"):
        area.get_node("..").fallthroughCollisionActivate()

    var player = get_node("..")
    var areaShape = area.get_node("CollisionShape")
    var ax = areaShape.global_transform.origin.x
    var ay = areaShape.global_transform.origin.y
    var arb = areaShape.shape.extents.x
    var alb = -arb
    var atb = areaShape.shape.extents.y
    var abb = -atb

    var x = player.global_transform.origin.x
    var y = player.global_transform.origin.y
    var rb = player.get_node("CollisionShape").shape.radius
    var lb = -rb
    var tb = player.get_node("CollisionShape").shape.height/2
    var bb = -tb
    if get_node("..").isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb, x + rb, y + bb - 0.12
    ) and player.linear_velocity.y < 0:
        var was_on_ground = player.was_on_ground
        player.linear_velocity = player.collideWithFloor(player.linear_velocity)
        if not player.was_on_ground:
            player.landed()
        player.was_on_ground = was_on_ground
        player.global_transform.origin.y = ay + atb - bb
