extends Control

onready var popupRect = get_node("CanvasLayer/PopupRect")
onready var popupText = get_node("CanvasLayer/PopupRect/ColorRect/ColorRect/RichTextLabel")
var popupTimer = 0
var popupTimeLimit = 20
var canResetBindings = true

onready var pauseTitleRect = get_node("PauseTitleRect")
onready var pauseTitleText = get_node("PauseTitleRect/PauseTitleText")

onready var cursorSprite = get_node("CursorSprite")
# NORMAL MENU
onready var normalMenu = get_node("NormalMenu")
onready var normalMenuText = get_node("NormalMenu/RichTextLabel")
onready var pauseMenuRect = get_node("PauseMenuRect")
onready var largerPopup = get_node("LargerPopup")
onready var inventoryRect = get_node("InventoryRect")
onready var shardsText = get_node("InventoryRect/ShardsText")
onready var mapRect = get_node("InventoryRect/MapRect")
onready var mapIconSprite = get_node("InventoryRect/MapRect/MapIconSprite")

# INPUT MENU
onready var inputMenu = get_node("InputMenu")
onready var menuMoveSound = get_node("MenuMoveSound")
onready var menuConfirmSound = get_node("MenuConfirmSound")
onready var menuCancelSound = get_node("MenuCancelSound")
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
  shardsText.visible = get_node("../GlitchStatusRect").visible
  if not global.isPauseMenuOpen:
    popupRect.visible = false
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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    menuConfirmSound.play()
  elif (Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start")) and ((pauseMenuState == PauseMenuState.INVENTORY and popupRect.visible) or (pauseMenuState != PauseMenuState.SECRET_RITUAL and pauseMenuState != PauseMenuState.INVENTORY and pauseMenuState != PauseMenuState.NORMAL)):
    menuCancelSound.play()

  processGlitchScreen(delta)
  if pauseMenuState == PauseMenuState.NORMAL:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processNormalLogic(delta)

  if pauseMenuState == PauseMenuState.GRAPHICS:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    colorblindPlayers.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processGraphicsLogic(delta)
  else:
    graphicsOptionIndex = 0
    colorblindPlayers.visible = false

  if pauseMenuState == PauseMenuState.SOUND:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processSoundLogic(delta)
  else:
    soundOptionIndex = 0

  if pauseMenuState == PauseMenuState.QUIT_TO_MAIN:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processQuitToMainLogic(delta)
  else:
    quitToMainOptionIndex = 0

  if pauseMenuState == PauseMenuState.TOP_INPUT:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processTopInputLogic(delta)

  if pauseMenuState == PauseMenuState.KEYBOARD_INPUT or pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = false
    cursorSprite.position.x = 100
    cursorSprite.visible = true
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
    cursorSprite.visible = true
    processSecretRitualLogic(delta)
  else:
    secretRitualOptionIndex = 0

  if pauseMenuState == PauseMenuState.INVENTORY:
    pauseMenuRect.visible = false
    largerPopup.visible = true
    normalMenu.visible = false
    cursorSprite.visible = false
    processInventoryLogic(delta)
    inventoryRect.visible = true
  else:
    inventoryRect.visible = false
    inventoryOptionIndex = 0
    inventoryOptionIndexX = 0

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

  if largerPopup.visible and not pauseMenuRect.visible:
    pauseTitleRect.rect_position = Vector2(92, 400)
  else:
    pauseTitleRect.rect_position = Vector2(92, 5)


var normalMenuOptions = ["resume", "Input", "Graphics", "Sound", "Quit to Main"]
var normalMenuOptionsOnMainMenu = ["resume", "Input", "Graphics", "Sound", "Quit Game"]
var normalOptionIndex = 0
func processNormalLogic(_delta):
  if global.isOnMainMenu:
    normalMenuOptions = normalMenuOptionsOnMainMenu
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to resume\n"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(normalMenuOptions)):
      var option = normalMenuOptions[i]
      if i == normalOptionIndex:
        if global.memory["demo_mode"] >= 2:
          text += "[wave]" + str(option) + "[/wave]\n" 
        else:
          text += "[wave]" + str(option) + "[/wave]\n\n" 
      else:
        if global.memory["demo_mode"] >= 2:
          text += "[color=gray]" + str(option) + "[/color]\n" 
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
  if global.memory["demo_mode"] >= 2:
    cursorSprite.position.y = 120 + (40*normalOptionIndex)
  else:
    cursorSprite.position.y = 120 + (80*normalOptionIndex)

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
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
      topInputOptionIndex = 0
    elif normalOptionIndex == 2:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.GRAPHICS
    elif normalOptionIndex == 3:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.SOUND
    elif normalOptionIndex == 4:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.QUIT_TO_MAIN
    elif normalOptionIndex == 5:
      OS.shell_open("https://steamcommunity.com/app/1876850/discussions/0/")
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.NORMAL
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
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
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
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
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    if quitToMainOptionIndex == 0:
      if global.isOnMainMenu:
        get_tree().quit()
      else:
        # dedupe (ish) with "dev_demo_reset" above
        global.pauseGame = true
        global.has_started_game = false
        global.has_really_started_game = false
        global.resetMemory()
        global.currLevelZone = null
        transition.long_fade_to("res://levels/EndlessFantasy/gd1/000PastoralScene.tscn")
        global.isPauseMenuOpen = false
    elif quitToMainOptionIndex == 1:
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
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
      get_node("TeleportSound").play()
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
    yield(get_tree().create_timer(0.1), "timeout")
    global.isPauseMenuOpen = false
    global.pauseGame = false
    getPlayer().unpauseSound.play()
    level.restartMusic()

var inventoryOptionIndex = 0
var inventoryOptionIndexX = 0
var selectedGlitchSprite = -1
onready var invSelectionSprite = get_node("InventoryRect/SelectionSprite")
onready var glitchRect1 = get_node("InventoryRect/GlitchRect1")
onready var glitchRect2 = get_node("InventoryRect/GlitchRect2")
onready var glitchRect3 = get_node("InventoryRect/GlitchRect3")
onready var glitchRect4 = get_node("InventoryRect/GlitchRect4")
onready var glitchSprite1 = get_node("InventoryRect/GlitchRect1/ColorRect/EquipmentSlotSprite")
onready var glitchSprite2 = get_node("InventoryRect/GlitchRect2/ColorRect/EquipmentSlotSprite")
onready var glitchSprite3 = get_node("InventoryRect/GlitchRect3/ColorRect/EquipmentSlotSprite")
onready var glitchSprite4 = get_node("InventoryRect/GlitchRect4/ColorRect/EquipmentSlotSprite")
func processInventoryLogic(delta):
  pauseTitleText.bbcode_text = global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to resume"
  var spellbook = global.memory["spellbookPage"] if global.memory.has("spellbookPage") else []
  var spellbookSize = spellbook.size()
  if selectedGlitchSprite >= 0:
    if spellbookSize == 0:
      pauseTitleText.bbcode_text = "you've forgotten your spells"
    else:
      pauseTitleText.bbcode_text = "change spell order, " + global.getInputText("menu_left") + global.getInputText("menu_right") + "\n" + global.getInputText("menu_confirm") + " to swap"
  processInventoryRender(delta)
  
  var activeColor = Color("#dcdcdc")
  var inactiveColor = Color("#006400")
  var selectedColor = Color("#f79838")
  if inventoryOptionIndex == 0:
    if not global.memory.has("spellbookPage"):
      inventoryOptionIndex = 1
      return
    if Input.is_action_just_pressed("menu_right"):
      inventoryOptionIndexX += 1
      menuMoveSound.play()
    elif Input.is_action_just_pressed("menu_left"):
      inventoryOptionIndexX -= 1
      menuMoveSound.play()
    if inventoryOptionIndexX < 0:
      inventoryOptionIndexX = spellbookSize - 1
    elif inventoryOptionIndexX > spellbookSize - 1:
      inventoryOptionIndexX = 0
    glitchRect1.color = activeColor if inventoryOptionIndexX == 0 else selectedColor if selectedGlitchSprite == 0 else inactiveColor
    glitchRect2.color = activeColor if inventoryOptionIndexX == 1 else selectedColor if selectedGlitchSprite == 1 else inactiveColor
    glitchRect3.color = activeColor if inventoryOptionIndexX == 2 else selectedColor if selectedGlitchSprite == 2 else inactiveColor
    glitchRect4.color = activeColor if inventoryOptionIndexX == 3 else selectedColor if selectedGlitchSprite == 3 else inactiveColor
    if spellbookSize > 0:
      var which_glitch = spellbook[inventoryOptionIndexX] if global.memory["glitched_grimoire"] or level.player.spellCastPauseIndex == 0 else spellbook[1-inventoryOptionIndexX]
      if which_glitch == global.GlitchForm.FLOOR:
        popupText.text = "air walk:\n  walk off platforms\n  without falling"
      if which_glitch == global.GlitchForm.FEATHER:
        popupText.text = "feather fall:\n  hold jump to\n  float or jump high"
      if which_glitch == global.GlitchForm.LADDER:
        popupText.text = "ladder:\n  walk into walls\n  climb upwards"
      if which_glitch == global.GlitchForm.INVISIBLE:
        popupText.text = "ghost:\n  glitches can't get u"
      if which_glitch == global.GlitchForm.WALK_THROUGH_WALLS:
        popupText.text = "undefined:\n ???"
  else:
    glitchRect1.color = inactiveColor
    glitchRect2.color = inactiveColor
    glitchRect3.color = inactiveColor
    glitchRect4.color = inactiveColor
      
  if (selectedGlitchSprite < 0 or spellbookSize == 0) and not popupRect.visible:
    if Input.is_action_just_pressed("menu_up"):
      normalizeInventoryOptionIndex(-1, 0)
    if Input.is_action_just_pressed("menu_down"):
      normalizeInventoryOptionIndex(1, 0)

  if inventoryOptionIndex != 0 and not popupRect.visible:
    if Input.is_action_just_pressed("menu_right"):
      normalizeInventoryOptionIndex(0, 1)
      menuMoveSound.play()
    elif Input.is_action_just_pressed("menu_left"):
      normalizeInventoryOptionIndex(0, -1)
      menuMoveSound.play()

  if Input.is_action_just_pressed("menu_confirm"):
    if inventoryOptionIndex == 0:
      if selectedGlitchSprite == -1:
        selectedGlitchSprite = inventoryOptionIndexX
      else:
        if inventoryOptionIndexX != selectedGlitchSprite:
          var temp = spellbook[selectedGlitchSprite]
          spellbook[selectedGlitchSprite] = spellbook[inventoryOptionIndexX]
          spellbook[inventoryOptionIndexX] = temp
          global.memory["spellbookPage"] = spellbook
          var spellCastPauseIndex = level.player.spellCastPauseIndex
          if inventoryOptionIndexX == spellCastPauseIndex or selectedGlitchSprite == spellCastPauseIndex:
            level.player.applyGlitch(spellbook[spellCastPauseIndex])
        selectedGlitchSprite = -1
      if spellbookSize > 0:
        popupRect.visible = not popupRect.visible
    elif inventoryOptionIndex == 1:
      popupRect.visible = not popupRect.visible
      if inventoryOptionIndexX == 0:
        popupText.text = "your trusty broom.." if not global.memory["glitched_broom"] else "uyro utsryt oomr;b"
        if global.memory["broomerang"] > 1:
          popupText.text += "\nsweep twice to throw it!"
        else:
          popupText.text += "\ngreat for sweeping dust"
        if global.memory["broomerang"] >= 2:
          popupText.text += "\nand again to warp!"
      elif inventoryOptionIndexX == 1:
        popupText.text = "babushka scarf\nkeeps ya warm"
      elif inventoryOptionIndexX == 2:
        popupText.text = "pet follower\nin progress..."
      elif inventoryOptionIndexX == 3:
        popupText.text = "an enchanted bag\nlets you take another hit"
    elif inventoryOptionIndex == 2:
      popupRect.visible = not popupRect.visible
      if inventoryOptionIndexX == 0:
        popupText.text = "memory of fish:\n  swim in water\n  blow bubbles"
      elif inventoryOptionIndexX == 1:
        popupText.text = "mole cricket memory:\n  jump and hold to dig\n  up through ceilings"
      elif inventoryOptionIndexX == 2:
        popupText.text = "mushroom memory:\n  what does this do?"
    elif inventoryOptionIndex == 3:
      popupRect.visible = not popupRect.visible
      if inventoryOptionIndexX == 0:
        popupText.text = "forget me not:\n  the goddess allows you\n  to remember"
      elif inventoryOptionIndexX == 1:
        popupText.text = "goddess dream 2:\n  what does this do?"
      elif inventoryOptionIndexX == 2:
        popupText.text = "goddess dream 3:\n  what does this do?"
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    if popupRect.visible:
      popupRect.visible = false
      selectedGlitchSprite = -1
    elif selectedGlitchSprite >= 0:
      selectedGlitchSprite = -1
    else:
      yield(get_tree().create_timer(0.1), "timeout")
      global.isPauseMenuOpen = false
      global.pauseGame = false
      getPlayer().unpauseSound.play()
      level.restartMusic()

func normalizeInventoryOptionIndex(y, x):
  # gonna need to not be hard coded... based on global.memories... it will be REALLY gross to hardcode this in the case where
  # for example, the player has not collected the enchanted broom, but has collected some SOUL MEMORIES or DREAMS.
  # so on menu_down/up, we're gonna have to have a normalizeFunction...
  if y != 0:
    inventoryOptionIndexX = 0
    inventoryOptionIndex += y
    if y > 0:
      if inventoryOptionIndex == 0 and not grimoireSprite.visible:
        inventoryOptionIndex = 1
      if inventoryOptionIndex == 2 and not bagSprite.visible:
        inventoryOptionIndex = 3
      if inventoryOptionIndex == 3 and not soulLabel.visible:
        inventoryOptionIndex = 4
      if inventoryOptionIndex == 4 or inventoryOptionIndex > 4: # if (inventoryOptionIndex == 4 and not dreamLabel.visible) or inventoryOptionIndex > 4:
        inventoryOptionIndex = 0 if grimoireSprite.visible else 1
    elif y < 0:
      if inventoryOptionIndex == -1 or (inventoryOptionIndex == 0 and not grimoireSprite.visible):
        inventoryOptionIndex = 4
      if inventoryOptionIndex == 4: # and not dreamLabel.visible:
        inventoryOptionIndex = 3
      if inventoryOptionIndex == 3 and not soulLabel.visible:
        inventoryOptionIndex = 2
      if inventoryOptionIndex == 2 and not bagSprite.visible:
        inventoryOptionIndex = 1

  if inventoryOptionIndex == 1:
    inventoryOptionIndexX += x
    if x >= 0:
      if (inventoryOptionIndexX == 3 and not bagSprite.visible) or inventoryOptionIndexX > 3:
        inventoryOptionIndexX = 0
    elif x < 0:
      if inventoryOptionIndexX < 0:
        inventoryOptionIndexX = 3 if bagSprite.visible else 2
      
  if inventoryOptionIndex == 2:
    inventoryOptionIndexX += x
    if x >= 0:
      if inventoryOptionIndexX == 0 and not soulSprite1.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not soulSprite2.visible:
        inventoryOptionIndexX = 2
      if (inventoryOptionIndexX == 2 and not soulSprite3.visible) or inventoryOptionIndexX > 2:
        inventoryOptionIndexX = 0 if soulSprite1.visible else 1
    elif x < 0:
      if inventoryOptionIndexX == 2 and not soulSprite3.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not soulSprite2.visible:
        inventoryOptionIndexX = 0
      if (inventoryOptionIndexX == 0 and not soulSprite1.visible) or inventoryOptionIndex < 0:
        inventoryOptionIndexX = 2 if soulSprite3.visible else 1
  # elif inventoryOptionIndex == 4: # goddess dreams
  #   pass
  #   # if x >= 0:
  #   #   if inventoryOptionIndexX == 0 and not dreamSprite1.visible:
  #   #     inventoryOptionIndexX = 1
  #   #   if inventoryOptionIndexX == 1 and not dreamSprite2.visible:
  #   #     inventoryOptionIndexX = 2
  #   #   if (inventoryOptionIndexX == 2 and not dreamSprite3.visible) or inventoryOptionIndexX > 2:
  #   #     inventoryOptionIndexX = 0 if dreamSprite1.visible else 1
  #   # elif x < 0:
  #   #   if inventoryOptionIndexX == 2 and not dreamSprite3.visible:
  #   #     inventoryOptionIndexX = 1
  #   #   if inventoryOptionIndexX == 1 and not dreamSprite2.visible:
  #   #     inventoryOptionIndexX = 0
  #   #   if (inventoryOptionIndexX == 0 and not dreamSprite1.visible) or inventoryOptionIndex < 0:
  #   #     inventoryOptionIndexX = 2 if dreamSprite3.visible else 1


onready var grimoireSprite = get_node("InventoryRect/GrimoireSprite")
onready var bagSprite = get_node("InventoryRect/BagSprite")
# onready var bagLabel = get_node("InventoryRect/BagLabel")
onready var soulSprite1 = get_node("InventoryRect/SoulSprite1")
onready var soulSprite2 = get_node("InventoryRect/SoulSprite2")
onready var soulSprite3 = get_node("InventoryRect/SoulSprite3")
onready var soulLabel = get_node("InventoryRect/SoulLabel")
# onready var dreamSprite1 = get_node("InventoryRect/DreamSprite1")
# onready var dreamSprite2 = get_node("InventoryRect/DreamSprite2")
# onready var dreamSprite3 = get_node("InventoryRect/DreamSprite3")
# onready var dreamLabel = get_node("InventoryRect/DreamLabel")
func processInventoryRender(_delta):
  tryDrawMap()
  if inventoryOptionIndex == 0:
    invSelectionSprite.position = Vector2(26, 46)
  elif inventoryOptionIndex == 1:
    invSelectionSprite.position = Vector2(26, 102)
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 26
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 82
    elif inventoryOptionIndexX == 2:
      invSelectionSprite.position.x = 140
    elif inventoryOptionIndexX == 3:
      invSelectionSprite.position.x = 197
  elif inventoryOptionIndex == 2:
    invSelectionSprite.position.y = 165
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 26
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 82
    elif inventoryOptionIndexX == 2:
      invSelectionSprite.position.x = 140
  elif inventoryOptionIndex == 3:
    invSelectionSprite.position.y = 240
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 26
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 75
    elif inventoryOptionIndexX == 2:
      invSelectionSprite.position.x = 125

  var spellbook = global.memory["spellbookPage"] if global.memory.has("spellbookPage") else []
  var spellbookSize = spellbook.size()
  var index = level.player.spellCastPauseIndex
  if global.memory.has("spellbookPage"):
    grimoireSprite.visible = true
    # should dedupe with UILayer...
    if global.memory["glitched_grimoire"]:
      grimoireSprite.frame = 3
      glitchRect1.visible = true
      glitchRect2.visible = true
      glitchRect3.visible = true
      glitchRect4.visible = false
      setGlitchSprite(glitchSprite1, spellbook[0] if spellbookSize >= 1 else level.player.glitch_form)
      setGlitchSprite(glitchSprite2, spellbook[1] if spellbookSize >= 2 else global.GlitchForm.NORMAL)
      setGlitchSprite(glitchSprite3, spellbook[2] if spellbookSize >= 3 else global.GlitchForm.NORMAL)
      setGlitchSprite(glitchSprite4, spellbook[3] if spellbookSize >= 4 else global.GlitchForm.NORMAL)
    else:
      grimoireSprite.frame = 0
      glitchRect1.visible = true
      glitchRect2.visible = true
      glitchRect3.visible = false
      glitchRect4.visible = false
      setGlitchSprite(glitchSprite1, spellbook[index] if spellbookSize >= 1 else level.player.glitch_form)
      if spellbookSize >= 2:
        index = (index + 1) % spellbookSize
        setGlitchSprite(glitchSprite2, spellbook[index])
      else:
        setGlitchSprite(glitchSprite2, global.GlitchForm.NORMAL)
  else:
    grimoireSprite.visible = false
    glitchRect1.visible = false
    glitchRect2.visible = false
    glitchRect3.visible = false
    glitchRect4.visible = false

  bagSprite.visible = global.memory["hp"] > 1
  # bagLabel.visible = global.memory["hp"] > 1

  soulSprite1.visible = global.memory["zora_flippers"]
  soulSprite2.visible = global.memory["mole_cricket"]
  soulSprite3.visible = global.memory["mushroom_soul"]
  soulLabel.visible = soulSprite1.visible or soulSprite2.visible or soulSprite3.visible
  # dreamSprite1.visible = global.memory["forget_me_not"]
  # dreamSprite2.visible = global.memory["angel_flute"]
  # dreamSprite3.visible = global.memory["goddess_dream3"]
  # dreamLabel.visible = dreamSprite1.visible or dreamSprite2.visible or dreamSprite3.visible

# optimization could be, rather than reconstructing the map on every level, can keep this map sprite grid on transition, and simply draw it here...
var MAP_WIDTH = 15
var MAP_HEIGHT = 15
var has_drawn_map = false
func setProperMapFrame(sprite, mapGrid, i, j):
  var mapRoom = mapGrid[i][j] # guaranteed to already have this room at least by the time that we get here.
  var mapPath = mapRoom.path
  var levelZoneName = global.getLevelZoneName(mapPath)
  sprite.frame = 0
  var is_left_open = mapRoom.can_nav_left and j > 0 and mapGrid[i].has(j-1)
  var is_right_open = mapRoom.can_nav_right and j < 14 and mapGrid[i].has(j+1)
  var is_top_open = mapRoom.can_nav_up and i < 14 and mapGrid.has(i+1) and mapGrid[i+1].has(j)
  var is_bottom_open = mapRoom.can_nav_down and i > 0 and mapGrid.has(i-1) and mapGrid[i-1].has(j)
  if is_left_open and is_right_open and is_top_open and is_bottom_open:
    sprite.frame = 5
  elif is_left_open and is_right_open and is_top_open:
    sprite.frame = 4
  elif is_left_open and is_right_open and is_bottom_open:
    sprite.frame = 4
    sprite.flip_v = true
  elif is_left_open and is_top_open and is_bottom_open:
    sprite.frame = 15
    sprite.flip_h = true
  elif is_right_open and is_top_open and is_bottom_open:
    sprite.frame = 15
  elif is_left_open and is_right_open:
    sprite.frame = 3
  elif is_left_open and is_top_open:
    sprite.frame = 2
    sprite.flip_h = true
  elif is_left_open and is_bottom_open:
    sprite.frame = 2
    sprite.flip_h = true
    sprite.flip_v = true
  elif is_right_open and is_top_open:
    sprite.frame = 2
  elif is_right_open and is_bottom_open:
    sprite.frame = 2
    sprite.flip_v = true
  elif is_top_open and is_bottom_open:
    sprite.frame = 13
  elif is_left_open:
    sprite.frame = 1
    sprite.flip_h = true
  elif is_right_open:
    sprite.frame = 1
  elif is_top_open:
    sprite.frame = 9
  elif is_bottom_open:
    sprite.frame = 8
  
  sprite.material = sprite.material.duplicate()
  sprite.z_index = 1
  match levelZoneName:
    "gd1":
        pass
    "gd1TutorialDungeon":
        sprite.material.set_shader_param("target_palette", global.grey_palette)
    "gd1FishingVillage":
        sprite.material.set_shader_param("target_palette", global.green_palette)
    "gd1ToxicJungle":
        sprite.material.set_shader_param("target_palette", global.black_palette)
    "gd1ShiftingSandLand":
        sprite.material.set_shader_param("target_palette", global.yellow_palette)
    "gd1CrystalTower":
        sprite.material.set_shader_param("target_palette", global.white_palette)
    "gd1GrandmaVillage":
        sprite.material.set_shader_param("target_palette", global.white_palette)
    "gd1BubblegloopSwamp":
        sprite.material.set_shader_param("target_palette", global.green_tidepool_palette)
    "gd1TombSouls":
        sprite.material.set_shader_param("target_palette", global.yellow_black_palette)
    "gd1AbstractSuburbs":
        sprite.material.set_shader_param("target_palette", global.green_black_palette)
    "gd1primordialOoze":
        sprite.material.set_shader_param("target_palette", global.dream_palette)
    _:
        pass

func tryDrawMap():
  if has_drawn_map:
    return

  var mapGrid = transition.mapManager.gimmeMapGrid()
  var angelStatues = global.getThingArrayFromAllLevelZonez("angel_statue")
  for i in range(MAP_HEIGHT):
    for j in range(MAP_WIDTH):
      if not mapGrid.has(i) or not mapGrid[i].has(j):
        continue
      var spriteIndex = (j + ((14-i)*MAP_WIDTH)) + 1
      var spriteName = "ColorRect/ColorRect/MapSprite" + str(spriteIndex)
      var sprite = mapRect.get_node(spriteName) if mapRect.has_node(spriteName) else null
      sprite.z_index = 0
      var mapRoom = mapGrid[i][j]
      if sprite == null:
        print("DEBUG: " + spriteName + " doesn't exist")
      elif mapRoom.path == level.getLevelName():
        setProperMapFrame(sprite, mapGrid, i, j)
        var playerIcon = mapIconSprite.duplicate()
        playerIcon.visible = true
        sprite.add_child(playerIcon)
      elif global.memory.has("prev_room") and mapRoom.path == global.memory["prev_room"]:
        setProperMapFrame(sprite, mapGrid, i, j)
        var playerIcon = mapIconSprite.duplicate()
        playerIcon.frame = 1
        playerIcon.visible = true
        sprite.add_child(playerIcon)
      # elif global.haveIBeenToThisLevelPath(mapRoom.path):
      else:
        for angelStatue in angelStatues:
          if mapRoom.path == angelStatue[1]:
            var playerIcon = mapIconSprite.duplicate()
            playerIcon.frame = 2
            playerIcon.visible = true
            sprite.add_child(playerIcon)
        setProperMapFrame(sprite, mapGrid, i, j)
  has_drawn_map = true

func setGlitchSprite(sprite, glitch):
  # TODO(jaketrower): dedupe (1) with Player.gd
  if glitch == global.GlitchForm.NORMAL: sprite.frame = 4
  elif glitch == global.GlitchForm.FLOOR: sprite.frame = 1
  elif glitch == global.GlitchForm.FEATHER: sprite.frame = 0
  elif glitch == global.GlitchForm.LADDER: sprite.frame = 2
  elif glitch == global.GlitchForm.INVISIBLE: sprite.frame = 3
  elif glitch == global.GlitchForm.WALK_THROUGH_WALLS: sprite.frame = 4


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

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    if topInputOptionIndex == 0:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.KEYBOARD_INPUT
    elif topInputOptionIndex == 1:
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.CONTROLLER_INPUT
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
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
      "button_index": JOY_DS_Y, 
      "default_button_index": JOY_DS_Y,
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
      "default_keyCode": 16777237, 
      "button_index": JOY_L, 
      "default_button_index": JOY_L, 
    },
    {
      "input_action": "spell_1",
      "label_str": "spell 1",
      "default_keyCode": 49, 
    },
    {
      "input_action": "spell_2",
      "label_str": "spell 2",
      "default_keyCode": 50, 
    },
    {
      "input_action": "spell_3",
      "label_str": "spell 3",
      "default_keyCode": 51, 
    },
    {
      "input_action": "spell_4",
      "label_str": "spell 4",
      "default_keyCode": 52, 
    },
    {
      "input_action": "spell_5",
      "label_str": "spell 5",
      "default_keyCode": 53, 
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
      pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back\n   hold " + global.getInputText("ui_cancel_controller") + ": reset bindings"

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
    if (Input.is_action_just_pressed("menu_confirm") or Input.is_action_just_pressed("popup_menu")) and not Input.is_action_pressed("ui_cancel"):
      global.is_reading_input = true
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        global.is_reading_keyboard_input = true
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        global.is_reading_controller_input = true
      global.last_read_input = null
      last_control_index = -1
    elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
      yield(get_tree().create_timer(0.1), "timeout")
      pauseMenuState = PauseMenuState.TOP_INPUT
      shouldUpdateMenuText = true

  var showCondensedMenu = pauseMenuState == PauseMenuState.KEYBOARD_INPUT
  var properSize = controlsConfig.size() if showCondensedMenu else controlsConfig.size() - 5
  if control_index < 0:
    control_index = properSize - 1
  if control_index >= properSize:
    control_index = 0
  if showCondensedMenu:
    cursorSprite.position.y = 114 + (29*control_index)
  else:
    cursorSprite.position.y = 114 + (44*control_index)

  var inputLabelText = ""
  if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
    inputLabelText = "[font=res://pauseMenuFontInputCondensed.tres]"
  var buttonInputText = "[font=res://pauseMenuFontInputCondensed.tres][center]"
  for i in range(properSize):
    var controlConfig = controlsConfig[i]
    if control_index == i:
      var buttonTextAdd = ""
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        buttonTextAdd = "press key" if global.is_reading_input else global.getInputText(controlConfig.input_action, 2, true, showCondensedMenu)
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        buttonTextAdd = "press button" if global.is_reading_input else global.getInputText(controlConfig.input_action, 1)
      buttonInputText += buttonTextAdd + " \n"
      inputLabelText += "[wave]" + controlConfig.label_str + "[/wave]\n"
    else:
      var buttonTextAdd = ""
      if pauseMenuState == PauseMenuState.KEYBOARD_INPUT:
        buttonTextAdd = "[color=gray]" + global.getInputText(controlConfig.input_action, 2, true, showCondensedMenu) + "[/color]"
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        buttonTextAdd = "[color=gray]" + global.getInputText(controlConfig.input_action, 1) + "[/color]"
      buttonInputText += buttonTextAdd + "\n"
      inputLabelText += "[color=gray]" + controlConfig.label_str + "[/color] \n"
  if last_control_index != control_index or shouldUpdateMenuText:
    inputLabelTextLabel.bbcode_text = inputLabelText
    buttonInputTextLabel.bbcode_text = buttonInputText + "[/center]"

  last_control_index = control_index

func processPopupRenderLogic(delta):
  if global.is_reading_input and (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_cancel")) or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    getPlayer().noBroomSound.play()
    global.is_reading_input = false
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
          if controlsConfig[i].has("default_button_index"):
            controlsConfig[control_index].button_index = controlsConfig[i].default_button_index
            global.setButtonIndex(controlsConfig[i].input_action, controlsConfig[i].default_button_index)
        global.memory["controls_config"] = controlsConfig
        level.saveTheGame()
        canResetBindings = false
        shouldUpdateMenuText = true
    else:
      popupRect.visible = false
  else:
    if pauseMenuState != PauseMenuState.INVENTORY:
      popupRect.visible = false
    popupTimer = 0
    if not Input.is_action_pressed("ui_cancel") and not Input.is_action_pressed("popup_menu") and not Input.is_action_pressed("ui_start"):
      canResetBindings = true
