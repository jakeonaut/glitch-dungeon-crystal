extends TextureRect

var dialogFont = preload("res://dialogBodyFontTheme.tres")
var promptFont = preload("res://levels/common/UITheme_real.tres")
onready var textNode = get_node("Container/ScrollContainer/Text")
onready var textSprite = get_node("Container/ScrollContainer/TextSprite") if has_node("Container/ScrollContainer/TextSprite") else null
onready var container = get_node("Container")
onready var dialogStartSound = get_node("DialogStartSound")
onready var dialogSound = get_node("DialogSound")
onready var nextDialogSound = get_node("NextDialogSound")
onready var abortSound = get_node("AbortSound")
onready var broomSelectSound = get_node("BroomSelectSound")
onready var broomConfirmSound = get_node("BroomConfirmSound")
export(NodePath) var nextTextBoxPath = NodePath("")

var text_timer = 0
var text_time_limit = 0.5
var text_final = ''
var stripped_text = ''

var ui_should_continue = false

var hide_textbox_timer = 0
var hide_textbox_time_limit = 20

var has_been_shown = false
var has_preactivated = false
var focus_me = false
var floating_text = false
export var can_camera_zoom = true

var is_important = false
var is_really_important = false
var is_tiny = false

onready var tinyColorRect = get_node("TinyColorRect")
var top_margin_start = 0
var bot_margin_start = 0
var left_margin_start = 0
var right_margin_start = 0
var adjusted_tiny_y_pos = 0
var adjusted_tiny_x_pos = 0
var target_origin = Vector3(0, 0, 0)
var override_target_origin = null
var is_fast_text = false

var showYesNoOptions = false
onready var yesButton = get_node("Container/YesButton")
onready var yesButtonCursor = get_node("Container/YesButton/CursorSprite")
onready var yesButtonText = get_node("Container/YesButton/TextPrompt")
onready var noButton = get_node("Container/NoButton")
onready var noButtonCursor = get_node("Container/NoButton/CursorSprite")
onready var noButtonText = get_node("Container/NoButton/TextPrompt")
var selectedYesNoOption = true
onready var nextPrompt = get_node("NextPrompt")
onready var endPrompt = get_node("EndPrompt")
onready var textPrompt = get_node("Container/TextPrompt")
var nextPrompt_wiggle_timer = 0
var nextPrompt_wiggle_time_limit = 20
var nextPrompt_wiggled_up = false

onready var textContainer = get_node("..")
onready var textboxParent = weakref(get_node("../.."))
onready var textboxCameraTarget = weakref(get_node("../../TextBoxCameraTarget")) if has_node("../../TextBoxCameraTarget") else weakref(get_node("../.."))
onready var portraitContainer = get_node("PortraitColor")
onready var portraitSprite = get_node("PortraitColor/ColorRect2/ColorRect4/Portrait")

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var am_i_in_ui_layer = false
var is_immediate = false
var was_smacked = false

# used with global.activeInteractor
var am_i_a_textbox = true

var gameCamera = null
func getGameCamera():
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera
  
var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

func _ready():
  hideMe()
  set_process(true)
  
  # text_final = textNode.get_bbcode_text() # this is better set by TextContainer.gd
  top_margin_start = self.margin_top
  left_margin_start = self.margin_left
  bot_margin_start = self.margin_bottom
  right_margin_start = self.margin_right
  yield(get_tree().create_timer(0.1), "timeout")
  nextPrompt.visible = false
  endPrompt.visible = false
  if textSprite: textSprite.visible = false
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  tryMoveToUiLayer()
  originalDialogStartSoundPitch = dialogStartSound.pitch_scale
  originalDialogStartSoundVolume = dialogStartSound.volume_db

func tryMoveToUiLayer():
  if not floating_text and not am_i_in_ui_layer and level.uiLayer != null:
    textContainer.remove_child(self)
    level.uiLayer.textBoxes.add_child(self)
    if level.should_offset_ui:
      textContainer.offset = Vector2(global.OFFSET_X, global.OFFSET_Y)
    else:
      textContainer.offset = Vector2(0, 0)
    am_i_in_ui_layer = true

var bg_texture = null
func tinify():
  if self.texture != null:
    bg_texture = self.texture
  self.texture = null
  textNode.rect_clip_content = false
  portraitContainer.visible = false
  get_node("ColorRect").visible = false
  is_tiny = true
  if floating_text:
    showTextbox()

func untinify():
  is_tiny = false
  self.texture = bg_texture
  textNode.rect_clip_content = true
  portraitContainer.visible = false # true
  get_node("ColorRect").visible = true
  setTextBoxPosition()

var interact_prompt_offset = 0
func setTinyPosition():
  var factor = 0.4

  # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
  if override_target_origin != null:
    target_origin = override_target_origin
  elif textboxParent.get_ref():
    target_origin = textboxParent.get_ref().global_transform.origin
  getGameCamera().respectLevelTilesEdges()
  var target_pos = getGameCamera().unproject_position(target_origin)
  self.rect_position.x = factor * target_pos.x - 50 - adjusted_tiny_x_pos
  self.rect_position.y = factor * target_pos.y - 50 - adjusted_tiny_y_pos + interact_prompt_offset

  var m = 0.05 # 2.5
  container.rect_position.x = self.rect_position.x * m
  container.rect_position.y = self.rect_position.y * m + interact_prompt_offset

func setTextBoxPosition():
  if not is_tiny:
    self.rect_position.x = 20
    self.rect_position.y = 280
    self.rect_size.x = 467
    self.rect_size.y = 104
    
    var player_camera_pos = getGameCamera().unproject_position(level.player.global_transform.origin)
    if player_camera_pos.y > 600:
      self.rect_position.y = 30
    
    var m = 2.5
    container.rect_position.x = 0# self.rect_position.x * m
    container.rect_position.y = 0# self.rect_position.y * m
    container.rect_size.x = self.rect_size.x * m
    container.rect_size.y = self.rect_size.x * m

func _process(delta):
  if global.activeInteractor == self and not self.visible:
    global.activeInteractor = null

  portraitContainer.visible = false # not is_interact_prompt and not is_tiny
  if is_interact_prompt and not textboxParent.get_ref():
    hideMe()
    portraitContainer.visible = false
    return
  if not textboxParent.get_ref() and not self.visible and not global.activeInteractor == self:
    queue_free()

  textPrompt.visible = not floating_text and (isWaitingForEndPrompt() or isWaitingForNextPrompt()) and not is_tiny
  if global.isPauseMenuOpen:
    return
  if textPrompt.visible:
    var sweep_button_text = global.getLargeInputText("talk_button")
    textPrompt.bbcode_text = "[center][wave]" + sweep_button_text + "[/wave][/center]"
  if text_final == "•": text_final = ""
  # delta = delta * global.time_dilation_multiplier # i'm exempt

  if textboxParent.get_ref() and textboxParent.get_ref().is_active:
    textboxParent.get_ref().idleTalk()

  if floating_text:
    nextPrompt.visible = false
    endPrompt.visible = false
  else:
    if endPrompt.visible:
      wigglePrompt(delta, endPrompt)
    elif nextPrompt.visible:
      wigglePrompt(delta, nextPrompt)

  if is_tiny:
    if not is_interact_prompt:
      adjusted_tiny_x_pos = 50
      adjusted_tiny_y_pos = 20
    setTinyPosition()

  # TODO(jaketrower): This logic could probably be simplified with a FSM, or at least broken into functions
  if visible:
    if not floating_text:
      tryToHide(delta)
      
    if isWaitingForEndPrompt():
      if showYesNoOptions and not is_interact_prompt:
        if getPlayer().rawPressingMoveLeft():
          if not selectedYesNoOption: broomSelectSound.play()
          selectedYesNoOption = true
        elif getPlayer().rawPressingMoveRight():
          if selectedYesNoOption: broomSelectSound.play()
          selectedYesNoOption = false
        yesButton.visible = true
        noButton.visible = true
        yesButtonCursor.visible = selectedYesNoOption
        noButtonCursor.visible = not selectedYesNoOption
        if selectedYesNoOption:
          yesButtonText.bbcode_text = "[wave]" + tr("UI.Yes") + "[/wave]"
          noButtonText.bbcode_text = "" + tr("UI.No") + ""
        else:
          yesButtonText.bbcode_text = "" + tr("UI.Yes") + ""
          noButtonText.bbcode_text = "[wave]" + tr("UI.No") + "[/wave]"
      else:
        yesButton.visible = false
        noButton.visible = false

      # its set when hiding the textbox, which is more reliable
      # if textboxParent.get_ref() and not is_interact_prompt:
      #   textboxParent.get_ref().setGlobalMemoryOfHasSpoken()
      if abortSound.has_method("preActivateScript") and not has_preactivated and not is_interact_prompt:
        abortSound.preActivateScript()
        has_preactivated = true
      endPrompt.visible = not is_tiny and not floating_text
      if not is_interact_prompt:
        has_been_shown = true
        is_really_important = false
    else:
      yesButton.visible = false
      noButton.visible = false
      if isWaitingForNextPrompt():
        nextPrompt.visible = not is_tiny and not floating_text


    if (not isWaitingForNextPrompt() and not isWaitingForEndPrompt()) or ui_should_continue:
      text_timer += (delta*22)
      var time_limit = text_time_limit
      if textNode.visible_characters >= len(stripped_text):
        pass
      elif stripped_text[textNode.visible_characters - 1] == ",":
        time_limit *= 5
      elif stripped_text[textNode.visible_characters - 1] == ".":
        time_limit *= 10

      if text_timer >= time_limit and textNode.visible_characters < len(stripped_text):
        appendNextTextCharacter()
        ui_should_continue = false

func advanceToEndOfPhrase():
  while not isWaitingForNextPrompt() and not isWaitingForEndPrompt():
    appendNextTextCharacter(false)
      
var num_newlines = 0
var stupid_newline_difference_variable = 0
var currently_scrolled_line = 0
var now_were_scrolling = false
export var minDialogPitch = 0.8
export var maxDialogPitch = 1.2
func appendNextTextCharacter(play_sound = true):
  if tindex >= len(stripped_text):
    return
  if textboxParent.get_ref():
    textboxParent.get_ref().appendNextTextCharacter()
  if is_tiny:
    adjustTinyColorRect()

  if not isWaitingForNextPrompt() and not isWaitingForEndPrompt():
    resetPrompts()
    
  if play_sound:
    dialogSound.pitch_scale = rand_range(minDialogPitch, maxDialogPitch)
    dialogSound.play()
  text_timer = 0
  
  tindex += 1
  if tindex < len(stripped_text):
      if stripped_text[tindex] == "↓":
        num_newlines = 3
        textNode.scroll_to_line(currently_scrolled_line + 1)
        currently_scrolled_line += 1
      elif stripped_text[tindex] == "\n":
        num_newlines += 1
        if num_newlines < 3 and now_were_scrolling:
          textNode.scroll_to_line(currently_scrolled_line + 1)
          currently_scrolled_line += 1
      else:
        textNode.visible_characters += 1
  if isWaitingForEndPrompt():
    textNode.scroll_to_line(currently_scrolled_line + 1)
    currently_scrolled_line += 1
      
func isWaitingForNextPrompt():
  return tindex < len(stripped_text) and num_newlines == 3
  
func isWaitingForEndPrompt():
  return tindex + 1 >= len(stripped_text)

func wigglePrompt(delta, promptSprite):
  nextPrompt_wiggle_timer += (delta*22)
  if nextPrompt_wiggle_timer >= nextPrompt_wiggle_time_limit:
    if nextPrompt_wiggled_up:
      promptSprite.transform.origin.y -= 5
      textPrompt.margin_top -= 5
    else:
      promptSprite.transform.origin.y += 5
      textPrompt.margin_top += 5
    nextPrompt_wiggled_up = not nextPrompt_wiggled_up
    nextPrompt_wiggle_timer = 0
    
func resetPrompts():
  nextPrompt.visible = false
  endPrompt.visible = false
  nextPrompt_wiggle_timer = 0
  nextPrompt_wiggled_up = false

var is_interact_prompt = false
func showInteractPrompt(is_comic_alert = false): 
  if global.activeInteractor == self or global.pauseGame:
    return
    
  var sweep_button_text = global.getLargeInputText("talk_button")
  if not is_interact_prompt:
    if is_comic_alert:
      textNode.bbcode_text = "[wave]!" + sweep_button_text + "![/wave]"
    else:
      textNode.bbcode_text = "[wave]" + sweep_button_text + "[/wave]"
    tinify()
    is_interact_prompt = true
    self.theme = promptFont

  showMe()
  textNode.visible_characters = -1
  resetTinyColorRect()
  adjusted_tiny_x_pos = -25
  adjusted_tiny_y_pos = 20
  setTinyPosition()

func showMe():
  self.show()

func hideMe():
  self.hide()

func hideInteractPrompt():
  if is_interact_prompt:
    is_interact_prompt = false
    hideMe()
    self.theme = dialogFont
      
var tindex = -1
var smackedBbText = null
var needs_to_talk_normal_first = false
var has_talked_normal = false
var originalDialogStartSoundPitch = 1.0
var originalDialogStartSoundVolume = -15
func showTextbox(wasSmacked = false):
  selectedYesNoOption = false
  # TODO(jaketrower): DialogStartSound play nice with smackedBbText?
  dialogStartSound.activateScript()
  dialogStartSound.pitch_scale = originalDialogStartSoundPitch
  dialogStartSound.volume_db = originalDialogStartSoundVolume
  dialogStartSound.play()

  # if text_final.find("•") == -1 and not text_final == "":
  #   text_final = "•" + text_final
  textNode.visible_characters = 0

  textNode.scroll_to_line(0)
  if wasSmacked and smackedBbText != null and smackedBbText != "" and (not needs_to_talk_normal_first or has_talked_normal):
    if textSprite: textSprite.visible = false
    textNode.bbcode_text = tr(smackedBbText)
    showYesNoOptions = false
  else:
    has_talked_normal = true
    if textSprite: textSprite.visible = true
    textNode.bbcode_text = tr(text_final)
  tindex = -1
  stripped_text = global.strip_bbcode(tr(textNode.bbcode_text))

  tryMoveToUiLayer()

  num_newlines = 0
  stupid_newline_difference_variable = 0
  currently_scrolled_line = 0
  now_were_scrolling = false
  setTextBoxPosition()
  has_preactivated = false
  focus_me = true
  if is_important and not floating_text:
    getPlayer().unsmack()
    global.pauseGame = true
    if textboxParent.get_ref() and textboxParent.get_ref().can_move_player:
      var npcOrigin = textboxParent.get_ref().global_transform.origin
      var playerOrigin = Vector3(npcOrigin.x, npcOrigin.y, 0)
      if getPlayer().global_transform.origin.x >= npcOrigin.x:
        playerOrigin.x += 3
        getPlayer().mySprite.flip_h = true
      else:
        playerOrigin.x -= 3
        getPlayer().mySprite.flip_h = false
      getPlayer().global_transform.origin = playerOrigin
      getPlayer().on_ground = true
      getPlayer().landed()
    # maybe treat this like the Item Catch?
  # if tiny: tinyColorRect.visible = true
  text_timer = 99999
  if is_immediate or floating_text:
    textNode.visible_characters = len(stripped_text)
  resetTinyColorRect()

  textNode.get_v_scroll().value = 0
  showMe()
  dialogSound.activateScript()
  
  if not floating_text:
    resetPrompts()
    
func hideTextbox():
  if textSprite: textSprite.visible = false
  yesButton.visible = false
  noButton.visible = false
  hideMe()
  if textboxParent.get_ref():
    textboxParent.get_ref().setGlobalMemoryOfHasSpoken(true)
  if showYesNoOptions and selectedYesNoOption:
    broomConfirmSound.play()
  else:
    selectedYesNoOption = false
    abortSound.play()
  
  if abortSound.has_method("preActivateScript") and not has_preactivated:
    abortSound.preActivateScript()
    has_preactivated = true
  abortSound.activateScript()
  if not isWaitingForEndPrompt():
    if abortSound.has_method("cutOffEarlyActivateScript"):
      abortSound.cutOffEarlyActivateScript()
  if global.activeInteractor == self:
    global.activeInteractor = null
  if is_important:
    is_important = false
    global.pauseGame = false

  if level.player.physics_state == level.player.PhysicsState.OCCUPIED:
    level.player.physics_state = level.player.PhysicsState.NORMAL
    level.player.pauseAnimation = false
    level.player.pauseInput = false
      
func tryToHide(delta):
  if not focus_me and not is_interact_prompt:
    hide_textbox_timer += (delta*22)
    if hide_textbox_timer >= hide_textbox_time_limit:
      hideTextbox()
      hide_textbox_timer = 0
    
func InteractActivate(_is_player=true, _is_local_broom=false):
  return interact()
    
func interact(wasSmacked = false):
  if global.activeInteractor == null:
    was_smacked = wasSmacked

  if text_final == "" and (not was_smacked or smackedBbText == ""):
    return false
  if !visible and dialogSound.isActive():
    showTextbox(wasSmacked)
    #if not is_tiny:
    global.activeInteractor = self
    return true

  if global.activeInteractor == self:
    if isWaitingForEndPrompt():
      hideTextbox()
    elif isWaitingForNextPrompt():
      textNode.scroll_to_line(currently_scrolled_line + 1)
      currently_scrolled_line += 1
      now_were_scrolling = true
      # nextDialogSound.play()
      ui_should_continue = true
      nextPrompt.visible = false
      stupid_newline_difference_variable += 3
      num_newlines = 0
      resetTinyColorRect()
      adjusted_tiny_y_pos += 35
    else:
      # nextDialogSound.play()
      advanceToEndOfPhrase()
    return true
  return false

func passiveInteract(_delta):
  if text_final == "":
    return
  if !visible and dialogSound.isActive() and (global.activeInteractor == null or (is_instance_valid(global.activeInteractor) and global.activeInteractor == self)):
    if is_really_important and not has_been_shown:
      global.activeInteractor = self
      showTextbox()

  if global.activeInteractor == self and not focus_me:
    focus_me = true
    hide_textbox_timer = 0
        
func stopInteract():
  hideTextbox()

func tryStopInteractPassive():
  if not is_important and isWaitingForEndPrompt():
    focus_me = false
  
func adjustTinyColorRect():
  # TODO(jaketrower): nocommit
  # this needs to be updated with the new visible characters... ? num_newlines ?
  var lines = stripped_text.substr(0, tindex).split("\n", true)
  var last_char = stripped_text[tindex]
  var max_width = 0
  var last_line_width = 0
  var total_height = 0
  var font = textNode.get_font("normal_font")
  for i in lines.size():
    if i < stupid_newline_difference_variable:
      pass
    var line = lines[i]
    var width = font.get_string_size(line).x
    var height = font.get_height()
    if i < lines.size()-1 or (last_char != "\n" and last_char != "↓"):
      total_height += height
    if width > max_width:
      max_width = width
    last_line_width = width
  tinyColorRect.margin_right = max_width
  adjusted_tiny_x_pos = max_width / 2
  tinyColorRect.margin_bottom = total_height
  adjusted_tiny_y_pos = total_height
  tinyColorRect.margin_right += 12

  if not floating_text:
    nextPrompt.position = Vector2(last_line_width + 160, total_height - 20)
    endPrompt.position = nextPrompt.position

func resetTinyColorRect():
  tinyColorRect.margin_right = 135
  tinyColorRect.margin_bottom = 20
  adjusted_tiny_x_pos = 0
  adjusted_tiny_y_pos = 0
