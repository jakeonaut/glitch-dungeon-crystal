extends TextureRect

var dialogFont = preload("res://dialogBodyFontTheme.tres")
var promptFont = preload("res://levels/common/UITheme_real.tres")
onready var textNode = get_node("ScrollContainer/Text")
onready var dialogStartSound = get_node("DialogStartSound")
onready var dialogSound = get_node("DialogSound")
onready var nextDialogSound = get_node("NextDialogSound")
onready var abortSound = get_node("AbortSound")
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
var is_fast_text = false

var showYesNoOptions = false
onready var yesButton = get_node("YesButton")
onready var yesButtonCursor = get_node("YesButton/CursorSprite")
onready var yesButtonText = get_node("YesButton/TextPrompt")
onready var noButton = get_node("NoButton")
onready var noButtonCursor = get_node("NoButton/CursorSprite")
onready var noButtonText = get_node("NoButton/TextPrompt")
var selectedYesNoOption = true
onready var nextPrompt = get_node("NextPrompt")
onready var endPrompt = get_node("EndPrompt")
onready var textPrompt = get_node("TextPrompt")
var nextPrompt_wiggle_timer = 0
var nextPrompt_wiggle_time_limit = 20
var nextPrompt_wiggled_up = false

onready var textContainer = get_node("..")
onready var textboxParent = weakref(get_node("../.."))
onready var textboxCameraTarget = weakref(get_node("../../TextBoxCameraTarget")) if has_node("../../TextBoxCameraTarget") else weakref(get_node("../.."))
onready var portrait = get_node("PortraitColor")

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var am_i_in_ui_layer = false
var is_immediate = false

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
  self.hide()
  set_process(true)
  
  # text_final = textNode.get_bbcode_text() # this is better set by TextContainer.gd
  top_margin_start = self.margin_top
  left_margin_start = self.margin_left
  bot_margin_start = self.margin_bottom
  right_margin_start = self.margin_right
  nextPrompt.visible = false
  endPrompt.visible = false

var bg_texture = null
func tinify():
  if self.texture != null:
    bg_texture = self.texture
  self.texture = null
  textNode.rect_clip_content = false
  # get_node("Portrait").visible = false
  get_node("ColorRect").visible = false
  is_tiny = true
  if floating_text:
    showTextbox()

func untinify():
  is_tiny = false
  self.texture = bg_texture
  textNode.rect_clip_content = true
  # get_node("Portrait").visible = true
  get_node("ColorRect").visible = true
  setTextBoxPosition()

func setPosition():
  var factor = 0.5

  # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
  if textboxParent.get_ref():
    target_origin = textboxParent.get_ref().global_transform.origin
  getGameCamera().respectLevelTilesEdges()
  var target_pos = getGameCamera().unproject_position(target_origin)
  self.rect_position.x = factor * target_pos.x - 50 - adjusted_tiny_x_pos
  self.rect_position.y = factor * target_pos.y - 50 - adjusted_tiny_y_pos

func setTextBoxPosition():
  if not is_tiny:
    self.margin_top = top_margin_start
    self.margin_left = left_margin_start
    self.margin_bottom = bot_margin_start
    self.margin_right = right_margin_start

func _process(delta):
  if global.activeInteractor == self and not self.visible:
    global.activeInteractor = null

  portrait.visible = false # not is_tiny
  if is_interact_prompt and not textboxParent.get_ref():
    self.hide()
    return

  textPrompt.visible = not floating_text and (isWaitingForEndPrompt() or isWaitingForNextPrompt()) and not is_tiny
  if textPrompt.visible:
    var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
    textPrompt.bbcode_text = "[center][lb]" + sweep_button_text + "[rb][/center]"
  if text_final == "•": text_final = ""
  delta = delta * global.time_dilation_multiplier

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
    setPosition()

  # TODO(jaketrower): This logic could probably be simplified with a FSM, or at least broken into functions
  if visible:
    if not floating_text:
      tryToHide(delta)
      
    if isWaitingForEndPrompt():
      if showYesNoOptions and not is_interact_prompt:
        if Input.is_action_just_pressed("ui_left"):
          selectedYesNoOption = true
        elif Input.is_action_just_pressed("ui_right"):
          selectedYesNoOption = false
        yesButton.visible = true
        noButton.visible = true
        yesButtonCursor.visible = selectedYesNoOption
        noButtonCursor.visible = not selectedYesNoOption
        if selectedYesNoOption:
          yesButtonText.bbcode_text = "[center][wave]yes[/wave][/center]"
          noButtonText.bbcode_text = "[center]no.[/center]"
        else:
          yesButtonText.bbcode_text = "[center]yes[/center]"
          noButtonText.bbcode_text = "[center][wave]no.[/wave][/center]"
      else:
        yesButton.visible = false
        noButton.visible = false

      if textboxParent.get_ref():
        textboxParent.get_ref().setGlobalMemoryOfHasSpoken()
      if not endPrompt.visible and abortSound.has_method("preActivateScript") and not has_preactivated:
        abortSound.preActivateScript()
        has_preactivated = true
      endPrompt.visible = not is_tiny and not floating_text
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
func showInteractPrompt():
  if global.activeInteractor == self:
    return
    
  var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
  if not is_interact_prompt:
    textNode.bbcode_text = "[lb]" + sweep_button_text + "[rb]"
    tinify()
    is_interact_prompt = true
    self.theme = promptFont

  self.show()
  textNode.visible_characters = -1
  resetTinyColorRect()
  adjusted_tiny_x_pos = -25
  adjusted_tiny_y_pos = 10
  setPosition()

func hideInteractPrompt():
  if is_interact_prompt:
    is_interact_prompt = false
    self.hide()
    self.theme = dialogFont
      
var tindex = -1
func showTextbox():
  selectedYesNoOption = true
  dialogStartSound.play()
  dialogStartSound.activateScript()
  # if text_final.find("•") == -1 and not text_final == "":
  #   text_final = "•" + text_final
  textNode.visible_characters = 0

  textNode.scroll_to_line(0)
  textNode.bbcode_text = text_final
  tindex = -1
  stripped_text = global.strip_bbcode(textNode.bbcode_text)

  if not floating_text and not am_i_in_ui_layer and level.uiLayer != null:
    textContainer.remove_child(self)
    level.uiLayer.textBoxes.add_child(self)
    am_i_in_ui_layer = true

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
  self.show()
  dialogSound.activateScript()
  
  if not floating_text:
    resetPrompts()
    
func hideTextbox():
  yesButton.visible = false
  noButton.visible = false
  has_preactivated = false
  self.hide()
  if textboxParent.get_ref():
    textboxParent.get_ref().setGlobalMemoryOfHasSpoken(true)
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
    
func InteractActivate(_is_player=true):
  return interact()
    
func interact():
  if text_final == "":
    return false
  if !visible and dialogSound.isActive():
    print("show!")
    showTextbox()
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
      nextDialogSound.play()
      ui_should_continue = true
      nextPrompt.visible = false
      stupid_newline_difference_variable += 3
      num_newlines = 0
      resetTinyColorRect()
      adjusted_tiny_y_pos += 35
    else:
      nextDialogSound.play()
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
    nextPrompt.position = Vector2(last_line_width + 160, total_height + 20)
    endPrompt.position = nextPrompt.position

func resetTinyColorRect():
  tinyColorRect.margin_right = 135
  tinyColorRect.margin_bottom = 20
  adjusted_tiny_x_pos = 0
  adjusted_tiny_y_pos = 0
