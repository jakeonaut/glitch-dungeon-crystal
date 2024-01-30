extends "../../../scripts/levelScript.gd"

onready var grannyNPC = get_node("NPC") if has_node("NPC") else null
onready var door2 = get_node("Door2") if has_node("Door2") else null

var has_updated = false

# @override
func _process(_delta):
  show_dither_effect = global.memory["clean_crystals"] <= 0
  show_crt_effect = not show_dither_effect
  
  if global.memory.has("spellbookPage") and not has_updated:
    if door2 != null:
      door2.path = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_0.tscn"
    if grannyNPC != null:
      grannyNPC.visible = false
      grannyNPC.is_active = false
      grannyNPC.can_activate = false
    has_updated = true
