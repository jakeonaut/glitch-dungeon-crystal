extends Control

onready var popupRect = get_node("PopupRect")
onready var popupText = get_node("PopupRect/ColorRect/ColorRect/RichTextLabel")
var popupTimer = 0
var popupTimeLimit = 20
var canResetBindings = true

onready var pauseTitleText = get_node("PauseTitleText")

onready var cursorSprite = get_node("CursorSprite")
# NORMAL MENU
onready var normalMenu = get_node("NormalMenu")
onready var normalMenuText = get_node("NormalMenu/RichTextLabel")
onready var pauseMenuRect = get_node("PauseMenuRect")
onready var largerPopup = get_node("LargerPopup")

# INPUT MENU
onready var inputMenu = get_node("InputMenu")
onready var menuMoveSound = get_node("MenuMoveSound")
var glitch_death_timer = 0

var control_index = 0
var last_control_index = -1
var hasInitializedControlsConfig = false
var controlsConfig = []

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

enum PauseMenuState {
  NORMAL,
  GRAPHICS,
  SOUND,
  TOP_INPUT,
  KEYBOARD_INPUT,
  CONTROLLER_INPUT,
  QUIT_TO_MAIN,
  TEMP,
  SECRET_RITUAL,
  INVENTORY,
}
var pauseMenuState = PauseMenuState.NORMAL
var shouldUpdateMenuText = true

func _ready():
  set_process(true)

func _process(delta):
  self.visible = global.isPauseMenuOpen
  if not global.isPauseMenuOpen:
    return
    
  if not hasInitializedControlsConfig:
    initializeControlsConfig()
    hasInitializedControlsConfig = true
  if not hasInitializedControlsConfig:
    return

  if Input.is_action_just_pressed("menu_down"):
    menuMoveSound.play()
  elif Input.is_action_just_pressed("menu_up"):
    menuMoveSound.play()

  processGlitchScreen(delta)
  if pauseMenuState == PauseMenuState.NORMAL:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    processNormalLogic(delta)

  if pauseMenuState == PauseMenuState.GRAPHICS:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    colorblindPlayers.visible = true
    cursorSprite.position.x = 180
    processGraphicsLogic(delta)
  else:
    graphicsOptionIndex = 0
    colorblindPlayers.visible = false

  if pauseMenuState == PauseMenuState.SOUND:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    processSoundLogic(delta)
  else:
    soundOptionIndex = 0

  if pauseMenuState == PauseMenuState.QUIT_TO_MAIN:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    processQuitToMainLogic(delta)
  else:
    quitToMainOptionIndex = 0

  if pauseMenuState == PauseMenuState.TOP_INPUT:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    processTopInputLogic(delta)
  else:
    topInputOptionIndex = 0

  if pauseMenuState == PauseMenuState.KEYBOARD_INPUT or pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = false
    cursorSprite.position.x = 100
    inputMenu.visible = true
    processControlsLogic(delta)
    processPopupRenderLogic(delta)
  else:
    inputMenu.visible = false
    control_index = 0
    last_control_index = -1

  if pauseMenuState == PauseMenuState.SECRET_RITUAL:
    pauseMenuRect.visible = false
    largerPopup.visible = true
    normalMenu.visible = true
    cursorSprite.position.x = 180
    processSecretRitualLogic(delta)
  else:
    secretRitualOptionIndex = 0

  if cursorSprite.position.x >= 150:
    cursorSprite.scale = Vector2(4, 4)
  else:
    cursorSprite.scale = Vector2(3, 3)
  if Input.is_action_just_pressed("dev_demo_reset") and global.memory["demo_mode"] > 0:
    global.has_started_game = true
    global.has_really_started_game = true
    global.memory.erase("roomPath")
    global.resetMemory()
    global.isPauseMenuOpen = false
    global.pauseGame = false
    global.currLevelZone = null
    transition.long_fade_to("res://levels/EndlessFantasy/gd1TutorialDungeon/0_0.tscn")


var normalMenuOptions = ["resume", "Input", "Graphics", "Sound", "Quit to Main"]
var normalMenuOptionsOnMainMenu = ["resume", "Input", "Graphics", "Sound", "Quit Game"]
var normalOptionIndex = 0
func processNormalLogic(_delta):
  if global.isOnMainMenu:
    normalMenuOptions = normalMenuOptionsOnMainMenu
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(normalMenuOptions)):
      var option = normalMenuOptions[i]
      if i == normalOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    normalOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    normalOptionIndex -= 1
    shouldUpdateMenuText = true
  if normalOptionIndex < 0:
    normalOptionIndex = len(normalMenuOptions) - 1
  elif normalOptionIndex >= len(normalMenuOptions):
    normalOptionIndex = 0
  cursorSprite.position.y = 120 + (80*normalOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    pauseMenuState = PauseMenuState.TEMP
    shouldUpdateMenuText = true
    if normalOptionIndex == 0:
      yield(get_tree().create_timer(0.1), "timeout")
      global.isPauseMenuOpen = false
      global.pauseGame = false
      getPlayer().unpauseSound.play()
      level.restartMusic()
    elif normalOptionIndex == 1:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.TOP_INPUT
    elif normalOptionIndex == 2:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.GRAPHICS
    elif normalOptionIndex == 3:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.SOUND
    elif normalOptionIndex == 4:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.QUIT_TO_MAIN
  elif Input.is_action_just_pressed("menu_cancel"):
    yield(get_tree().create_timer(0.1), "timeout")
    global.isPauseMenuOpen = false
    global.pauseGame = false
    getPlayer().unpauseSound.play()
    level.restartMusic()

onready var colorblindPlayers = get_node("ColorblindPlayers")
onready var colorblindHats = get_node("ColorblindPlayers/ColorblindHats")
var graphicsOptions = ["CRT Filter", "Glitch Screen", "Color Blind", "Fullscreen"]
var graphicsOptionIndex = 0
func processGraphicsLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(graphicsOptions)):
      var option = graphicsOptions[i] + ": "
      if i == 0: option += ("ON" if global.memory["show_crt_effect"] else "OFF")
      if i == 1: option += ("ON" if global.memory["canGlitchScreen"] else "OFF")
      if i == 2: option += ("ON" if global.memory["colorblindMode"] else "OFF")
      if i == 3: option += ("ON" if OS.window_fullscreen else "OFF")

      if i == graphicsOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    graphicsOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    graphicsOptionIndex -= 1
    shouldUpdateMenuText = true
  if graphicsOptionIndex < 0:
    graphicsOptionIndex = len(graphicsOptions) - 1
  elif graphicsOptionIndex >= len(graphicsOptions):
    graphicsOptionIndex = 0
  cursorSprite.position.y = 120 + (80*graphicsOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    shouldUpdateMenuText = true
    if graphicsOptionIndex == 0:
      global.memory["show_crt_effect"] = not global.memory["show_crt_effect"]
    elif graphicsOptionIndex == 1:
      global.memory["canGlitchScreen"] = not global.memory["canGlitchScreen"]
      glitch_death_timer = 1
    elif graphicsOptionIndex == 2:
      global.memory["colorblindMode"] = not global.memory["colorblindMode"]
    elif graphicsOptionIndex == 3:
      OS.window_fullscreen = not OS.window_fullscreen
  elif Input.is_action_just_pressed("menu_cancel"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true
  colorblindHats.visible = global.memory["colorblindMode"]

func processGlitchScreen(delta):
  if glitch_death_timer != 0:
    glitch_death_timer += (delta*22)
    getPlayer().applyGlitchDeathEffects(abs(glitch_death_timer))
    if global.memory["canChangeSongPitch"]:
      musicPlayer.changeSongPitch(abs(sin((glitch_death_timer)*.05)+.02))
    level.glitchScreenEffect.visible = global.memory["canGlitchScreen"]
    if glitch_death_timer >= 40:
      musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
      level.glitchScreenEffect.visible = false
      glitch_death_timer = 0

var soundOptions = ["Play Music", "Music Glitches"] # global.memory["canChangeSongPitch"]
var soundOptionIndex = 0
func processSoundLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(soundOptions)):
      var option = soundOptions[i] + ": "
      if i == 0: option += ("OFF" if global.memory["stopAllMusic"] else "ON")
      if i == 1: option += ("ON" if global.memory["canChangeSongPitch"] else "OFF")

      if i == soundOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    soundOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    soundOptionIndex -= 1
    shouldUpdateMenuText = true
  if soundOptionIndex < 0:
    soundOptionIndex = len(soundOptions) - 1
  elif soundOptionIndex >= len(soundOptions):
    soundOptionIndex = 0
  cursorSprite.position.y = 120 + (80*soundOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    shouldUpdateMenuText = true
    if soundOptionIndex == 0:
      global.memory["stopAllMusic"] = not global.memory["stopAllMusic"]
      if global.memory["stopAllMusic"]:
        musicPlayer.stopAll()
      else:
        musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    elif soundOptionIndex == 1:
      global.memory["canChangeSongPitch"] = not global.memory["canChangeSongPitch"]
      if global.memory["canChangeSongPitch"]:
        musicPlayer.changeSongPitch(rand_range(0.8, 1.5))
      glitch_death_timer = 1
  elif Input.is_action_just_pressed("menu_cancel"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true


var quitToMainOptions = ["Yes", "cancel"]
var quitToMainOptionIndex = 0
func processQuitToMainLogic(_delta):
  if global.isOnMainMenu:
    pauseTitleText.bbcode_text = "Really quit?\n" + global.getInputText("menu_confirm") + " to confirm, " + global.getInputText("menu_cancel") + " to cancel"
  else:
    pauseTitleText.bbcode_text = "unsaved progress will be lost.\n" + global.getInputText("menu_confirm") + " to confirm, " + global.getInputText("menu_cancel") + " to cancel"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(quitToMainOptions)):
      var option = quitToMainOptions[i]
      if i == quitToMainOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    quitToMainOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    quitToMainOptionIndex -= 1
    shouldUpdateMenuText = true
  if quitToMainOptionIndex < 0:
    quitToMainOptionIndex = len(quitToMainOptions) - 1
  elif quitToMainOptionIndex >= len(quitToMainOptions):
    quitToMainOptionIndex = 0
  cursorSprite.position.y = 120 + (80*quitToMainOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    if quitToMainOptionIndex == 0:
      if global.isOnMainMenu:
        get_tree().quit()
      else:
        # dedupe (ish) with "dev_demo_reset" above
        global.has_started_game = false
        global.has_really_started_game = false
        global.resetMemory()
        global.currLevelZone = null
        transition.long_fade_to("res://levels/EndlessFantasy/gd1/000PastoralScene.tscn")
        global.isPauseMenuOpen = false
    elif quitToMainOptionIndex == 1:
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_cancel"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true

var secretRitualOptionIndex = 0
func processSecretRitualLogic(_delta):
  pauseTitleText.bbcode_text = "warp to angel statue\n" + global.getInputText("menu_confirm") + " to confirm, " + global.getInputText("menu_cancel") + " to cancel"

  var secretRitualOptions = global.getThingArrayFromAllLevelZonez("angel_statue")
  secretRitualOptions.push_back(["cancel", null])
  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(secretRitualOptions)):
      var option = secretRitualOptions[i]
      if i == secretRitualOptionIndex:
        text += "[wave]" + str(option[0]) + "[/wave]\n" 
      else:
        text += "[color=gray]" + str(option[0]) + "[/color]\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    secretRitualOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    secretRitualOptionIndex -= 1
    shouldUpdateMenuText = true
  if secretRitualOptionIndex < 0:
    secretRitualOptionIndex = len(secretRitualOptions) - 1
  elif secretRitualOptionIndex >= len(secretRitualOptions):
    secretRitualOptionIndex = 0
  cursorSprite.position.y = 120 + (40*secretRitualOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    if secretRitualOptionIndex == len(secretRitualOptions) - 1:
      yield(get_tree().create_timer(0.1), "timeout")
      global.isPauseMenuOpen = false
      global.pauseGame = false
      getPlayer().unpauseSound.play()
      level.restartMusic()
    else:
      var level_to_spawn_to = secretRitualOptions[secretRitualOptionIndex][1]
      global.memory["roomPath"] = level.getLevelName()
      global.pauseGame = true
      global.isEnteringRoom = true
      global.angelWarping = true
      global.hasJustEnteredRoom = false
      global.respawnVarTimerHack = 0
      global.memory["on_ground"] = true
      transition.long_fade_to(level_to_spawn_to)
      global.isPauseMenuOpen = false
  elif Input.is_action_just_pressed("menu_cancel"):
    yield(get_tree().create_timer(0.1), "timeout")
    global.isPauseMenuOpen = false
    global.pauseGame = false
    getPlayer().unpauseSound.play()
    level.restartMusic()
    


var topInputOptions = ["Keyboard", "Controller"]
var topInputOptionIndex = 0
func processTopInputLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(topInputOptions)):
      var option = topInputOptions[i]

      if i == topInputOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n\n" 
    normalMenuText.bbcode_text = text
    shouldUpdateMenuText = false

  if Input.is_action_just_pressed("menu_down"):
    topInputOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_up"):
    topInputOptionIndex -= 1
    shouldUpdateMenuText = true
  if topInputOptionIndex < 0:
    topInputOptionIndex = len(topInputOptions) - 1
  elif topInputOptionIndex >= len(topInputOptions):
    topInputOptionIndex = 0
  cursorSprite.position.y = 120 + (80*topInputOptionIndex)

  if Input.is_action_just_pressed("menu_confirm"):
    if topInputOptionIndex == 0:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.KEYBOARD_INPUT
    elif topInputOptionIndex == 1:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.CONTROLLER_INPUT
  elif Input.is_action_just_pressed("menu_cancel"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true

func initializeControlsConfig():
  var newControlsConfig = [
    {
      "input_action": "ui_left",
      "label_str": "move left",
      "default_keyCode": 16777231, 
      "button_index": JOY_DPAD_LEFT,
      "default_button_index": JOY_DPAD_LEFT,
    },
    {
      "input_action": "ui_right",
      "label_str": "move right",
      "default_keyCode": 16777233, 
      "button_index": JOY_DPAD_RIGHT,
      "default_button_index": JOY_DPAD_RIGHT,
    },
    {
      "input_action": "ui_down",
      "label_str": "down",
      "default_keyCode": 16777234, 
      "button_index": JOY_DPAD_DOWN,
      "default_button_index": JOY_DPAD_DOWN,
    },
    {
      "input_action": "ui_up",
      "label_str": "up",
      "default_keyCode": 16777232, 
      "button_index": JOY_DPAD_UP,
      "default_button_index": JOY_DPAD_UP,
    },
    {
      "input_action": "jump_button",
      "label_str": "jump",
      "default_keyCode": 90, 
      "button_index": JOY_DS_A,
      "default_button_index": JOY_DS_A,
    },
    {
      "input_action": "sub_action_button",
      "label_str": "sweep",
      "default_keyCode": 88, 
      "button_index": JOY_DS_B,
      "default_button_index": JOY_DS_B,
    },
    {
      "input_action": "restart_key",
      "label_str": "Return.",
      "default_keyCode": 82, 
      "button_index": JOY_SELECT, 
      "default_button_index": JOY_SELECT, 
    },
    {
      "input_action": "alt_action_button",
      "label_str": "next spell",
      "default_keyCode": 32, 
      "button_index": JOY_DS_X, 
      "default_button_index": JOY_DS_X, 
    },
    {
      "input_action": "left_button",
      "label_str": "prev spell",
      "default_keyCode": 16, 
      "button_index": JOY_DS_X, 
      "default_button_index": JOY_DS_X, 
    },
  ]
  if global.memory.has("controls_config") and not global.hasInitializedControlsConfig:
    var rememberedControlsConfig = global.memory["controls_config"]
    for control_config in newControlsConfig:
      for remembered_config in rememberedControlsConfig:
        if remembered_config.input_action == control_config.input_action:
          global.setKeyCode(control_config.input_action, remembered_config["key_code"])
          control_config["key_code"] = remembered_config["key_code"]
          break
      # make sure its set to default if it was erased from memory
      if not control_config.has("key_code") or control_config["key_code"] == null:
        control_config["key_code"] = global.getKeyCode(control_config.input_action)
    global.hasInitializedControlsConfig = true
  else:
    for control_config in newControlsConfig:
      control_config["key_code"] = global.getKeyCode(control_config.input_action)

  controlsConfig = newControlsConfig

onready var inputLabelTextLabel = get_node("InputMenu/ScrollContainer/InputLabels")
onready var buttonInputTextLabel = get_node("InputMenu/ScrollContainer/ButtonInputs")
func processControlsLogic(_delta):
  if global.is_reading_input:
    pauseTitleText.bbcode_text = "press key to set \"" + str(controlsConfig[control_index].label_str) + "\""
  else:
    if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
      pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back\n hold [font=res://DarkInputFont_small.tres]B[/font]: reset bindings"
    elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
      pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back\n   hold SELECT: reset bindings"

  if global.is_reading_input:
    if global.last_read_input != null:
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        var keyCodeString = OS.get_scancode_string(global.last_read_input)
        if keyCodeString != "Enter" and keyCodeString != "Escape" and keyCodeString != "BackSpace":
          controlsConfig[control_index].key_code = global.last_read_input
          global.setKeyCode(controlsConfig[control_index].input_action, global.last_read_input)
          global.memory["controls_config"] = controlsConfig
          global.is_reading_input = false
          global.is_reading_keyboard_input = false
          last_control_index = -1
          level.saveTheGame()
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        if global.last_read_input != JOY_START:
          controlsConfig[control_index].button_index = global.last_read_input
          global.setButtonIndex(controlsConfig[control_index].input_action, global.last_read_input)
          global.memory["controls_config"] = controlsConfig
          global.is_reading_input = false
          global.is_reading_controller_input = false
          last_control_index = -1
          level.saveTheGame()
    return
  else:
    if Input.is_action_just_pressed("menu_down"):
      control_index += 1
    elif Input.is_action_just_pressed("menu_up"):
      control_index -= 1
    if Input.is_action_just_pressed("menu_confirm") and not Input.is_action_pressed("ui_cancel") and not Input.is_action_pressed("ui_cancel_controller"):
      global.is_reading_input = true
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        global.is_reading_keyboard_input = true
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        global.is_reading_controller_input = true
      global.last_read_input = null
      last_control_index = -1
    elif Input.is_action_just_pressed("menu_cancel"):
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true

  if control_index < 0:
    control_index = controlsConfig.size() - 1
  if control_index >= controlsConfig.size():
    control_index = 0
  cursorSprite.position.y = 114 + (44*control_index)

  var inputLabelText = ""
  var buttonInputText = "[center]"
  for i in range(controlsConfig.size()):
    var controlConfig = controlsConfig[i]
    if control_index == i:
      var buttonTextAdd = ""
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        buttonTextAdd = "press key" if global.is_reading_input else global.getInputText(controlConfig.input_action, 2)
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        buttonTextAdd = "press button" if global.is_reading_input else global.getInputText(controlConfig.input_action, 1)
      buttonInputText += buttonTextAdd + " \n"
      inputLabelText += "[wave]" + controlConfig.label_str + "[/wave]\n"
    else:
      var buttonTextAdd = ""
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        buttonTextAdd = "[color=gray]" + global.getInputText(controlConfig.input_action, 2) + "[/color]"
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        buttonTextAdd = "[color=gray]" + global.getInputText(controlConfig.input_action, 1) + "[/color]"
      buttonInputText += buttonTextAdd + "\n"
      inputLabelText += "[color=gray]" + controlConfig.label_str + "[/color] \n"
  if last_control_index != control_index or shouldUpdateMenuText:
    inputLabelTextLabel.bbcode_text = inputLabelText
    buttonInputTextLabel.bbcode_text = buttonInputText + "[/center]"

  last_control_index = control_index

func processPopupRenderLogic(delta):
  if global.is_reading_input and (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_cancel")) or Input.is_action_just_pressed("ui_cancel_controller"):
    getPlayer().noBroomSound.play()
    return

  if pauseMenuState == PauseMenuState.KEYBOARD_INPUT and Input.is_action_pressed("ui_cancel") and canResetBindings:
    popupRect.visible = true
    popupTimer += (delta*11)
    if global.isPauseMenuOpen:
      if popupTimer < 5:
        popupText.text = "reset bindings\n ... 3"
      elif popupTimer < 10:
        popupText.text = "reset bindings\n ... 3 ... 2"
      elif popupTimer < 15:
        popupText.text = "reset bindings\n ... 3 ... 2 ... 1!"
      if popupTimer >= popupTimeLimit:
        for i in range(controlsConfig.size()):
          controlsConfig[i]["key_code"] = controlsConfig[i]["default_keyCode"]
          global.setKeyCode(controlsConfig[i].input_action, controlsConfig[i].default_keyCode)  
        global.memory["controls_config"] = controlsConfig
        level.saveTheGame()
        canResetBindings = false
        shouldUpdateMenuText = true
    else:
      popupRect.visible = false
  elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT and Input.is_action_pressed("ui_cancel_controller") and canResetBindings:
    popupRect.visible = true
    popupTimer += (delta*11)
    if global.isPauseMenuOpen:
      if popupTimer < 5:
        popupText.text = "reset bindings\n ... 3"
      elif popupTimer < 10:
        popupText.text = "reset bindings\n ... 3 ... 2"
      elif popupTimer < 15:
        popupText.text = "reset bindings\n ... 3 ... 2 ... 1!"
      if popupTimer >= popupTimeLimit:
        for i in range(controlsConfig.size()):
          controlsConfig[control_index].button_index = controlsConfig[i].default_button_index
          global.setButtonIndex(controlsConfig[i].input_action, controlsConfig[i].default_button_index)
        global.memory["controls_config"] = controlsConfig
        level.saveTheGame()
        canResetBindings = false
        shouldUpdateMenuText = true
    else:
      popupRect.visible = false
  else:
    popupRect.visible = false
    popupTimer = 0
    if not Input.is_action_pressed("ui_cancel") and not Input.is_action_pressed("ui_cancel_controller"):
      canResetBindings = true
