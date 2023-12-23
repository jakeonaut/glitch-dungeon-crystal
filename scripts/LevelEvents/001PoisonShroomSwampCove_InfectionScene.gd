extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

var has_done_cutscene = false

func getInfectingMushroom():
    return level.get_node("Mushrooms/InfectingMushroom")

func getFrogToBeInfected():
    return level.get_node("FrogToBeInfected")

func isActive():
    return not has_done_cutscene

func passiveActivate(_delta, _is_player):
    if not has_done_cutscene:
        global.pauseMoveInput = true
        if not getPlayer().on_ground:
            return
            
        has_done_cutscene = true
        global.pauseGame = true
        yield(get_tree().create_timer(0.5), "timeout")
        getInfectingMushroom().wiggle()
        yield(get_tree().create_timer(1.0), "timeout")
        var frogToBeInfected = getFrogToBeInfected()
        frogToBeInfected.is_infected = true
        frogToBeInfected.walk_direction.x = -1
        yield(get_tree().create_timer(1.0), "timeout")
        global.pauseGame = false
        global.pauseMoveInput = false
