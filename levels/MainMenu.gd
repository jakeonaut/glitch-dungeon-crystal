extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1
onready var broomSound = get_node("BroomSound")

var epilepsy_fade_timer = 0
var EPILEPSY_SHOW_TIME_LIMIT = 120
var epilepsy_cover_opacity = 1
enum MainMenuState {
    SHOWING_EPILEPSY_WARNING,
    HIDING_EPILEPSY_WARNING,
    MAIN_MENU,
    NORMAL_GAMEPLAY,
}
var mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
onready var epilepsyWarning = get_node("../../UILayer/EpilepsyWarning")
onready var epilepsyWarningCoverup = get_node("../../UILayer/EpilepsyWarning/Coverup")
onready var epilepsyWarningSprite = get_node("../../UILayer/EpilepsyWarning/Sprite")
onready var epilepsyWarningText = get_node("../../UILayer/EpilepsyWarning/Text")
func tryInitializeFromDebug():
  if global.memory["initialized_from_debug"]:
    epilepsyWarning.visible = false
    mainMenuState = MainMenuState.NORMAL_GAMEPLAY
  else:
    mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
    epilepsyWarning.visible = true

func setUpRoomInitializationOverride():
    if not global.has_started_game:
        global.isOnMainMenu = true
        player.normalGlitch()
        player.pauseInput = true
        show_dither_effect = false
        show_crt_effect = true
    else:
        mainMenuState = MainMenuState.NORMAL_GAMEPLAY
        logoSprite.visible = false
        mainMenuUi.visible = false
        show_dither_effect = false
        show_crt_effect = true
        babushkaCat.visible = false
        var finalText = "*moo* (nice of you to stop by.\ni'm taking care of the\nfarm while you're gone)"
        cowNPC.textBox.text_final = finalText
        cowNPC.textBox.textNode.bbcode_text = finalText
    if global.pauseGame:
        transition.reverse_fade()

onready var eventSoundWakeup = get_node("EventSoundWakeup")
onready var eventSound1 = get_node("EventSound1")
onready var eventSound2 = get_node("EventSound2")
onready var eventSound3 = get_node("EventSound3")
onready var glitchMoleCricket = get_node("GlitchMoleCricket")
onready var glitchMoleCricket2 = get_node("GlitchMoleCricket2")
onready var glitchMoleCricket3 = get_node("GlitchMoleCricket3")
onready var babushkaCat = get_node("BabushkaCat")
onready var croneNPC = get_node("CroneNPC")
onready var cowNPC = get_node("NPC2")
onready var door2 = get_node("Door2")
onready var logoSprite = get_node("../../Viewport2/CanvasLayer/LogoSprite")
onready var glitchEnemy6 = get_node("GlitchEnemy6")
onready var colorRect = get_node("../../UILayer/MainMenu/ColorRect")
onready var cameraTarget = get_node("cameraTarget")

var was_intro_cutscene_skipped = 0
var skip_intro_cutscene_reset_timer = 0
var skip_intro_cutscene_reset_time_limit = 10
func startGame():
  global.isOnMainMenu = false
  global.resetMemory()
#   show_dither_effect = false
#   show_crt_effect = true
  global.okay_really_really_started_game = false
  global.has_started_game = true
  global.shouldRenderAsCinematic = true
  uiLayer.statsTitleRect.visible = false
  player.pauseInput = true
  uiLayer.glitchSprite.visible = false
  uiLayer.get_node("GlitchStatusRect").visible = false
  if global.memory["demo_mode"] > 0:
    global.has_started_game = true
    global.has_really_started_game = true
    global.pauseGame = false
    transition.really_long_fade_to("res://levels/EndlessFantasy/gd1TutorialDungeon/0_0.tscn")
    global.isRespawning = true
    return
  logoSprite.visible = false
  mainMenuUi.visible = false
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  gameCamera.initial_size = 25
  gameCamera.zoomed_size = 25
  # gameCamera.can_i_move = false

  yield(get_tree().create_timer(1.5), "timeout")
  if was_intro_cutscene_skipped == 2: return
  gameCamera.can_i_move = false
  player.override_press_move_right = true
  yield(get_tree().create_timer(0.2), "timeout")
  player.override_press_move_right = false
  # player.pauseAnimation = true
  yield(get_tree().create_timer(0.5), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(1.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.override_press_move_left = true
  yield(get_tree().create_timer(0.1), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.override_press_move_left = false
  yield(get_tree().create_timer(0.5), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(2.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  player.aniPlayer.play("happyStand")
  yield(get_tree().create_timer(2.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.aniPlayer.play("fall")
  eventSound1.play()
  eventSound2.play()
  musicPlayer.stopAll()
  eventSoundWakeup.play()
  yield(get_tree().create_timer(1.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  babushkaCat.mySprite.updateBaseFrame(2, 2)
  gameCamera.can_i_move = true
  if cameraTarget != null:
    cameraTarget.queue_free()
    cameraTarget = null
  eventSound1.play()
  eventSound2.play()
  yield(get_tree().create_timer(1.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  levelTiles.randomize_num = 3
  babushkaCat.mySprite.flip_h = true
  babushkaCat.mySprite.should_randomize_frame_delay = false
  babushkaCat.mySprite.frame_delay = 0.1
  babushkaCat.override_press_move_right = true
  player.mySprite.flip_h = not player.mySprite.flip_h
  eventSound1.play()
  yield(get_tree().create_timer(2.0), "timeout")
  global.shouldRenderAsCinematic = false
  player.pauseInput = false
  global.has_really_started_game = true

func loadGame():
    global.has_started_game = true
    if global.loadGame():
        global.has_really_started_game = true
        global.okay_really_really_started_game = true
        global.isRespawning = true
        if global.memory.has("roomPath"):
            var roomPath = global.memory["roomPath"]
            global.isEnteringRoom = true
            transition.long_fade_to(roomPath)
            return
    # default
    startGame()

func quitGame():
    get_tree().quit()

onready var mainMenuUi = get_node("../../UILayer/MainMenu")
onready var optionsMenuPrompt = get_node("../../UILayer/MainMenu/OptionsMenuPrompt")
onready var selectPrompt = get_node("../../UILayer/MainMenu/SelectPrompt")
onready var selectTextPrompt = get_node("../../UILayer/MainMenu/SelectPrompt/TextPrompt")
onready var menuText = get_node("../../UILayer/MainMenu/MenuText")
onready var pressCText = get_node("../../UILayer/MainMenu/PressC")
onready var skipText = get_node("../../UILayer/SkipText")

export var camera_size = 30
var mainMenuPromptIndex = 0
var updateMenuText = true
func _process(delta):
    if mainMenuState == MainMenuState.SHOWING_EPILEPSY_WARNING or mainMenuState == MainMenuState.HIDING_EPILEPSY_WARNING:
        if mainMenuState == MainMenuState.SHOWING_EPILEPSY_WARNING:
            epilepsy_cover_opacity -= (delta)
            if epilepsy_cover_opacity < 0:
                epilepsy_cover_opacity = 0
                epilepsy_fade_timer += (delta*11)
                if epilepsy_fade_timer >= EPILEPSY_SHOW_TIME_LIMIT or (
                    Input.is_action_just_pressed("sub_action_button") or \
                    Input.is_action_just_pressed("jump_button") or \
                    Input.is_action_just_pressed("ui_start") or \
                    (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))
                ):
                    mainMenuState = MainMenuState.HIDING_EPILEPSY_WARNING
                    transition.aniPlayer.stop()
                    transition.aniPlayer.play("long_fade_no_change")
        elif mainMenuState == MainMenuState.HIDING_EPILEPSY_WARNING:
            epilepsy_cover_opacity += (delta)
            if epilepsy_cover_opacity >= 1:
                epilepsy_cover_opacity = 1
                transition.reverse_fade()
                epilepsyWarning.visible = false
                mainMenuState = MainMenuState.MAIN_MENU
        epilepsyWarningCoverup.color = Color(0, 0, 0, epilepsy_cover_opacity)
        return


    if not global.has_started_game:
        player.camera_y_offset = -20
        gameCamera.initial_size = camera_size
        gameCamera.zoomed_size = camera_size
        gameCamera.size = camera_size
        mainMenuUi.visible = not global.isPauseMenuOpen
        pressCText.bbcode_text = "press " + global.getInputText("menu_confirm") + " to start"
        optionsMenuPrompt.bbcode_text = "Press " + global.getInputText("ui_start") + " for OPTIONS"
        selectTextPrompt.bbcode_text = global.getInputText("menu_confirm")

    # if uiLayer.title_display_state == 3:
    #     uiLayer.title_display_state = 0
    # uiLayer.setDisplayTitle("press " + global.getInputText("sub_action_button"))

    # .process(delta) implicit
    # player.rotation_degrees.y += (delta)*direction
    # if player.rotation_degrees.y > 5:
    #     direction = -1
    # elif player.rotation_degrees.y < -5:
    #     direction = 1

    if mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
        mainMenuPromptIndex = 1
        colorRect.visible = false

    if global.has_started_game and not global.isRespawning:
        player.camera_y_offset = 5
        if global.has_really_started_game:
            if pressCText.get_parent() == mainMenuUi and not global.memory.has("roomPath"):
                mainMenuUi.remove_child(pressCText)
                uiLayer.add_child(pressCText)
                pressCText.rect_position = Vector2(16, 465)
                pressCText.rect_size = Vector2(712, 101)
                mainMenuUi.remove_child(optionsMenuPrompt)
                uiLayer.add_child(optionsMenuPrompt)
                optionsMenuPrompt.rect_position.y = 16
            var is_controller_connected = Input.get_connected_joypads().size() > 0
            pressCText.bbcode_text = global.getInputText("sub_action_button") + " to Sweep. " + global.getInputText("jump_button") + " to Jump. " + global.getInputText("ui_left")  + global.getInputText("ui_right") + " to walk"
            pressCText.visible = (global.activeInteractor == null and not global.isPauseMenuOpen)
            optionsMenuPrompt.bbcode_text = "Press " + global.getInputText("ui_start") + " for OPTIONS"
            optionsMenuPrompt.visible = pressCText.visible
        return

    if global.isPauseMenuOpen or mainMenuState != MainMenuState.MAIN_MENU:
        return

    if Input.is_action_just_pressed("menu_down"):
        uiLayer.pauseMenu.menuMoveSound.play()
        normalizeMainMenuPromptIndex(1)
        updateMenuText = true
    elif Input.is_action_just_pressed("menu_up"):
        uiLayer.pauseMenu.menuMoveSound.play()
        normalizeMainMenuPromptIndex(-1)
        updateMenuText = true

    selectPrompt.rect_position.y = 354.5 + (mainMenuPromptIndex*55)
    if mainMenuPromptIndex == 0 and updateMenuText:
        menuText.bbcode_text = "[wave]Continue...?[/wave]\n\nNew Game\n\nQUIT!!! bye."
    elif mainMenuPromptIndex == 1 and updateMenuText:
        if global.doesSaveGameExist():
            menuText.bbcode_text = "Continue...?\n\n[wave]New Game[/wave]\n\nQUIT!!! bye."
        else:
            menuText.bbcode_text = "\n\n[wave]New Game[/wave]\n\nQUIT!!! bye."
    elif mainMenuPromptIndex == 2 and updateMenuText:
        if global.doesSaveGameExist():
            menuText.bbcode_text = "Continue...?\n\nNew Game\n\n[wave]QUIT!!! bye.[/wave]"
        else:
            menuText.bbcode_text = "\n\nNew Game\n\n[wave]QUIT!!! bye.[/wave]"
    updateMenuText = false


    # switch_glitch_timer += (delta*22)
    # if switch_glitch_timer >= switch_glitch_time_limit:
    #     switch_glitch_timer = 0
    #     player.applyNextGlitch()

    if (Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))) and not global.has_started_game:
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if mainMenuPromptIndex == 0:
            broomSound.play()
            loadGame()
        elif mainMenuPromptIndex == 1:
            broomSound.play()
            startGame()
        else:
            quitGame()

# @override
# func processPauseMenu():
#     pass

func normalizeMainMenuPromptIndex(change):
    mainMenuPromptIndex += change

    if mainMenuPromptIndex > 2:
        mainMenuPromptIndex = 0
    if mainMenuPromptIndex < 0:
        mainMenuPromptIndex = 2

    if change > 0 and mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
        mainMenuPromptIndex = 1
    if change < 0 and mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
        mainMenuPromptIndex = 2

var has_ever_started_music = false
# @override
func playMenuMusic():
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    pass
    
# @override
func restartMusic():
    if not has_ever_started_music:
        musicPlayer.conductFromScenePath(getLevelName())
        has_ever_started_music = true
