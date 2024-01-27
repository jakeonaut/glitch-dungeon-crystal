extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive():
  return true

var has_activated = false
onready var npc = get_node("../NPC7")
onready var NPC5 = get_node("../NPC5") if has_node("../NPC5") else null
func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  npc.textBox.hideTextbox()
  has_activated = true
  if NPC5:
    NPC5.textBox.showTextbox()
