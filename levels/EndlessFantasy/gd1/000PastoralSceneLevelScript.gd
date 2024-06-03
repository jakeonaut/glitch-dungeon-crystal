extends "../../../scripts/levelScript.gd"

var has_updated = false
var original_granny_text = ""
var prev_jump_button_text = null

onready var eventSound1 = get_node("EventSound1")
onready var chicken10 = get_node("NPC10")
onready var chicken9 = get_node("NPC9")
onready var chicken3 = get_node("NPC3")
onready var glitchMoleCricket = get_node("GlitchMoleCricket")
onready var glitchMoleCricket2 = get_node("GlitchMoleCricket2")
onready var glitchMoleCricket3 = get_node("GlitchMoleCricket3")
onready var babushkaCat = get_node("BabushkaCat")

# @override
func setUpRoomInitializationOverride():
  # global.pauseMoveInput = true
  global.shouldRenderAsCinematic = true
  uiLayer.statsTitleRect.visible = false
  player.pauseInput = true
  uiLayer.get_node("GlitchSprite").visible = false
  uiLayer.get_node("GlitchStatusRect").visible = false
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  player.aniPlayer.play("happyStand")

  yield(get_tree().create_timer(3.0), "timeout")
  player.override_press_move_right = true
  yield(get_tree().create_timer(0.2), "timeout")
  player.override_press_move_right = false
  # player.pauseAnimation = true
  yield(get_tree().create_timer(0.5), "timeout")
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(1.0), "timeout")
  player.override_press_move_left = true
  yield(get_tree().create_timer(0.1), "timeout")
  player.override_press_move_left = false
  yield(get_tree().create_timer(0.5), "timeout")
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(2.0), "timeout")
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  player.aniPlayer.play("happyStand")
  yield(get_tree().create_timer(4.0), "timeout")
  player.aniPlayer.play("fall")
  eventSound1.play()
  yield(get_tree().create_timer(1.0), "timeout")
  babushkaCat.mySprite.updateBaseFrame(2, 2)
  eventSound1.play()
  chicken10.glitchOut()
  yield(get_tree().create_timer(1.0), "timeout")
  chicken9.glitchOut()
  var dig_time_limit = 2
  glitchMoleCricket.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket.startDigging()
  glitchMoleCricket2.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket2.startDigging()
  glitchMoleCricket3.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket3.startDigging()

  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  chicken3.glitchOut()
  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
  # var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
  # pastoralGrannyNPC.textBox.text_final = "•some glitch dust appeared!\nhow odd... dearie, could you\nsweep up with [lb]" + sweep_button_text + "[rb]?"
  # pastoralGrannyNPC.textBoxContainer.bbText = pastoralGrannyNPC.textBox.text_final

  # NPC7.floating_text = true
  # NPC7.mySprite.pixel_size = 0.0001
  # NPC7.textBox.floating_text = true
  # var right_button_text = global.getKeyCodeStr(global.getKeyCode("ui_right"))
  # NPC7.textBox.text_final = "*meow!\n•up here dearie!\npress [lb]" + right_button_text + "[rb] to walk"
  # NPC7.textBox.showTextbox()
  

# @override
func _process(_delta):
  pass
  # show_dither_effect = global.memory["clean_crystals"] <= 0
  # show_crt_effect = not show_dither_effect

  # if global.memory.has("spellbookPage") and not has_updated:
  #   if fallenBroom.get_ref():
  #     fallenBroom.get_ref().visible = false
  #   if NPC5 != null:
  #     NPC5.textBox.hideTextbox()
  #   if NPC7 != null:
  #     NPC7.textBox.hideTextbox()
  #   has_updated = true
  # elif global.memory["broom"] and not has_updated:
  #   if fallenBroom.get_ref():
  #     fallenBroom.get_ref().visible = false
  #   if NPC5 != null:
  #     NPC5.textBox.hideTextbox()
  #   has_updated = true
  # elif NPC5.textBox.visible:
  #   var jump_button_text = global.getKeyCodeStr(global.getKeyCode("jump_button"))
  #   if jump_button_text != prev_jump_button_text:
  #     NPC5.textBox.hideTextbox()
  #     NPC5.textBox.text_final = ("•moo.\njump with [lb]" + str(jump_button_text) + "[rb]")
  #     NPC5.textBox.showTextbox()
  #     prev_jump_button_text = jump_button_text
