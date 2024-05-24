extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_activated = false
onready var player = get_node("../Player")

onready var chicken10 = get_node("../NPC10")
onready var chicken9 = get_node("../NPC9")

onready var glitchMoleCricket = get_node("../GlitchMoleCricket")
onready var glitchMoleCricket2 = get_node("../GlitchMoleCricket2")
onready var glitchMoleCricket3 = get_node("../GlitchMoleCricket3")

onready var eventSound1 = get_node("EventSound1")

func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  has_activated = true
  player.override_press_move_right = false
  yield(get_tree().create_timer(0.99), "timeout")
  chicken9.glitchOut()
  yield(get_tree().create_timer(0.66), "timeout")
  chicken10.glitchOut()
  # yield(get_tree().create_timer(0.33), "timeout")
  # chicken4.glitchOut()
  yield(get_tree().create_timer(0.99), "timeout")

  var dig_time_limit = 2
  glitchMoleCricket.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket.startDigging()
  glitchMoleCricket2.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket2.startDigging()
  glitchMoleCricket3.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket3.startDigging()

  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
