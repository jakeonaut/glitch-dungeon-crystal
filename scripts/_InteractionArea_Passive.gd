extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
var is_touching_water = false
var is_touching_waterfall = false
var touched_water_area = null
var is_touching_ladder = false
var is_touching_player_proxy = false
var was_touching_player_proxy = false
var is_touching_carcass = false
var was_touching_carcass = false
onready var parent = get_parent()
export var handlePlayerInteraction = true
export var ignore_water = false

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

func isActive(_debug=false):
    return parent.has_method("isActive") and parent.isActive()

# for use with PlayerSmallInteractionArea
func PassiveInteractActivate(delta, is_player = true):
    if parent.has_method("passiveActivate"):
        # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
        # TODO(jaketrower): Will be not true when broomerang >= 2
        parent.passiveActivate(delta, is_player)
    touchingPlayer = is_player
    if is_in_group("enemies") and not is_in_group("no_pushems") and is_player:
        getPlayer().enemyPushMe(delta, self.global_transform.origin)

# for use with GameMoverSmallInteractionArea
func OtherPassiveInteractActivate(delta, gameMover):
    if parent.has_method("otherPassiveActivate"):
        parent.otherPassiveActivate(delta, gameMover)


func PassivePassiveInteractActivate(_delta, is_player = true):
    touchingPlayer = is_player

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
    was_touching_player_proxy = is_touching_player_proxy
    was_touching_carcass = is_touching_carcass
    touchingPlayer = false

    var areas = get_overlapping_areas()
    is_touching_water = false
    is_touching_waterfall = false
    touched_water_area = null
    is_touching_ladder = false
    is_touching_player_proxy = false
    is_touching_carcass = false
    var has_done_fallthrough_object_collision = false
    var possible_game_mover = get_node("..")
    for area in areas:
        if area.get_node("..") == self.get_node(".."):
            continue
        if area.is_in_group("water") and not ignore_water:
            is_touching_water = true
            touched_water_area = area
            if area.is_in_group("waterfall"):
                is_touching_waterfall = true
        if area.is_in_group("ladder"):
            is_touching_ladder = true
        if area.is_in_group("fallthrough") and "was_fallthrough_area_collision_triggered" in possible_game_mover:
            has_done_fallthrough_object_collision = global.doFallthroughObjectCollision(possible_game_mover, area) or has_done_fallthrough_object_collision
        if isActive() and area.is_in_group("corporeal_body") and parent.has_method("touchCorporealBody"):
            parent.touchCorporealBody(area.get_node(".."))
        if area.is_in_group("player_proxy"):
            is_touching_player_proxy = true
        if area.is_in_group("carcass"):
            is_touching_carcass = true

    if not has_done_fallthrough_object_collision and "was_fallthrough_area_collision_triggered" in possible_game_mover:
        possible_game_mover.was_fallthrough_area_collision_triggered = false
