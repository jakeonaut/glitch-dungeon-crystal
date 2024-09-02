extends Control

onready var popupRect = get_node("PopupRect")
onready var popupText = get_node("PopupRect/ColorRect/ColorRect/RichTextLabel")
var popupTimer = 0
var popupTimeLimit = 20
var canResetBindings = true

onready var pauseTitleText = get_node("PauseTitleRect/ColorRect/ColorRect/RichTextLabel")

onready var cursorSprite = get_node("CursorSprite")
# NORMAL MENU
onready var normalMenu = get_node("NormalMenu")
onready var normalMenuText = get_node("NormalMenu/RichTextLabel")

# INPUT MENU
onready var inputMenu = get_node("InputMenu")
onready var leftSprite = get_node("InputMenu/LeftSprite")
onready var leftSpriteAniPlayer = get_node("InputMenu/LeftSprite/AnimationPlayer")
onready var leftTextLabel = get_node("InputMenu/LeftTextLabel")
onready var rightSprite = get_node("InputMenu/RightSprite")
onready var rightSpriteAniPlayer = get_node("InputMenu/RightSprite/AnimationPlayer")
onready var rightTextLabel = get_node("InputMenu/RightTextLabel")
onready var runSprite = get_node("InputMenu/RunSprite")
onready var runSpriteAniPlayer = get_node("InputMenu/RunSprite/AnimationPlayer")
onready var runTextLabel = get_node("InputMenu/RunTextLabel")
onready var downSprite = get_node("InputMenu/DownSprite")
onready var downSpriteAniPlayer = get_node("InputMenu/DownSprite/AnimationPlayer")
onready var downTextLabel = get_node("InputMenu/DownTextLabel")
onready var upSprite = get_node("InputMenu/UpSprite")
onready var upSpriteAniPlayer = get_node("InputMenu/UpSprite/AnimationPlayer")
onready var upTextLabel = get_node("InputMenu/UpTextLabel")
onready var jumpSprite = get_node("InputMenu/JumpSprite")
onready var jumpSpriteAniPlayer = get_node("InputMenu/JumpSprite/AnimationPlayer")
onready var jumpTextLabel = get_node("InputMenu/JumpTextLabel")
onready var sweepSprite = get_node("InputMenu/SweepSprite")
onready var sweepSpriteAniPlayer = get_node("InputMenu/SweepSprite/AnimationPlayer")
onready var sweepTextLabel = get_node("InputMenu/SweepTextLabel")
onready var castSprite = get_node("InputMenu/CastSprite")
onready var castSpriteAniPlayer = get_node("InputMenu/CastSprite/AnimationPlayer")
onready var castTextLabel = get_node("InputMenu/CastTextLabel")
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
  INPUT,
  QUIT_TO_MAIN,
  TEMP
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
    if castTextLabel != null:
      initializeControlsConfig()
      hasInitializedControlsConfig = true
  if not hasInitializedControlsConfig:
    return

  processGlitchScreen(delta)
  if pauseMenuState == PauseMenuState.NORMAL:
    normalMenu.visible = true
    processNormalLogic(delta)

  if pauseMenuState == PauseMenuState.GRAPHICS:
    normalMenu.visible = true
    colorblindPlayers.visible = true
    processGraphicsLogic(delta)
  else:
    graphicsOptionIndex = 0
    colorblindPlayers.visible = false

  if pauseMenuState == PauseMenuState.SOUND:
    normalMenu.visible = true
    processSoundLogic(delta)
  else:
    soundOptionIndex = 0

  if pauseMenuState == PauseMenuState.QUIT_TO_MAIN:
    normalMenu.visible = true
    processQuitToMainLogic(delta)
  else:
    quitToMainOptionIndex = 0

  if pauseMenuState == PauseMenuState.INPUT:
    normalMenu.visible = false
    inputMenu.visible = true
    processControlsLogic(delta)
    processPopupRenderLogic(delta)
  else:
    inputMenu.visible = false
    control_index = 0
    last_control_index = -1


var normalMenuOptions = ["RESUME", "GRAPHICS", "SOUND", "INPUT", "QUIT TO MAIN"]
var normalMenuOptionsOnMainMenu = ["RESUME", "GRAPHICS", "SOUND", "INPUT"]
var normalOptionIndex = 0
func processNormalLogic(_delta):
  if global.isOnMainMenu:
    normalMenuOptions = normalMenuOptionsOnMainMenu
  pauseTitleText.bbcode_text = "press " + global.getKeyCodeStr(controlsConfig[6].key_code) + " to select"

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

  if Input.is_action_just_pressed("ui_down"):
    normalOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("ui_up"):
    normalOptionIndex -= 1
    shouldUpdateMenuText = true
  if normalOptionIndex < 0:
    normalOptionIndex = len(normalMenuOptions) - 1
  elif normalOptionIndex >= len(normalMenuOptions):
    normalOptionIndex = 0
  cursorSprite.position.y = 120 + (80*normalOptionIndex)

  if Input.is_action_just_pressed("sub_action_button"):
    pauseMenuState = PauseMenuState.TEMP
    shouldUpdateMenuText = true
    if normalOptionIndex == 0:
      global.isPauseMenuOpen = false
      global.pauseGame = false
      getPlayer().unpauseSound.play()
      level.restartMusic()
    elif normalOptionIndex == 1:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.GRAPHICS
    elif normalOptionIndex == 2:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.SOUND
    elif normalOptionIndex == 3:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.INPUT
    elif normalOptionIndex == 4:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.QUIT_TO_MAIN

onready var colorblindPlayers = get_node("ColorblindPlayers")
onready var colorblindHats = get_node("ColorblindPlayers/ColorblindHats")
var graphicsOptions = ["CRT FILTER", "GLITCH SCREEN", "COLOR BLIND", "FULLSCREEN"]
var graphicsOptionIndex = 0
func processGraphicsLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getKeyCodeStr(controlsConfig[6].key_code) + " to select, " + global.getKeyCodeStr(controlsConfig[5].key_code) + " to go back"

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

  if Input.is_action_just_pressed("ui_down"):
    graphicsOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("ui_up"):
    graphicsOptionIndex -= 1
    shouldUpdateMenuText = true
  if graphicsOptionIndex < 0:
    graphicsOptionIndex = len(graphicsOptions) - 1
  elif graphicsOptionIndex >= len(graphicsOptions):
    graphicsOptionIndex = 0
  cursorSprite.position.y = 120 + (80*graphicsOptionIndex)

  if Input.is_action_just_pressed("sub_action_button"):
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
  elif Input.is_action_just_pressed("jump_button"):
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

var soundOptions = ["PLAY MUSIC", "MUSIC GLITCH"] # global.memory["canChangeSongPitch"]
var soundOptionIndex = 0
func processSoundLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getKeyCodeStr(controlsConfig[6].key_code) + " to select, " + global.getKeyCodeStr(controlsConfig[5].key_code) + " to go back"

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

  if Input.is_action_just_pressed("ui_down"):
    soundOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("ui_up"):
    soundOptionIndex -= 1
    shouldUpdateMenuText = true
  if soundOptionIndex < 0:
    soundOptionIndex = len(soundOptions) - 1
  elif soundOptionIndex >= len(soundOptions):
    soundOptionIndex = 0
  cursorSprite.position.y = 120 + (80*soundOptionIndex)

  if Input.is_action_just_pressed("sub_action_button"):
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
  elif Input.is_action_just_pressed("jump_button"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true


var quitToMainOptions = ["YES", "CANCEL"]
var quitToMainOptionIndex = 0
func processQuitToMainLogic(_delta):
  pauseTitleText.bbcode_text = "  Really Quit?!?\npress " + global.getKeyCodeStr(controlsConfig[6].key_code) + " to select, " + global.getKeyCodeStr(controlsConfig[5].key_code) + " to go back..."

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

  if Input.is_action_just_pressed("ui_down"):
    quitToMainOptionIndex += 1
    shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("ui_up"):
    quitToMainOptionIndex -= 1
    shouldUpdateMenuText = true
  if quitToMainOptionIndex < 0:
    quitToMainOptionIndex = len(quitToMainOptions) - 1
  elif quitToMainOptionIndex >= len(quitToMainOptions):
    quitToMainOptionIndex = 0
  cursorSprite.position.y = 120 + (80*quitToMainOptionIndex)

  if Input.is_action_just_pressed("sub_action_button"):
    if quitToMainOptionIndex == 0:
      transition.long_fade_to("res://levels/EndlessFantasy/gd1/000PastoralScene.tscn")
      global.isPauseMenuOpen = false
    elif quitToMainOptionIndex == 1:
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("jump_button"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true



func initializeControlsConfig():
  var newControlsConfig = [
    {
      "input_action": "ui_left",
      "label_str": "LEFT",
      "text_label": leftTextLabel,
      "sprite": leftSprite,
      "sprite_aniPlayer": leftSpriteAniPlayer,
      "default_keyCode": 16777231, 
    },
    {
      "input_action": "ui_right",
      "label_str": "RIGHT",
      "text_label": rightTextLabel,
      "sprite": rightSprite,
      "sprite_aniPlayer": rightSpriteAniPlayer,
      "default_keyCode": 16777233, 
    },
    # {
    #   "input_action": "run_button",
    #   "label_str": "RUN",
    #   "text_label": runTextLabel,
    #   "sprite": runSprite,
    #   "sprite_aniPlayer": runSpriteAniPlayer,
    #   "default_keyCode": 16777237, 
    # },
    {
      "input_action": "ui_down",
      "label_str": "DOWN",
      "text_label": downTextLabel,
      "sprite": downSprite,
      "sprite_aniPlayer": downSpriteAniPlayer,
      "default_keyCode": 16777234, 
    },
    {
      "input_action": "ui_up",
      "label_str": "UP",
      "text_label": upTextLabel,
      "sprite": upSprite,
      "sprite_aniPlayer": upSpriteAniPlayer,
      "default_keyCode": 16777232, 
    },
    {
      "input_action": "jump_button",
      "label_str": "JUMP",
      "text_label": jumpTextLabel,
      "sprite": jumpSprite,
      "sprite_aniPlayer": jumpSpriteAniPlayer,
      "default_keyCode": 90, 
    },
    {
      "input_action": "sub_action_button",
      "label_str": "SWEEP",
      "text_label": sweepTextLabel,
      "sprite": sweepSprite,
      "sprite_aniPlayer": sweepSpriteAniPlayer,
      "default_keyCode": 88, 
    },
    {
      "input_action": "alt_action_button",
      "label_str": "MAGICK",
      "text_label": castTextLabel,
      "sprite": castSprite,
      "sprite_aniPlayer": castSpriteAniPlayer,
      "default_keyCode": 32, 
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

func processControlsLogic(_delta):
  if global.is_reading_input:
    pauseTitleText.bbcode_text = "press key to set \"" + str(controlsConfig[control_index].label_str) + "\""
  else:
    pauseTitleText.bbcode_text = "press " + global.getKeyCodeStr(controlsConfig[6].key_code) + " to select, " + global.getKeyCodeStr(controlsConfig[5].key_code) + " to go back\n    hold BACKSPACE: reset bindings"

  if global.is_reading_input:
    if global.last_read_input != null:
      var keyCodeString = OS.get_scancode_string(global.last_read_input)
      if keyCodeString != "Enter" and keyCodeString != "Escape" and keyCodeString != "Backspace":
        controlsConfig[control_index].key_code = global.last_read_input
        global.setKeyCode(controlsConfig[control_index].input_action, global.last_read_input)
        global.memory["controls_config"] = controlsConfig
        global.is_reading_input = false
        last_control_index = -1
        level.saveTheGame()
    return
  else:
    if Input.is_action_just_pressed("ui_down"):
      control_index += 1
      menuMoveSound.play()
    elif Input.is_action_just_pressed("ui_up"):
      control_index -= 1
      menuMoveSound.play()
    if Input.is_action_just_pressed("sub_action_button") and not Input.is_action_pressed("ui_cancel"):
      global.is_reading_input = true
      global.last_read_input = null
      last_control_index = -1
    elif Input.is_action_just_pressed("jump_button"):
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true

  if control_index < 0:
    control_index = controlsConfig.size() - 1
  if control_index >= controlsConfig.size():
    control_index = 0
  cursorSprite.position.y = 120 + (58*control_index)

  var normal_size = Vector2(2, 2)
  var big_size = Vector2(3, 3)

  for i in range(controlsConfig.size()):
    var controlConfig = controlsConfig[i]
    if control_index == i:
      controlConfig.sprite.scale = big_size
      if control_index != last_control_index:
        var waveTextVal = "press key" if global.is_reading_input else "[lb]" + global.getKeyCodeStr(controlConfig.key_code) + "[rb]"
        controlConfig.text_label.bbcode_text = "[wave]" + waveTextVal + "[/wave]"
        # controlConfig.sprite.z_index = 1
        controlConfig.sprite_aniPlayer.play("idle")
    else:
      controlConfig.sprite.scale = normal_size
      controlConfig.text_label.bbcode_text = "[color=gray][lb]" + global.getKeyCodeStr(controlConfig.key_code) + "[rb][/color]"
      # controlConfig.sprite.z_index = 0
      controlConfig.sprite_aniPlayer.stop()
      controlConfig.sprite_aniPlayer.play("RESET")

  last_control_index = control_index

var castSpritePalette = 0
func changeCastSpritePalette():
  if castSpritePalette == 0:
    castSprite.material.set_shader_param("palette_out", global.green_palette)
    castSpritePalette = 1
  elif castSpritePalette == 1:
    castSprite.material.set_shader_param("palette_out", global.red_palette)
    castSpritePalette = 2
  elif castSpritePalette == 2:
    castSprite.material.set_shader_param("palette_out", global.grey_player_palette)
    castSpritePalette = 0

func processPopupRenderLogic(delta):
  if global.is_reading_input and (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_cancel")):
    getPlayer().noBroomSound.play()
    return
  if Input.is_action_pressed("ui_cancel") and canResetBindings:
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
    else:
      popupRect.visible = false
  else:
    popupRect.visible = false
    popupTimer = 0
    if not Input.is_action_pressed("ui_cancel"):
      canResetBindings = true
