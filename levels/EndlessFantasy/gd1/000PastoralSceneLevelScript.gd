extends "../../../scripts/levelScript.gd"

onready var grannyNPC = get_node("NPC6") if has_node("NPC6") else null
onready var NPC5 = get_node("NPC5") if has_node("NPC5") else null
onready var npc7 = get_node("NPC7") if has_node("NPC7") else null
onready var fallenBroom = weakref(get_node("FallenBroom"))

var has_updated = false
var original_granny_text = ""

# @override
func setUpRoomInitializationOverride():
  original_granny_text = grannyNPC.textBox.text_final

# @override
func _process(_delta):
  show_dither_effect = global.memory["clean_crystals"] <= 0
  show_crt_effect = not show_dither_effect

  if global.memory.has("spellbookPage") and not has_updated:
    if fallenBroom.get_ref():
      fallenBroom.get_ref().visible = false
    if NPC5 != null:
      NPC5.textBox.hideTextbox()
    if npc7 != null:
      npc7.textBox.hideTextbox()
    has_updated = true
  elif global.memory["broom"] and not has_updated:
    if fallenBroom.get_ref():
      fallenBroom.get_ref().visible = false
    if NPC5 != null:
      NPC5.textBox.hideTextbox()
    has_updated = true

  if player.glitch_form == global.GlitchForm.FEATHER:
    grannyNPC.textBox.text_final = "•i'm feeling... green?\nas light as a leaf\n i hope i dont get sick.."
  elif player.glitch_form == global.GlitchForm.FLOOR:
    grannyNPC.textBox.text_final = "•i'm feeling RED!\nready to move!\nhoo ya!! oh dear me.."
  else:
    grannyNPC.textBox.text_final = original_granny_text
