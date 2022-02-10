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
	var has_done_fallthrough_object_collision = false
	var possible_game_mover = get_node("..")
	for area in areas:
		if area.is_in_group("water"):
			is_touching_water = true
		if area.is_in_group("ladder"):
			is_touching_ladder = true
		if area.is_in_group("fallthrough"):
			has_done_fallthrough_object_collision = global.doFallthroughObjectCollision(possible_game_mover, area) or has_done_fallthrough_object_collision

	if not has_done_fallthrough_object_collision and "should_do_fallthrough_area_collision" in possible_game_mover:
		possible_game_mover.should_do_fallthrough_area_collision = false
