extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_waterfall = false
var touched_water_area = null
var is_touching_ladder = false
onready var parent = get_parent()
export var handlePlayerInteraction = true

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

# is this cheating?
var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

func _ready():
    set_process(true)

func isActive(debug=false):
    return parent.has_method("isActive") and parent.isActive()

func PassiveInteractActivate(delta, is_player = true):
    if parent.has_method("passiveActivate"):
        # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
        parent.passiveActivate(delta, is_player)
    touchingPlayer = true
    if is_in_group("corporeal_body") and not is_in_group("no_pushems") and is_player:
        getPlayer().bodyPushMe(delta, self.global_transform.origin)

func playerActivationAreaPassiveActivate():
    if parent.has_method("playerActivationAreaPassiveActivate"):
        parent.playerActivationAreaPassiveActivate()
    touchingPlayer = true

func _process(_delta):
    if handlePlayerInteraction:
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
    is_touching_waterfall = false
    touched_water_area = null
    is_touching_ladder = false
    var has_done_fallthrough_object_collision = false
    var possible_game_mover = get_node("..")
    for area in areas:
        if area.is_in_group("water"):
            is_touching_water = true
            touched_water_area = area
            if area.is_in_group("waterfall"):
                is_touching_waterfall = true
        if area.is_in_group("ladder"):
            is_touching_ladder = true
        if area.is_in_group("fallthrough") and "should_do_fallthrough_area_collision" in possible_game_mover:
            has_done_fallthrough_object_collision = global.doFallthroughObjectCollision(possible_game_mover, area) or has_done_fallthrough_object_collision
        if isActive() and area.is_in_group("corporeal_body") and parent.has_method("touchCorporealBody"):
            parent.touchCorporealBody(area.get_node(".."))

    if not has_done_fallthrough_object_collision and "should_do_fallthrough_area_collision" in possible_game_mover:
        possible_game_mover.should_do_fallthrough_area_collision = false
