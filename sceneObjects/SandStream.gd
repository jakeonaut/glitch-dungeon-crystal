extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  pass

func _process(_delta):
  pass

func isActive(_debug=false):
  return true

func passiveActivate(delta, is_player):
  if not is_player or level.player.truly_on_ground:
    return
  level.player.camera_target_y_pos = level.player.global_transform.origin.y
  level.player.is_touching_sandstream = true
  var value = 2
  # if level.player.pressingDown():
  #   value = 4
  # if level.player.pressingJump():
  #   value = -2
  level.player.global_transform.origin.y -= (delta*value)
  # level.player.on_ground = true
  # if global.memory["zora_flippers"] == 0:
  level.player.pauseAnimation = true
  if level.player.transformation == level.player.TransformationState.FISHY:
    return
  var aa = level.player.aniPlayer.assigned_animation
  if aa != "jumpSquat" and aa != "sinkInSand" and aa != "sweepFloor" and not "broom" in aa:
    level.player.aniPlayer.play("sinkInSand", -1, 1)

func justStopPassiveActivate():
  # TODO(jaketrower): dangerous?!
  level.player.is_touching_sandstream = false
  level.player.pauseAnimation = false
  level.player.aniPlayer.stop()
  level.player.aniPlayer.clear_queue()
  level.player.aniPlayer.play("walk")
    
