extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_activated = false
onready var NPC4 = get_node("../NPC4") if has_node("../NPC4") else null
func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  if NPC4 != null:
    NPC4.glitchOut()
  has_activated = true
