extends TextureRect

onready var textNode = get_node("Text")
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
var adjusted_tiny_y_pos = 0
var adjusted_tiny_x_pos = 0
var target_origin = Vector3(0, 0, 0)
var is_fast_text = false

onready var nextPrompt = get_node("NextPrompt")
onready var endPrompt = get_node("EndPrompt")
var nextPrompt_wiggle_timer = 0
var nextPrompt_wiggle_time_limit = 20
var nextPrompt_wiggled_up = false

onready var textContainer = get_node("..")
onready var textboxParent = weakref(get_node("../.."))
onready var textboxCameraTarget = weakref(get_node("../../TextBoxCameraTarget")) if has_node("../../TextBoxCameraTarget") else weakref(get_node("../.."))

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
  bot_margin_start = self.margin_bottom
  nextPrompt.visible = false
  endPrompt.visible = false
  
func tinify():
  self.texture = null
  # get_node("Portrait").visible = false
  get_node("ColorRect").visible = false
  is_tiny = true
  hide_textbox_time_limit = 5
  if floating_text:
    showTextbox()

func setPosition():
  var factor = 0.5

  # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
  if textboxParent.get_ref():
    target_origin = textboxParent.get_ref().global_transform.origin
  getGameCamera().respectLevelTilesEdges()
  var target_pos = getGameCamera().unproject_position(target_origin)
  self.rect_position.x = factor * target_pos.x - 50 - adjusted_tiny_x_pos
  self.rect_position.y = factor * target_pos.y - 75 - adjusted_tiny_y_pos

func setTextBoxPosition():
  if not is_tiny:
    if getGameCamera().isNearBottom() and (getGameCamera().isInitialTargetNearBottom() or can_camera_zoom):
      self.margin_top = 60
      self.margin_bottom = self.margin_top + (bot_margin_start - top_margin_start)
    else:
      self.margin_top = top_margin_start
      self.margin_bottom = bot_margin_start
  
var important_unpause_timer = 0
var important_unpause_time_limit = 20
func _process(delta):
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
      if textboxParent.get_ref():
        textboxParent.get_ref().setGlobalMemoryOfHasSpoken()
      if not endPrompt.visible and abortSound.has_method("preActivateScript") and not has_preactivated:
        abortSound.preActivateScript()
        has_preactivated = true
      endPrompt.visible = not is_tiny and not floating_text
      has_been_shown = true
      if is_important and global.pauseGame:
        important_unpause_timer += (delta * 22)
        if important_unpause_timer >= important_unpause_time_limit:
          is_important = false
          global.pauseGame = false
      is_really_important = false
      
    elif isWaitingForNextPrompt():
      nextPrompt.visible = not is_tiny and not floating_text

    if (not isWaitingForNextPrompt() and not isWaitingForEndPrompt()) or ui_should_continue:
      text_timer += (delta*22)
      var time_limit = text_time_limit
      if textNode.visible_characters >= len(stripped_text):
        pass
      elif stripped_text[textNode.visible_characters - 1] == ",":
        time_limit *= 10
      elif stripped_text[textNode.visible_characters - 1] == ".":
        time_limit *= 20

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
        # print(num_newlines)
        if num_newlines < 3 and now_were_scrolling:
          # print("scroll")
          # print(currently_scrolled_line + 1)
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
    else:
      promptSprite.transform.origin.y += 5
    nextPrompt_wiggled_up = not nextPrompt_wiggled_up
    nextPrompt_wiggle_timer = 0
    
func resetPrompts():
  nextPrompt.visible = false
  endPrompt.visible = false
  nextPrompt_wiggle_timer = 0
  nextPrompt_wiggled_up = false
      
var tindex = -1
func showTextbox():
  # if text_final.find("•") == -1 and not text_final == "":
  #   text_final = "•" + text_final
  textNode.visible_characters = 0
  textNode.bbcode_text = text_final
  tindex = -1
  stripped_text = global.strip_bbcode(textNode.bbcode_text)

  if not floating_text and not am_i_in_ui_layer and level.uiLayer != null:
    textContainer.remove_child(self)
    level.uiLayer.add_child(self)
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
  dialogStartSound.play()
  # whateva
  dialogStartSound.activateScript()
  dialogSound.activateScript()
  
  if not floating_text:
    resetPrompts()
    
func hideTextbox():
  has_preactivated = false
  self.hide()
  if textboxParent.get_ref():
    textboxParent.get_ref().setGlobalMemoryOfHasSpoken(true)
  if isWaitingForEndPrompt():
    abortSound.play()
    abortSound.activateScript()
  else:
    abortSound.play()
    if abortSound.has_method("cutOffEarlyActivateScript"):
      abortSound.cutOffEarlyActivateScript()
  if global.activeInteractor == self:
    global.activeInteractor = null
  if is_important:
    is_important = false
    global.pauseGame = false
      
func tryToHide(delta):
  if not focus_me:
    hide_textbox_timer += (delta*22)
    if hide_textbox_timer >= hide_textbox_time_limit:
      hideTextbox()
      hide_textbox_timer = 0
    
func InteractActivate(_is_player=true):
  interact()
    
func interact():
  if text_final == "":
    return
  # print("visible: " + str(visible) + ", isActive: " + str(dialogSound.isActive()))
  if !visible and dialogSound.isActive():
    showTextbox()
    global.activeInteractor = self
    return

  # print("global activeInteractor: ", global.activeInteractor)
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

func passiveInteract(_delta):
  if text_final == "":
    return
  if !visible and dialogSound.isActive() and (global.activeInteractor == null or (is_instance_valid(global.activeInteractor) and global.activeInteractor == self)):
    if (is_tiny or is_really_important) and not has_been_shown:
      global.activeInteractor = self
      showTextbox()

  if global.activeInteractor == self and not focus_me:
    focus_me = true
    hide_textbox_timer = 0
        
func stopInteract():
  if not is_important and isWaitingForNextPrompt() or isWaitingForEndPrompt():
    focus_me = false
  hideTextbox()
  
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
