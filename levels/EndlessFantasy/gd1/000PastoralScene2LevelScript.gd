extends "../../../scripts/levelScript.gd"

onready var grannyNPC = get_node("NPC") if has_node("NPC") else null
onready var door = get_node("Door") if has_node("Door") else null
onready var door2 = get_node("Door2") if has_node("Door2") else null

onready var chick1 = get_node("NPC6") if has_node("NPC6") else null
onready var chick2 = get_node("NPC7") if has_node("NPC7") else null
onready var chick3 = get_node("NPC8") if has_node("NPC8") else null
onready var chick4 = get_node("NPC9") if has_node("NPC9") else null

var has_updated = false

# @override
func _process(_delta):
  show_dither_effect = global.memory["clean_crystals"] <= 0 and not global.memory.has("spellbookPage")
  show_crt_effect = not show_dither_effect

  if global.memory.has("spellbookPage") or global.memory["clean_crystals"] > 0:
    door.path = "res://levels/EndlessFantasy/gd1/PastoralTowerHub.tscn"
  
  if (global.memory.has("spellbookPage") or global.memory["clean_crystals"] > 0) and not has_updated:
    if door2 != null:
      door2.path = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_0.tscn"
    if grannyNPC != null:
      grannyNPC.visible = false
      grannyNPC.is_active = false
      grannyNPC.can_activate = false
      chick1.queue_free()
      chick2.queue_free()
      chick3.queue_free()
      chick4.queue_free()
    has_updated = true
