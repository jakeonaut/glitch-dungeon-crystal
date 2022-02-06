extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_ladder = false
onready var parent = get_parent()

func _ready():
	set_process(true)

func isActive():
	return parent.has_method("isActive") and \
		   parent.isActive()

func PassiveInteractActivate(delta):
	if parent.has_method("passiveActivate"):
		parent.passiveActivate(delta)
	touchingPlayer = true

func playerActivationAreaPassiveActivate():
	if parent.has_method("playerActivationAreaPassiveActivate"):
		parent.playerActivationAreaPassiveActivate()
	touchingPlayer = true

func _process(delta):
	if not touchingPlayer and wasTouchingPlayer:
		if parent.has_method("justStopPassiveActivate"):
			parent.justStopPassiveActivate()
			
	if not touchingPlayer and not wasTouchingPlayer:
		if parent.has_method("stopPassiveActivate"):
			parent.stopPassiveActivate()
		
	# need to have this buffer variable because the PlayerInteractionArea
	# handles the PassiveInteractActivate method, and this can occur
	# before or after this NPC's _process event
	wasTouchingPlayer = touchingPlayer
	touchingPlayer = false

	var areas = get_overlapping_areas()
	is_touching_water = false
	is_touching_ladder = false
	for area in areas:
		if area.is_in_group("water"):
			is_touching_water = true
		if area.is_in_group("ladder"):
			is_touching_ladder = true
		if area.is_in_group("fallthrough"):
			doFallthroughObjectCollision(area)

func doFallthroughObjectCollision(area):
	if area.get_node("..").has_method("fallthroughCollisionActivate"):
		area.get_node("..").fallthroughCollisionActivate()
		
	var gameMover = get_node("..")
	var areaShape = area.get_node("CollisionShape")
	var ax = areaShape.global_transform.origin.x
	var ay = areaShape.global_transform.origin.y
	var arb = areaShape.shape.extents.x
	var alb = -arb
	var atb = areaShape.shape.extents.y
	var abb = -atb

	var x = gameMover.global_transform.origin.x
	var y = gameMover.global_transform.origin.y
	if not gameMover.has_node("CollisionShape") or not gameMover.get_node("CollisionShape").shape is CylinderShape:
		return

	var rb = gameMover.get_node("CollisionShape").shape.radius
	var lb = -rb
	var tb = gameMover.get_node("CollisionShape").shape.height/2
	var bb = -tb
	if get_node("..").isRectColliding(
		ax + alb, ay + atb, ax + arb, ay + abb,
		x + lb, y + bb, x + rb, y + bb - 0.12
	) and gameMover.linear_velocity.y < 0:
		var was_on_ground = gameMover.was_on_ground
		gameMover.linear_velocity = gameMover.collideWithFloor(gameMover.linear_velocity)
		if not gameMover.was_on_ground:
			gameMover.landed()
		gameMover.was_on_ground = was_on_ground
		gameMover.global_transform.origin.y = ay + atb - bb
