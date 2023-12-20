extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive():
  return true

var has_activated = false
onready var npc = get_node("../NPC7")
func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  npc.textBox.hideTextbox()
  has_activated = true
