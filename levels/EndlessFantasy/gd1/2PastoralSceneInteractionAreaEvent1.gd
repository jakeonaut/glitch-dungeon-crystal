extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_activated = false
onready var player = get_node("../Player")
func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  has_activated = true
  player.override_press_move_right = true
  player.pauseInput = true
  global.shouldRenderAsCinematic = true
