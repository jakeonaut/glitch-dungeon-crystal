extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_activated = false
onready var grandmaNpc = get_node("../PastoralGrannyNPC")
func passiveActivate(_delta, _is_player):
  if global.memory.has("spellbookPage"):
    has_activated = true
  if has_activated:
    return
  grandmaNpc.textBox.hideTextbox()
  grandmaNpc.textBox.text_final = "•thank you dear.."
  # grandmaNpc.textBox.tinify()
  grandmaNpc.textBox.showTextbox()
  global.activeInteractor = grandmaNpc.textBox
  has_activated = true
