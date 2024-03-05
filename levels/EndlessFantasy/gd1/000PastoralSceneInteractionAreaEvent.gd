extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive(debug=false):
  return true

var has_activated = false
onready var npc7 = get_node("../NPC7")
onready var NPC5 = get_node("../NPC5") if has_node("../NPC5") else null
onready var pastoralGrannyNPC = get_node("../PastoralGrannyNPC") if has_node("../PastoralGrannyNPC") else null
onready var chickenNPC = get_node("../ChickenNPC") if has_node("../ChickenNPC") else null
func passiveActivate(_delta, _is_player):
  if global.memory.has("spellbookPage"):
    has_activated = true
  if has_activated:
    return
  npc7.textBox.hideTextbox()
  if chickenNPC != null:
    chickenNPC.glitchOut()
  if pastoralGrannyNPC:
    pastoralGrannyNPC.is_active = true
  has_activated = true
  if NPC5:
    NPC5.textBox.showTextbox()
