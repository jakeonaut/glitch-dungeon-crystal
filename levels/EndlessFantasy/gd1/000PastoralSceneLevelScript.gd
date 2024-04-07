extends "../../../scripts/levelScript.gd"

onready var NPC5 = get_node("NPC5") if has_node("NPC5") else null
onready var NPC7 = get_node("NPC7") if has_node("NPC7") else null
onready var pastoralGrannyNPC = get_node("PastoralGrannyNPC")
onready var fallenBroom = weakref(get_node("FallenBroom"))

var has_updated = false
var original_granny_text = ""
var prev_jump_button_text = null

# @override
func setUpRoomInitializationOverride():
  NPC7.floating_text = true
  NPC7.textBox.floating_text = true
  var right_button_text = global.getKeyCodeStr(global.getKeyCode("ui_right"))
  NPC7.textBox.text_final = "•up here dearie!\npress [lb]" + right_button_text + "[rb] to walk"
  NPC7.textBox.showTextbox()
  
  var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
  pastoralGrannyNPC.textBox.text_final = "•this dust just showed up!\nhow odd... dearie, could you\nsweep up with [lb]" + sweep_button_text + "[rb]?"
  pastoralGrannyNPC.textBoxContainer.bbText = pastoralGrannyNPC.textBox.text_final
  

# @override
func _process(_delta):
  # show_dither_effect = global.memory["clean_crystals"] <= 0
  # show_crt_effect = not show_dither_effect

  if global.memory.has("spellbookPage") and not has_updated:
    if fallenBroom.get_ref():
      fallenBroom.get_ref().visible = false
    if NPC5 != null:
      NPC5.textBox.hideTextbox()
    if NPC7 != null:
      NPC7.textBox.hideTextbox()
    has_updated = true
  elif global.memory["broom"] and not has_updated:
    if fallenBroom.get_ref():
      fallenBroom.get_ref().visible = false
    if NPC5 != null:
      NPC5.textBox.hideTextbox()
    has_updated = true
  elif NPC5.textBox.visible:
    var jump_button_text = global.getKeyCodeStr(global.getKeyCode("jump_button"))
    if jump_button_text != prev_jump_button_text:
      NPC5.textBox.hideTextbox()
      NPC5.textBox.text_final = ("•moo.\njump with [lb]" + str(jump_button_text) + "[rb]")
      NPC5.textBox.showTextbox()
      prev_jump_button_text = jump_button_text