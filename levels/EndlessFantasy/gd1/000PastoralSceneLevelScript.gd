extends "../../../scripts/levelScript.gd"

onready var NPC5 = get_node("NPC5") if has_node("NPC5") else null
onready var npc7 = get_node("NPC7") if has_node("NPC7") else null
onready var fallenBroom = weakref(get_node("FallenBroom"))

var has_updated = false
var original_granny_text = ""
var prev_jump_button_text = ""

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
  elif NPC5.textBox.visible:
    var jump_button_text = OS.get_scancode_string(global.getKeyCode("jump_button"))
    if jump_button_text != prev_jump_button_text:
      NPC5.textBox.text_final = "•moo..\n(jump with " + jump_button_text + ")"
      NPC5.textBox.hideTextbox()
      NPC5.textBox.showTextbox()
      prev_jump_button_text = jump_button_text
