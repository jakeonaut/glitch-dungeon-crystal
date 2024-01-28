extends "../../../scripts/levelScript.gd"

onready var grannyNPC = get_node("NPC") if has_node("NPC") else null
onready var door2 = get_node("Door2") if has_node("Door2") else null

var has_updated = false

# @override
func _process(_delta):
  if global.memory.has("spellbookPage") and not has_updated:
    if door2 != null:
      door2.path = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_1Haven.tscn"
    if grannyNPC != null:
      grannyNPC.visible = false
      grannyNPC.active = false
      grannyNPC.can_activate = false
    has_updated = true
