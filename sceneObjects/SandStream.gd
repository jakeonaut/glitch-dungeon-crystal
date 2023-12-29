extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  pass

func _process(_delta):
  pass

func isActive():
  return true

func passiveActivate(_delta, is_player):
  if not is_player or level.player.truly_on_ground:
    return
  var value = -1
  if level.player.lv.y > 0:
    value = level.player.lv.y / 1.1
  level.player.lv.y = value
  level.player.vv = value
  level.player.linear_velocity.y = value
  level.player.on_ground = true
  level.player.was_just_on_ground_timer = 0
  var aa = level.player.aniPlayer.assigned_animation
  if aa != "jumpSquat" and aa != "sinkInSand" and aa != "sweepFloor":
    level.player.aniPlayer.play("sinkInSand", -1, 1)

func justStopPassiveActivate():
  level.player.pauseAnimation = false
    
