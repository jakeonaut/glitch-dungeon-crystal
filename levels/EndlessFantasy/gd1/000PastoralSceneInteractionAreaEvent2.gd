extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive():
  return true

var has_activated = false
onready var grandmaNpc = get_node("../NPC6")
func passiveActivate(_delta, _is_player):
  if has_activated:
    return
  grandmaNpc.textBox.hideTextbox()
  grandmaNpc.textBox.text_final = "•thank you dear.."
  grandmaNpc.textBox.tinify()
  grandmaNpc.textBox.showTextbox()
  has_activated = true
