extends Control

onready var popupRectCanvasLayer = get_node("CanvasLayer")
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
onready var shardsRect = get_node("InventoryRect/ShardsRect")
onready var keysRect = get_node("InventoryRect/KeysRect")
onready var mapRect = get_node("MapRect")
onready var mapTitleRect = get_node("MapRect/MapTitleRect")
onready var mapColorRect1 = get_node("MapRect/ColorRect")
onready var mapColorRect2 = get_node("MapRect/ColorRect/ColorRect")
onready var mapBackgroundSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite")
var MAP_SPRITE_PREFIX = "ColorRect/ColorRect/MapBackgroundSprite/MapSprite"
onready var mapPlayerSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/PlayerSprite")

onready var map_anglerFishBossSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/AnglerFishBossSprite")
onready var map_babaYagaBossSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/BabaYagaBossSprite")
onready var map_doguBossSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/DoguBossSprite")
onready var map_mushroomSoulSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/MushroomSoulSprite")
onready var map_cricketSoulSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/CricketSoulSprite")
onready var map_fishSoulSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/FishSoulSprite")
onready var map_cryptKeySprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/CryptKeySprite")
onready var map_phishingKeySprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/PhishingKeySprite")
onready var map_sporeKeySprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/SporeKeySprite")

onready var mapCursorSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/CursorSprite")
onready var mapCursorSprite2 = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/CursorSprite2")
onready var mapAngelSprite = get_node("MapRect/ColorRect/ColorRect/MapBackgroundSprite/AngelSprite")
onready var mapFaderRect = get_node("MapRect/ColorRect/ColorRect/MapFaderRect")

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
  # SECRET_RITUAL,
  INVENTORY,
}
var pauseMenuState = PauseMenuState.NORMAL
var shouldUpdateMenuText = true

func _ready():
  set_process(true)

func _process(delta):
  if Input.is_action_pressed("open_map") and global.memory["has_map_item"] and not global.isOnMainMenu and not global.isPauseMenuOpen and global.activeInteractor == null and not global.shouldRenderAsCinematic:
    self.visible = true
    if not has_drawn_map:
      processInventoryRender(delta)
      tryDrawMap()
    mapRect.visible = true
    mapTitleRect.visible = false
    mapRect.color = Color("#00000000")
    mapColorRect1.color = Color("#00000000")
    mapColorRect2.color = Color("#00000000")
    mapBackgroundSprite.modulate = Color("#ffffffff")
    mapBackgroundSprite.self_modulate = Color("#ffffffff")
    # if Input.is_action_pressed("open_map"):
    mapRect.rect_position = Vector2(225, 60)
    mapRect.rect_scale = Vector2(1.5, 1.5)
    # else:
    #   mapRect.rect_position = Vector2(595, 380)
    #   mapRect.rect_scale = Vector2(0.5, 0.5)

    pauseTitleRect.visible = false
    pauseMenuRect.visible = false
    largerPopup.visible = false
    normalMenu.visible = false
    cursorSprite.visible = false
    inventoryRect.visible = false
    shardsRect.visible = false
    keysRect.visible = false
    inventoryFaderRect.visible = false
    mapFaderRect.visible = false
    # inventoryOptionIndex = 4
    # processInventoryLogic(delta)
    # inventoryOptionIndex = 4
    return

  self.visible = global.isPauseMenuOpen
  mapTitleRect.visible = true
  pauseTitleRect.visible = true
  mapRect.rect_position = Vector2(450, 131)
  mapRect.rect_scale = Vector2(1, 1)
  mapRect.color = Color("#040404")
  mapColorRect1.color = Color("#394c62")
  mapColorRect2.color = Color("#040404")
  mapBackgroundSprite.modulate = Color("#ffffff")
  mapBackgroundSprite.self_modulate = Color("#ffffff")

  shardsRect.visible = get_node("../GlitchStatusRect").visible
  keysRect.visible = get_node("../KeyStatusRect").visible
  if not global.isPauseMenuOpen:
    popupRect.visible = false
    return

  if not hasInitializedControlsConfig:
    return
  if not popupRectCanvasLayer.visible:
    popupRectCanvasLayer.visible = true

  if Input.is_action_just_pressed("menu_down"):
    menuMoveSound.play()
  elif Input.is_action_just_pressed("menu_up"):
    menuMoveSound.play()

  if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    menuConfirmSound.play()
  elif (Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start")) and ((pauseMenuState == PauseMenuState.INVENTORY and popupRect.visible) or (pauseMenuState != PauseMenuState.INVENTORY and pauseMenuState != PauseMenuState.NORMAL)):
    menuCancelSound.play()

  processGlitchScreen(delta)
  if pauseMenuState == PauseMenuState.NORMAL:
    pauseTitleRect.visible = true
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processNormalLogic(delta)

  if pauseMenuState == PauseMenuState.GRAPHICS:
    pauseTitleRect.visible = true
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
    pauseTitleRect.visible = true
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processSoundLogic(delta)
  else:
    soundOptionIndex = 0

  if pauseMenuState == PauseMenuState.QUIT_TO_MAIN:
    pauseTitleRect.visible = true
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processQuitToMainLogic(delta)
  else:
    quitToMainOptionIndex = 0

  if pauseMenuState == PauseMenuState.TOP_INPUT:
    pauseTitleRect.visible = true
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = true
    cursorSprite.position.x = 180
    cursorSprite.visible = true
    processTopInputLogic(delta)

  if pauseMenuState == PauseMenuState.KEYBOARD_INPUT or pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
    pauseTitleRect.visible = true
    pauseMenuRect.visible = true
    largerPopup.visible = false
    normalMenu.visible = false
    cursorSprite.position.x = 108
    cursorSprite.visible = true
    inputMenu.visible = true
    processControlsLogic(delta)
    processPopupRenderLogic(delta)
  else:
    inputMenu.visible = false
    control_index = 0
    last_control_index = -1

  if pauseMenuState == PauseMenuState.INVENTORY:
    pauseMenuRect.visible = false
    largerPopup.visible = true
    normalMenu.visible = false
    cursorSprite.visible = false
    processInventoryLogic(delta)
    inventoryRect.visible = true
    mapRect.visible = global.memory["has_map_item"]
    mapTitleRect.visible = mapRect.visible and inventoryOptionIndex != 4
  else:
    inventoryRect.visible = false
    mapRect.visible = false
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
    pauseTitleRect.rect_position = Vector2(164, 400)
  else:
    pauseTitleRect.rect_position = Vector2(164, 5)


var normalMenuOptions = ["resume", "Input", "Graphics", "Sound", "Quit to Main"]
var normalMenuOptionsOnMainMenu = ["resume", "Input", "Graphics", "Sound", "Quit Game"]
var normalOptionIndex = 0
func processNormalLogic(_delta):
  if global.isOnMainMenu:
    normalMenuOptions = normalMenuOptionsOnMainMenu
  pauseTitleText.bbcode_text = global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to resume\n" + global.getInputText("menu_up") + " " + global.getInputText("menu_down")

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(normalMenuOptions)):
      var option = normalMenuOptions[i]
      if i == normalOptionIndex:
        if global.memory["demo_mode"] >= 2:
          text += "[wave]" + str(option) + "[/wave]\n" 
        else:
          text += "[wave]" + str(option) + "[/wave]\n" 
      else:
        if global.memory["demo_mode"] >= 2:
          text += "[color=gray]" + str(option) + "[/color]\n" 
        else:
          text += "[color=gray]" + str(option) + "[/color]\n" 
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
    # elif normalOptionIndex == 5:
    #   OS.shell_open("https://steamcommunity.com/app/1876850/discussions/0/")
    #   yield(get_tree().create_timer(0.1), "timeout")
    #   pauseMenuState = PauseMenuState.NORMAL
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
      if i == 0: option += ("ON" if global.userSettings["show_crt_effect"] else "OFF")
      if i == 1: option += ("ON" if global.userSettings["canGlitchScreen"] else "OFF")
      if i == 2: option += ("ON" if global.userSettings["colorblindMode"] else "OFF")
      if i == 3: option += ("ON" if OS.window_fullscreen else "OFF")

      if i == graphicsOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n" 
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
      global.userSettings["show_crt_effect"] = not global.userSettings["show_crt_effect"]
    elif graphicsOptionIndex == 1:
      global.userSettings["canGlitchScreen"] = not global.userSettings["canGlitchScreen"]
      glitch_death_timer = 1
    elif graphicsOptionIndex == 2:
      global.userSettings["colorblindMode"] = not global.userSettings["colorblindMode"]
    elif graphicsOptionIndex == 3:
      OS.window_fullscreen = not OS.window_fullscreen
    level.saveUserSettings()
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true
  colorblindHats.visible = global.userSettings["colorblindMode"]

func processGlitchScreen(delta):
  if glitch_death_timer != 0:
    glitch_death_timer += (delta*22)
    getPlayer().applyGlitchDeathEffects(abs(glitch_death_timer))
    if global.userSettings["canChangeSongPitch"]:
      musicPlayer.changeSongPitch(abs(sin((glitch_death_timer)*.05)+.02))
    level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
    if glitch_death_timer >= 40:
      musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
      level.glitchScreenEffect.visible = false
      glitch_death_timer = 0

var soundOptions = ["Play Music", "Music Glitches"]
var soundOptionIndex = 0
func processSoundLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(soundOptions)):
      var option = soundOptions[i] + ": "
      if i == 0: option += ("OFF" if global.userSettings["stopAllMusic"] else "ON")
      if i == 1: option += ("ON" if global.userSettings["canChangeSongPitch"] else "OFF")

      if i == soundOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n" 
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
      global.userSettings["stopAllMusic"] = not global.userSettings["stopAllMusic"]
      if global.userSettings["stopAllMusic"]:
        level.stopAllMusic()
      else:
        level.playMenuMusic()
    elif soundOptionIndex == 1:
      global.userSettings["canChangeSongPitch"] = not global.userSettings["canChangeSongPitch"]
      if global.userSettings["canChangeSongPitch"]:
        musicPlayer.changeSongPitch(rand_range(0.8, 1.5))
      glitch_death_timer = 1
    level.saveUserSettings()
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
        text += "[wave]" + str(option) + "[/wave]\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n" 
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
        transition.reset_game("res://levels/EndlessFantasy/gd1/000PastoralScene.tscn")
    elif quitToMainOptionIndex == 1:
      pauseMenuState = PauseMenuState.NORMAL
      shouldUpdateMenuText = true
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
    pauseMenuState = PauseMenuState.NORMAL
    shouldUpdateMenuText = true

var inventoryOptionIndex = 0
var inventoryOptionIndexX = 0
var selectedGlitchSprite = -1
onready var invSelectionSprite = get_node("InventoryRect/SelectionSprite")
onready var inventoryFaderRect = get_node("InventoryRect/InventoryFaderRect")
onready var glitchRect1 = get_node("InventoryRect/GlitchRect1")
onready var glitchRect2 = get_node("InventoryRect/GlitchRect2")
onready var glitchRect3 = get_node("InventoryRect/GlitchRect3")
onready var glitchRect4 = get_node("InventoryRect/GlitchRect4")
onready var glitchSprite1 = get_node("InventoryRect/GlitchRect1/ColorRect/EquipmentSlotSprite")
onready var glitchSprite2 = get_node("InventoryRect/GlitchRect2/ColorRect/EquipmentSlotSprite")
onready var glitchSprite3 = get_node("InventoryRect/GlitchRect3/ColorRect/EquipmentSlotSprite")
onready var glitchSprite4 = get_node("InventoryRect/GlitchRect4/ColorRect/EquipmentSlotSprite")
var angelStatueToTeleportTo = null
func processInventoryLogic(delta):
  var angelStatues = global.getThingArrayFromAllLevelZonez("angel_statue")
  var angelStatueArrValue = angelStatues[getAngelStatueIndex()] if angelStatues.size() > 0 else null
  if (inventoryOptionIndex == 4 or angelStatueToTeleportTo != null) and angelStatueArrValue != null:
    pauseTitleText.bbcode_text = str(angelStatueArrValue[0]) + "\n" + global.getInputText("menu_confirm") + " to teleport, " + global.getInputText("menu_cancel") + " to cancel"
  else:
    pauseTitleText.bbcode_text = global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to resume\n" + global.getInputText("menu_left") + " " + global.getInputText("menu_right") + " " + global.getInputText("menu_up") + " " + global.getInputText("menu_down")
  var spellbook = global.memory["spellbookPage"] if global.memory.has("spellbookPage") else []
  var spellbookSize = spellbook.size()
  if selectedGlitchSprite >= 0:
    if spellbookSize == 0:
      pauseTitleText.bbcode_text = "you've forgotten your spells"
    else:
      pauseTitleText.bbcode_text = "change spell order, " + global.getInputText("menu_left") + global.getInputText("menu_right") + "\n" + global.getInputText("menu_confirm") + " to swap"
  processInventoryRender(delta)
  tryDrawMap()
  
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
      inventoryOptionIndexX = (spellbookSize - 1) if spellbookSize > 0 else 0
    elif inventoryOptionIndexX > spellbookSize - 1 and inventoryOptionIndexX != 0:
      if global.memory["angel_flute"] and selectedGlitchSprite == -1 and angelStatues.size() > 0:
        inventoryOptionIndex = 4
        menuConfirmSound.play()
        inventoryOptionIndexX = 0
        return
      else:
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
      
  var isOnMap = inventoryOptionIndex == 4
  if (selectedGlitchSprite < 0 or spellbookSize == 0) and not popupRect.visible and not isOnMap:
    if Input.is_action_just_pressed("menu_up"):
      normalizeInventoryOptionIndex(-1, 0)
    if Input.is_action_just_pressed("menu_down"):
      normalizeInventoryOptionIndex(1, 0)

  if inventoryOptionIndex != 0 and not popupRect.visible:
    if Input.is_action_just_pressed("menu_right") or (Input.is_action_just_pressed("menu_down") and isOnMap):
      mapCursorSprite.restart()
      mapCursorSprite2.restart()
      normalizeInventoryOptionIndex(0, 1)
      menuMoveSound.play()
    elif Input.is_action_just_pressed("menu_left") or (Input.is_action_just_pressed("menu_up") and isOnMap):
      mapCursorSprite.restart()
      mapCursorSprite2.restart()
      normalizeInventoryOptionIndex(0, -1)
      menuMoveSound.play()
  isOnMap = inventoryOptionIndex == 4
  # inventoryFaderRect.visible = isOnMap
  # mapFaderRect.visible = not isOnMap

  invSelectionSprite.visible = not isOnMap
  if isOnMap and angelStatues.size() != 0 and angelStatueArrValue != null:
    var mapGrid = transition.mapManager.gimmeMapGrid()
    var mapPathToSeek = angelStatueArrValue[1]
    for i in range(MAP_HEIGHT):
      for j in range(MAP_WIDTH):
        if not mapGrid.has(i) or not mapGrid[i].has(j):
          continue
        var roomPath = mapGrid[i][j].path
        if roomPath == mapPathToSeek:
          var spriteIndex = (j + ((MAP_HEIGHT-1-i)*MAP_WIDTH)) + 1
          var spriteName = MAP_SPRITE_PREFIX + str(spriteIndex)
          var sprite = mapRect.get_node(spriteName) if mapRect.has_node(spriteName) else null
          if sprite != null:
            mapCursorSprite.position = sprite.position
            mapCursorSprite2.position = mapCursorSprite.position
            mapCursorSprite2.position.x -= 14
          break
        

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
        popupText.text = "memory of fish:\n  swim in water\n"
      elif inventoryOptionIndexX == 1:
        popupText.text = "mole cricket memory:\n  jump and hold to dig\n  up through ceilings"
      elif inventoryOptionIndexX == 2:
        popupText.text = "spore memory:\n  hold sweep button to\n  teleport when smacking  \n  works with broomerang"
    elif inventoryOptionIndex == 3:
      popupRect.visible = not popupRect.visible
      if inventoryOptionIndexX == 0:
        var numEggs = global.getThingFromAllLevelZonez("angelEgg")
        popupText.text = "angel eggs:\n  spawn of the goddess\n  you have " + str(numEggs)
      elif inventoryOptionIndexX == 1:
        if global.memory["angler_seaman_boss"] == 3:
          popupText.text = "goddess dream of deceit"
        else:
          popupText.text = "phishing key:\n  to sea of corruption"
      elif inventoryOptionIndexX == 2:
        if global.memory["baba_yaga_boss"] == 3:
          popupText.text = "goddess dream of demon"
        else:
          popupText.text = "spore key:\n  to baba's forest"
      elif inventoryOptionIndexX == 3:
        if global.memory["dogu_matryoshka_boss"] == 3:
          popupText.text = "goddess dream of death"
        else:
          popupText.text = "crypt key:\n  to forgotten crypt"
    elif angelStatueToTeleportTo != null:
      var level_to_spawn_to = angelStatueToTeleportTo[1]
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
    elif inventoryOptionIndex == 4 and angelStatues.size() > 0 and angelStatueArrValue != null:
      if angelStatueArrValue[1] == level.getLevelName():
        getPlayer().noBroomSound.play()
      else:
        var levelZoneName = angelStatueArrValue[0]
        popupRect.visible = not popupRect.visible
        if popupRect.visible:
          angelStatueToTeleportTo = angelStatueArrValue
        popupText.text = "teleport to " + levelZoneName + "?"
  elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
    angelStatueToTeleportTo = null
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

func getAngelStatueIndex():
  var angelStatues = global.getThingArrayFromAllLevelZonez("angel_statue")
  # do it in order of collection, so reverse order of appending... sorry!
  var angelStatueIndex = angelStatues.size() - inventoryOptionIndexX - 1
  if angelStatueIndex >= angelStatues.size():
    return angelStatues.size() - 1
  if angelStatueIndex < 0:
    return 0
  return angelStatueIndex

# this would be SOO much easier with a 2d array
func normalizeInventoryOptionIndex(y, x):
  var angelStatues = global.getThingArrayFromAllLevelZonez("angel_statue")
  var hasAngelFlute = global.memory["angel_flute"] and angelStatues.size() > 0
  # gonna need to not be hard coded... based on global.memories... it will be REALLY gross to hardcode this in the case where
  # for example, the player has not collected the enchanted broom, but has collected some SOUL MEMORIES or DREAMS.
  # so on menu_down/up, we're gonna have to have a normalizeFunction...
  if y != 0:
    inventoryOptionIndexX = 0
    inventoryOptionIndex += y
    if y > 0:
      if inventoryOptionIndex == 0 and not grimoireSprite.visible:
        inventoryOptionIndex = 1
      if (inventoryOptionIndex == 2 and not soulLabel.visible):
        inventoryOptionIndex = 3
      if (inventoryOptionIndex == 3 and not keyLabel.visible) or inventoryOptionIndex > 3:
        inventoryOptionIndex = 4 if hasAngelFlute else 0 if grimoireSprite.visible else 1
        if hasAngelFlute:
          menuConfirmSound.play()
        mapCursorSprite.restart()
        mapCursorSprite2.restart()
    elif y < 0:
      if inventoryOptionIndex == -1 or (inventoryOptionIndex == 0 and not grimoireSprite.visible):
        inventoryOptionIndex = 4
        menuConfirmSound.play()
        mapCursorSprite.restart()
        mapCursorSprite2.restart()
        inventoryOptionIndexX = angelStatues.size() - 1
      if inventoryOptionIndex == 4 and not hasAngelFlute:
        inventoryOptionIndex = 3
      if inventoryOptionIndex == 3 and not keyLabel.visible:
        inventoryOptionIndex = 2
      if inventoryOptionIndex == 2 and not soulLabel.visible:
        inventoryOptionIndex = 1

  if inventoryOptionIndex == 1:
    inventoryOptionIndexX += x
    if x >= 0:
      if inventoryOptionIndexX > 1: # (inventoryOptionIndexX == 3 and not bagSprite.visible) or inventoryOptionIndexX > 3:
        if hasAngelFlute:
          inventoryOptionIndex = 4
          menuConfirmSound.play()
          mapCursorSprite.restart()
          mapCursorSprite2.restart()
          inventoryOptionIndexX = 0
          return
        else:
          inventoryOptionIndexX = 0
    elif x < 0:
      if inventoryOptionIndexX < 0:
        inventoryOptionIndexX = 1 # 3 if bagSprite.visible else 2
      
  if inventoryOptionIndex == 2:
    inventoryOptionIndexX += x
    if x >= 0:
      if inventoryOptionIndexX == 0 and not soulSprite1.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not soulSprite2.visible:
        inventoryOptionIndexX = 2
      if (inventoryOptionIndexX == 2 and not soulSprite3.visible) or inventoryOptionIndexX > 2:
        if hasAngelFlute:
          inventoryOptionIndex = 4
          menuConfirmSound.play()
          mapCursorSprite.restart()
          mapCursorSprite2.restart()
          inventoryOptionIndexX = 0
          return
        else:
          inventoryOptionIndexX = 0 if soulSprite1.visible else 1 if soulSprite2.visible else 2
    elif x < 0:
      if inventoryOptionIndexX == 2 and not soulSprite3.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not soulSprite2.visible:
        inventoryOptionIndexX = 0
      if (inventoryOptionIndexX == 0 and not soulSprite1.visible) or inventoryOptionIndexX < 0:
        inventoryOptionIndexX = 2 if soulSprite3.visible else 1 if soulSprite2.visible else 0

  if inventoryOptionIndex == 3:
    inventoryOptionIndexX += x
    if x >= 0:
      if inventoryOptionIndexX == 0 and not angelEggSprite.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not fishKeySprite.visible:
        inventoryOptionIndexX = 2
      if inventoryOptionIndexX == 2 and not sporeKeySprite.visible:
        inventoryOptionIndexX = 3
      if (inventoryOptionIndexX == 3 and not pyramidKeySprite.visible) or inventoryOptionIndexX > 3:
        if hasAngelFlute:
          inventoryOptionIndex = 4
          menuConfirmSound.play()
          mapCursorSprite.restart()
          mapCursorSprite2.restart()
          inventoryOptionIndexX = 0
          return
        else:
          inventoryOptionIndexX = 0 if angelEggSprite.visible else 1 if fishKeySprite.visible else 2 if sporeKeySprite.visible else 3
    elif x < 0:
      if inventoryOptionIndexX == 3 and not pyramidKeySprite.visible:
        inventoryOptionIndexX = 2
      if inventoryOptionIndexX == 2 and not sporeKeySprite.visible:
        inventoryOptionIndexX = 1
      if inventoryOptionIndexX == 1 and not fishKeySprite.visible:
        inventoryOptionIndexX = 0
      if (inventoryOptionIndexX == 0 and not angelEggSprite.visible) or inventoryOptionIndexX < 0:
        inventoryOptionIndexX = 3 if pyramidKeySprite.visible else 2 if sporeKeySprite.visible else 1 if fishKeySprite.visible else 0 

  if inventoryOptionIndex == 4:
    inventoryOptionIndexX += x
    if x > 0:
      if inventoryOptionIndexX >= angelStatues.size():
        inventoryOptionIndex = 0 if grimoireSprite.visible else 1
        inventoryOptionIndexX = 0
        processInventoryRender(0)
        return
    if x < 0:
      if inventoryOptionIndexX < 0:
        inventoryOptionIndex -= 1
        if inventoryOptionIndex == 3 and not keyLabel.visible:
          inventoryOptionIndex = 2
        if inventoryOptionIndex == 2 and not soulLabel.visible:
          inventoryOptionIndex = 1
        inventoryOptionIndexX = 0
        processInventoryRender(0)
        return
    



onready var grimoireSprite = get_node("InventoryRect/GrimoireSprite")
onready var bagSprite = get_node("InventoryRect/BagSprite")
onready var petSprite = get_node("InventoryRect/PetSprite")
# onready var bagLabel = get_node("InventoryRect/BagLabel")
onready var soulSprite1 = get_node("InventoryRect/SoulSprite1")
onready var soulSprite2 = get_node("InventoryRect/SoulSprite2")
onready var soulSprite3 = get_node("InventoryRect/SoulSprite3")
onready var soulLabel = get_node("InventoryRect/SoulLabel")
onready var angelEggSprite = get_node("InventoryRect/AngelEggSprite")
onready var angelEggLabel = get_node("InventoryRect/AngelEggLabel")
onready var fishKeySprite = get_node("InventoryRect/FishKeySprite")
onready var sporeKeySprite = get_node("InventoryRect/SporeKeySprite")
onready var pyramidKeySprite = get_node("InventoryRect/PyramidKeySprite")
onready var keyLabel = get_node("InventoryRect/KeyLabel")
func processInventoryRender(_delta):
  if inventoryOptionIndex == 0:
    invSelectionSprite.position = Vector2(99, 51)
  elif inventoryOptionIndex == 1:
    invSelectionSprite.position.y = 121
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 158
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 213
    # elif inventoryOptionIndexX == 2:
    #   invSelectionSprite.position.x = 209
    # elif inventoryOptionIndexX == 3:
    #   invSelectionSprite.position.x = 265
  elif inventoryOptionIndex == 2:
    invSelectionSprite.position.y = 204
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 136
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 190
    elif inventoryOptionIndexX == 2:
      invSelectionSprite.position.x = 243
  elif inventoryOptionIndex == 3:
    invSelectionSprite.position.y = 287
    if inventoryOptionIndexX == 0:
      invSelectionSprite.position.x = 112
    elif inventoryOptionIndexX == 1:
      invSelectionSprite.position.x = 166
    elif inventoryOptionIndexX == 2:
      invSelectionSprite.position.x = 223
    elif inventoryOptionIndexX == 3:
      invSelectionSprite.position.x = 280

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
  petSprite.visible = false

  soulSprite1.visible = global.memory["zora_flippers"]
  soulSprite2.visible = global.memory["mole_cricket"]
  soulSprite3.visible = global.memory["mushroom_soul"]
  soulLabel.visible = soulSprite1.visible or soulSprite2.visible or soulSprite3.visible
  var numEggs = global.getThingFromAllLevelZonez("angelEgg")
  angelEggSprite.visible = numEggs > 0
  angelEggLabel.visible = angelEggSprite.visible
  angelEggLabel.bbcode_text = str(numEggs)
  fishKeySprite.visible = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.FISH)) or global.memory["angler_seaman_boss"] == 3
  sporeKeySprite.visible = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.CAT)) or global.memory["baba_yaga_boss"] == 3
  pyramidKeySprite.visible = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.PYRAMID)) or global.memory["dogu_matryoshka_boss"] == 3
  if global.memory["angler_seaman_boss"] == 3:
    fishKeySprite.frame = 25
  if global.memory["baba_yaga_boss"] == 3:
    sporeKeySprite.frame = 24
  if global.memory["dogu_matryoshka_boss"] == 3:
    pyramidKeySprite.frame = 26
  mapAngelSprite.visible = false
  keyLabel.visible = fishKeySprite.visible or sporeKeySprite.visible or pyramidKeySprite.visible or angelEggSprite.visible
  mapCursorSprite.visible = inventoryOptionIndex == 4
  mapCursorSprite2.visible = mapCursorSprite.visible
  # dreamLabel.visible = dreamSprite1.visible or dreamSprite2.visible or dreamSprite3.visible

func forceRedrawMap():
  has_drawn_map = false
  tryDrawMap()

var MAP_WIDTH = 12
var MAP_HEIGHT = 12
var has_drawn_map = false
func tryDrawMap():
  if has_drawn_map:
    return

  map_anglerFishBossSprite.visible = false
  map_babaYagaBossSprite.visible = false
  map_doguBossSprite.visible = false
  map_mushroomSoulSprite.visible = false
  map_cricketSoulSprite.visible = false
  map_fishSoulSprite.visible = false
  map_cryptKeySprite.visible = false
  map_phishingKeySprite.visible = false
  map_sporeKeySprite.visible = false
  var mapGrid = transition.mapManager.gimmeMapGrid()
  var angelStatues = global.getThingArrayFromAllLevelZonez("angel_statue")
  for i in range(MAP_HEIGHT):
    for j in range(MAP_WIDTH):
      var spriteIndex = (j + ((MAP_HEIGHT-1-i)*MAP_WIDTH)) + 1
      var spriteName = MAP_SPRITE_PREFIX + str(spriteIndex)
      var sprite = mapRect.get_node(spriteName) if mapRect.has_node(spriteName) else null
      if sprite == null:
        print("DEBUG: " + spriteName + " doesn't exist")
        continue
      if not mapGrid.has(i) or not mapGrid[i].has(j) or mapGrid[i][j].hide_me_from_map:
        sprite.frame = 0
        continue
      setProperMapFrame(sprite, mapGrid, i, j)
      var mapRoom = mapGrid[i][j]
      if mapRoom.path == level.getLevelName():
        mapPlayerSprite.visible = true
        mapPlayerSprite.position = sprite.position
      elif "Haven" in mapRoom.path or mapRoom.has_angel_statue:
        print(mapRoom.path + ": " + str(getBabushkaCatSniffedVar(mapRoom.path)))
        if getBabushkaCatSniffedVar(mapRoom.path) > 0 or "0_1Haven" in mapRoom.path:
          sprite.frame = 61
          sprite.material.set_shader_param("offset", 11)

        for angelStatue in angelStatues:
          if mapRoom.path == angelStatue[1]:
            if global.memory["angel_flute"]:
              var angelSprite = mapAngelSprite.duplicate()
              sprite.visible = false
              angelSprite.visible = true
              angelSprite.position = sprite.position
              mapAngelSprite.get_parent().add_child(angelSprite)
            else:
              sprite.material.set_shader_param("offset", 6)
      elif "BossRoom" in mapRoom.path and not "preBossRoom" in mapRoom.path:
        if "AnglerFish" in mapRoom.path:
          sprite.frame = 217
          sprite.material.set_shader_param("offset", 0)
          # map_anglerFishBossSprite.visible = true
          # map_anglerFishBossSprite.position = sprite.position
        if "Claydol" in mapRoom.path:
          sprite.frame = 217
          sprite.material.set_shader_param("offset", 0)
          # map_doguBossSprite.visible = true
          # map_doguBossSprite.position = sprite.position
        if "BabaYaga" in mapRoom.path:
          sprite.frame = 217
          sprite.material.set_shader_param("offset", 0)
          # map_babaYagaBossSprite.visible = true
          # map_babaYagaBossSprite.position = sprite.position
      elif mapRoom.has_mole_memory and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 90 if not soulSprite2.visible else 91
        # map_cricketSoulSprite.visible = true
        # map_cricketSoulSprite.position = sprite.position
      elif mapRoom.has_baba_memory and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 90 if not soulSprite3.visible else 91
        # map_mushroomSoulSprite.visible = true
        # map_mushroomSoulSprite.position = sprite.position
      elif mapRoom.has_fish_memory and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 90 if not soulSprite1.visible else 91
        # map_fishSoulSprite.visible = true
        # map_fishSoulSprite.position = sprite.position
      elif mapRoom.has_crypt_key and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 248 if not pyramidKeySprite.visible else 246
        sprite.material.set_shader_param("offset", 1)
        # map_cryptKeySprite.visible = true
        # map_cryptKeySprite.position = sprite.position
      elif mapRoom.has_phishing_key and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 248 if not fishKeySprite.visible else 246
        sprite.material.set_shader_param("offset", 3)
        # map_phishingKeySprite.visible = true
        # map_phishingKeySprite.position = sprite.position
      elif mapRoom.has_spore_key and getBabushkaCatSniffedVar(mapRoom.path) >= 2:
        sprite.frame = 248 if not sporeKeySprite.visible else 246
        sprite.material.set_shader_param("offset", 2)
        # map_sporeKeySprite.visible = true
        # map_sporeKeySprite.position = sprite.position
      
      # if global.memory.has("prev_room") and global.memory["prev_room"] == mapRoom.path:
      #   sprite.material.set_shader_param("offset", 10)
  has_drawn_map = true

func getBabushkaCatSniffedVar(mapRoomPath):
  var tempLevelZone = global.currLevelZone
  global.currLevelZone = global.getLevelZoneName(mapRoomPath)
  var result = global.getLevelZoneThing("babushkaCatSniffed")
  global.currLevelZone = tempLevelZone
  return result if result != null else 0

# optimization could be, rather than reconstructing the map on every level, can keep this map sprite grid on transition, and simply draw it here...
func setProperMapFrame(sprite, mapGrid, i, j):
  var mapRoom = mapGrid[i][j] # guaranteed to already have this room at least by the time that we get here.
  var mapPath = mapRoom.path
  var levelZoneName = global.getLevelZoneName(mapPath)
  var haveIBeenToThisLevel = global.haveIBeenToThisLevelPath(mapPath)
  sprite.frame = 0
  sprite.material = sprite.material.duplicate()
  sprite.z_index = 1
  sprite.material.set_shader_param("palette_out", global.white_palette2d)
  sprite.material.set_shader_param("num_colors", 16)
  if not haveIBeenToThisLevel:
    sprite.material.set_shader_param("offset", 10)
  match levelZoneName:
    "gd1":
        sprite.frame = 231
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 11)
    "gd1TutorialDungeon":
        sprite.frame = 190
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 7)
    "gd1FishingVillage":
        sprite.frame = 245
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 3)
    "gd1ToxicJungle":
        sprite.frame = 95
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 2)
    "gd1ShiftingSandLand":
        sprite.frame = 253
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 1)
    "gd1CrystalTower":
        sprite.frame = 219
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 14)
    "gd1BubblegloopSwamp":
        sprite.frame = 207
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 15)
    "gd1TombSouls":
        sprite.frame = 250
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 12)
    "gd1AbstractSuburbs":
        sprite.frame = 59
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 13)

    "gd1GrandmaVillage":
      sprite.frame = 252
      if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 5)
    "gd1PrimordialOoze":
        sprite.frame = 252
        if haveIBeenToThisLevel: sprite.material.set_shader_param("offset", 5)
    _:
        pass

func setGlitchSprite(sprite, glitch):
  # TODO(jaketrower): dedupe (1) with Player.gd
  if glitch == global.GlitchForm.NORMAL: sprite.frame = 9
  elif glitch == global.GlitchForm.FLOOR: sprite.frame = 1
  elif glitch == global.GlitchForm.FEATHER: sprite.frame = 0
  elif glitch == global.GlitchForm.LADDER: sprite.frame = 2
  elif glitch == global.GlitchForm.INVISIBLE: sprite.frame = 3
  elif glitch == global.GlitchForm.WALK_THROUGH_WALLS: sprite.frame = 9
  elif glitch == global.GlitchForm.BUBBLE: sprite.frame = 4


var topInputOptions = ["Keyboard", "Controller"]
var topInputOptionIndex = 0
func processTopInputLogic(_delta):
  pauseTitleText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to select, " + global.getInputText("menu_cancel") + " to go back"

  if shouldUpdateMenuText:
    var text = ""
    for i in range(len(topInputOptions)):
      var option = topInputOptions[i]

      if i == topInputOptionIndex:
        text += "[wave]" + str(option) + "[/wave]\n" 
      else:
        text += "[color=gray]" + str(option) + "[/color]\n" 
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
      "label_str": "sweep broom",
      "default_keyCode": 88, 
      "button_index": JOY_DS_B,
      "default_button_index": JOY_DS_B,
    },
    {
      "input_action": "restart_key",
      "label_str": "Return to save.",
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
    # {
    #   "input_action": "spell_1",
    #   "label_str": "spell 1",
    #   "default_keyCode": 49, 
    # },
    # {
    #   "input_action": "spell_2",
    #   "label_str": "spell 2",
    #   "default_keyCode": 50, 
    # },
    # {
    #   "input_action": "spell_3",
    #   "label_str": "spell 3",
    #   "default_keyCode": 51, 
    # },
    # {
    #   "input_action": "spell_4",
    #   "label_str": "spell 4",
    #   "default_keyCode": 52, 
    # },
    {
      "input_action": "open_map",
      "label_str": "open map",
      "default_keyCode": 67, 
      "button_index": JOY_L, 
      "default_button_index": JOY_L, 
    },
  ]
  if global.userSettings.has("controls_config") and not global.hasInitializedControlsConfig:
    var rememberedControlsConfig = global.userSettings["controls_config"]
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

func getVisibleControlsConfig():
  var visibleControlsConfig = []
  for controlConfig in controlsConfig:
    var whichInput = controlConfig["input_action"]
    if whichInput == "restart_key" and not global.memory["can_force_respawn"]:
      continue
    if (whichInput == "alt_action_button" or whichInput == "left_button") and not global.memory.has("spellbookPage"):
      continue
    if whichInput == "open_map" and not global.memory["has_map_item"]:
      continue
    visibleControlsConfig.push_back(controlConfig)
  return visibleControlsConfig

onready var inputLabelTextLabel = get_node("InputMenu/ScrollContainer/InputLabels")
onready var buttonInputTextLabel = get_node("InputMenu/ScrollContainer/ButtonInputs")
func processControlsLogic(_delta):
  var tempControlsConfig = getVisibleControlsConfig()

  if global.is_reading_input:
    pauseTitleText.bbcode_text = "press key to set \"" + str(tempControlsConfig[control_index].label_str) + "\""
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
          tempControlsConfig[control_index].key_code = global.last_read_input
          global.setKeyCode(tempControlsConfig[control_index].input_action, global.last_read_input)
          global.userSettings["controls_config"] = tempControlsConfig
          global.is_reading_input = false
          print("hiii")
          global.is_reading_keyboard_input = false
          last_control_index = -1
          level.saveUserSettings()
      elif pauseMenuState == PauseMenuState.CONTROLLER_INPUT:
        if global.last_read_input != JOY_START:
          tempControlsConfig[control_index].button_index = global.last_read_input
          global.setButtonIndex(tempControlsConfig[control_index].input_action, global.last_read_input)
          global.userSettings["controls_config"] = tempControlsConfig
          global.is_reading_input = false
          global.is_reading_controller_input = false
          last_control_index = -1
          level.saveUserSettings()
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

  var showCondensedMenu = true
  var properSize = tempControlsConfig.size()
  if control_index < 0:
    control_index = properSize - 1
  if control_index >= properSize:
    control_index = 0
  if showCondensedMenu:
    cursorSprite.position.y = 100 + (29*control_index)
  else:
    cursorSprite.position.y = 114 + (44*control_index)

  var inputLabelText = ""
  if showCondensedMenu:
    inputLabelText = "[font=res://pauseMenuFontInputCondensed.tres]"
  var buttonInputText = "[font=res://pauseMenuFontInputCondensed.tres][center]"
  for i in range(properSize):
    var controlConfig = tempControlsConfig[i]
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
  if global.is_reading_input and (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("ui_cancel")):
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
        global.userSettings["controls_config"] = controlsConfig
        level.saveUserSettings()
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
        global.userSettings["controls_config"] = controlsConfig
        level.saveUserSettings()
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
