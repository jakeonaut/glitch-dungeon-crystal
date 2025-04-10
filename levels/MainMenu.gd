extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1
onready var broomSound = get_node("BroomSound")
onready var noBroomSound = get_node("NoBroomSound")
onready var startDeleteSound = get_node("StartDeleteSound")
onready var deleteSound = get_node("DeleteSound")
onready var reliefSound = get_node("ReliefSound")
onready var bellSound = get_node("BellSound")

enum MainMenuState {
    MAIN_MENU,
    TRY_DELETE_FILE,
    MAIN_MENU_TRY_QUIT_GAME,
    NORMAL_GAMEPLAY,
}
var mainMenuState = MainMenuState.MAIN_MENU

func setUpRoomInitializationOverride():
    player.mySprite.material_override.set_shader_param("black_offset", 0)
    if not global.has_started_game:
        global.isOnMainMenu = true
        player.normalGlitch()
        player.pauseInput = true
        show_dither_effect = false
        show_crt_effect = true
        mainMenuState = MainMenuState.MAIN_MENU
    else:
        mainMenuState = MainMenuState.NORMAL_GAMEPLAY
        logoSprite.visible = false
        overlayRect.visible = false
        mainMenuUi.visible = false
        show_dither_effect = false
        show_crt_effect = true
        babushkaCat.get_ref().visible = false
        var finalText = tr("NPC.Cow.2")
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
onready var babushkaCat = weakref(get_node("BabushkaCat"))
onready var secretGlitchyNPC = get_node("SecretGlitchyNPC")
onready var secretGlitchyNPC2 = get_node("SecretGlitchyNPC2")
onready var secretGlitchyNPC3 = get_node("SecretGlitchyNPC3")
onready var secretGlitchyNPC4 = get_node("SecretGlitchyNPC4")
onready var secretGlitchyNPC5 = get_node("SecretGlitchyNPC5")
onready var secretGlitchyNPC6 = get_node("SecretGlitchyNPC6")
onready var croneNPC = get_node("CroneNPC")
onready var cowNPC = get_node("NPC2")
onready var door2 = get_node("Door2")
onready var logoSprite = get_node("../../Viewport2/CanvasLayer/LogoSprite")
onready var overlayRect = get_node("OverlayRect")
onready var glitchEnemy6 = get_node("GlitchEnemy6")
onready var colorRect = get_node("../../UILayer/MainMenu/ColorRect")
onready var cameraTarget = get_node("cameraTarget")
onready var dialogPosition = get_node("DialogPosition")

var was_intro_cutscene_skipped = 0
var skip_intro_cutscene_reset_timer = 0
var skip_intro_cutscene_reset_time_limit = 10
func startGame(saveGameIndex):
  global.save_game_index = saveGameIndex
  mainMenuState = MainMenuState.NORMAL_GAMEPLAY
  global.isOnMainMenu = false
  global.resetMemory()
  global.okay_really_really_started_game = false
  global.has_started_game = true
  global.shouldRenderAsCinematic = true
  uiLayer.statsTitleRect.visible = false
  player.pauseInput = true
  player.applyGlitch(global.GlitchForm.NORMAL, true)
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
  overlayRect.visible = false
  mainMenuUi.visible = false
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
#   gameCamera.initial_size = 25
#   gameCamera.zoomed_size = 25
  # gameCamera.can_i_move = false

  yield(get_tree().create_timer(1.5), "timeout")
  if was_intro_cutscene_skipped == 2: return
  gameCamera.can_i_move = false
  player.override_press_move_left = true
  yield(get_tree().create_timer(0.2), "timeout")
  player.override_press_move_left = false
  # player.pauseAnimation = true
  yield(get_tree().create_timer(0.5), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(1.0), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.override_press_move_right = true
  yield(get_tree().create_timer(0.2), "timeout")
  if was_intro_cutscene_skipped == 2: return
  player.override_press_move_right = false
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

  summonSmokeClouds(Vector3(28, 2, 0), 3)
  var cell_index = Vector3(27, 1, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(29, 1, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(28, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(29, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)

  player.exclamationAniPlayer.play("exclaim")
  player.aniPlayer.play("fall")
  eventSound1.play()
  eventSound2.play()
  musicPlayer.stopAll()
  eventSoundWakeup.play()
  secretGlitchyNPC.glitchOut()
  yield(get_tree().create_timer(1.0), "timeout")
  if was_intro_cutscene_skipped == 2: return

  summonSmokeClouds(Vector3(24, 7, 0), 3)
  cell_index = Vector3(24, 6, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(25, 6, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(24, 7, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(25, 7, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)

  secretGlitchyNPC2.glitchOut()
  babushkaCat.get_ref().mySprite.updateBaseFrame(2, 2)
  # babushkaCat.tryShowInteractPrompt(true, true)
  if babushkaCat.get_ref().exclamationAniPlayer != null:
    babushkaCat.get_ref().exclamationAniPlayer.play("exclaim")
  gameCamera.can_i_move = true
  if cameraTarget != null:
    cameraTarget.queue_free()
    cameraTarget = null
  eventSound1.play()
  eventSound2.play()
  yield(get_tree().create_timer(0.4), "timeout")
  secretGlitchyNPC4.glitchOut()
  yield(get_tree().create_timer(0.6), "timeout")
  secretGlitchyNPC3.glitchOut()
  if was_intro_cutscene_skipped == 2: return
  levelTiles.randomize_num = 3
  babushkaCat.get_ref().tryHideActiveInteractPrompt()
  babushkaCat.get_ref().mySprite.flip_h = true
  babushkaCat.get_ref().mySprite.should_randomize_frame_delay = false
  babushkaCat.get_ref().mySprite.frame_delay = 0.1
  babushkaCat.get_ref().override_press_move_right = true
  player.mySprite.flip_h = not player.mySprite.flip_h
  eventSound1.play()
  yield(get_tree().create_timer(0.2), "timeout")
  secretGlitchyNPC5.glitchOut()
  yield(get_tree().create_timer(0.2), "timeout")
  player.mySprite.flip_h = not player.mySprite.flip_h
  secretGlitchyNPC6.glitchOut()

  summonSmokeClouds(Vector3(21.5, 3.5, 0), 3)
  cell_index = Vector3(20, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(21, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(22, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(20, 3, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(22, 3, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(20, 4, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(21, 4, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(22, 4, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)

  yield(get_tree().create_timer(1.6), "timeout")
  player.global_transform.origin = Vector3(26.135, 0, 0)
  player.doBroomAttack(1)
  yield(get_tree().create_timer(0.5), "timeout")
  player.mySprite.flip_h = not player.mySprite.flip_h
  player.grav = 0
  player.global_transform.origin = Vector3(24.635, 2, 0)
  player.doBroomAttack(1)
  yield(get_tree().create_timer(0.5), "timeout")
  player.mySprite.flip_h = not player.mySprite.flip_h
  player.grav = 0
  player.global_transform.origin = Vector3(23.135, 4, 0)
  player.doBroomAttack(1)
  yield(get_tree().create_timer(0.5), "timeout")
  player.grav = 28

  yield(get_tree().create_timer(1.1), "timeout")
  global.shouldRenderAsCinematic = false
  player.pauseInput = false
  global.has_really_started_game = true
  player.textBox.override_target_origin = dialogPosition.global_transform.origin
  player.sayThis(tr("Dialog.Player.1"))

func loadGame(saveGameIndex):
    mainMenuState = MainMenuState.NORMAL_GAMEPLAY
    global.has_started_game = true
    if global.loadGame(saveGameIndex):
        global.has_really_started_game = true
        global.okay_really_really_started_game = true
        global.isRespawning = true
        if global.memory.has("savedRoomPath") or global.memory.has("roomPath"):
            var roomPath = global.memory["savedRoomPath"] if global.memory.has("savedRoomPath") else global.memory["roomPath"]
            global.isEnteringRoom = true
            transition.long_fade_to(roomPath)
            return
    # default
    startGame(saveGameIndex)

func quitGame():
    get_tree().quit()

onready var mainMenuUi = get_node("../../UILayer/MainMenu")
onready var optionsMenuPrompt = get_node("../../UILayer/MainMenu/OptionsMenuPrompt")
onready var selectPrompt = get_node("../../UILayer/MainMenu/SelectPrompt")
onready var selectTextPrompt = get_node("../../UILayer/MainMenu/SelectPrompt/TextPrompt")
onready var menuText = get_node("../../UILayer/MainMenu/MenuText")
onready var pressCText = get_node("../../UILayer/MainMenu/PressC")
onready var deleteConfirmationLayer = get_node("../../UILayer/MainMenu/DeleteConfirmationLayer")
onready var deleteConfirmationLayerText =  get_node("../../UILayer/MainMenu/DeleteConfirmationLayer/PopupRect/ColorRect/ColorRect/RichTextLabel")
onready var skipPrompt = get_node("../../UILayer/SkipPrompt")
var hideSkipPromptTimer = 0
var hideSkipPromptTimeLimit = 15

export var camera_size = 30
var mainMenuPromptIndex = 0
var updateMenuText = true
var has_reset_transition = false
func _process(delta):
    if not transition.aniPlayer.is_playing() and not has_reset_transition:
        transition.colorRect.rect_position = Vector2(320, 28)
        transition.colorRect.rect_size = Vector2(1280, 1024)
        has_reset_transition = true
    if mainMenuState == MainMenuState.TRY_DELETE_FILE:
        deleteConfirmationLayer.visible = true
        if deleteConfirmationLayerText.bbcode_text == "":
            deleteConfirmationLayerText.bbcode_text = tr("UI.MainMenu.5") % [str(mainMenuPromptIndex + 1), global.getInputText("menu_confirm"), global.getInputText("menu_cancel")]
        if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
            if global.doesSaveGameExist(mainMenuPromptIndex):
                global.tryDeleteGame(mainMenuPromptIndex)
            mainMenuState = MainMenuState.MAIN_MENU
            deleteSound.play()
            updateMenuText = true
        elif Input.is_action_just_pressed("menu_cancel"):
            mainMenuState = MainMenuState.MAIN_MENU
            reliefSound.play()
            broomSound.play()
        elif Input.is_action_just_pressed("menu_delete"):
            noBroomSound.play()
        return
    deleteConfirmationLayer.visible = false
    deleteConfirmationLayerText.bbcode_text = ""

    if mainMenuState == MainMenuState.NORMAL_GAMEPLAY:
        if global.has_started_game and not global.isRespawning:
            player.camera_y_offset = 5
            if global.has_really_started_game:
                gameCamera.initial_size = gameCamera.initial_size + (25 - gameCamera.initial_size) * (delta * 2)
                gameCamera.zoomed_size = gameCamera.initial_size
                # pressCText.rect_position.x = 214
                # pressCText.rect_position.y = 515
                if pressCText.get_parent() == mainMenuUi and not global.memory.has("roomPath"):
                    mainMenuUi.remove_child(pressCText)
                    uiLayer.add_child(pressCText)
                    pressCText.rect_position = Vector2(16, 465)
                    pressCText.rect_size = Vector2(712, 101)
                    mainMenuUi.remove_child(optionsMenuPrompt)
                    uiLayer.add_child(optionsMenuPrompt)
                    optionsMenuPrompt.rect_position.y = 16
                pressCText.bbcode_text = tr("UI.Tutorial.InputPrompt.1") % [global.getInputText("sub_action_button"), global.getInputText("jump_button"), global.getInputText("ui_left"), global.getInputText("ui_right")]
                pressCText.visible = (global.activeInteractor == null and not global.isPauseMenuOpen and not global.shouldRenderAsCinematic)
                optionsMenuPrompt.bbcode_text = tr("UI.MainMenu.1") % global.getInputText("ui_start")
                optionsMenuPrompt.visible = pressCText.visible
            else:
                gameCamera.initial_size = gameCamera.initial_size + (15 - gameCamera.initial_size) * (delta * 2)
                gameCamera.zoomed_size = gameCamera.initial_size
                processSkipPrompt(delta)
            return

    if global.isPauseMenuOpen or global.has_started_game:
        mainMenuUi.visible = false
        return

    if mainMenuState == MainMenuState.MAIN_MENU:
        player.camera_y_offset = -20
        gameCamera.initial_size = camera_size
        gameCamera.zoomed_size = camera_size
        gameCamera.size = camera_size
        mainMenuUi.visible = true
        if mainMenuState == MainMenuState.MAIN_MENU_TRY_QUIT_GAME:
            pressCText.bbcode_text = "[right]press " + global.getInputText("menu_cancel") + " to cancel, " + global.getInputText("menu_confirm") + " to start[/right]"
        else:
            var secondPartTemp = tr("UI.MainMenu.4") % global.getInputText("menu_delete")
            var second_part = secondPartTemp if global.doesSaveGameExist(mainMenuPromptIndex) else ("[s][color=gray]" + secondPartTemp + "[/color][/s]")
            pressCText.bbcode_text = "[right]" + (tr("UI.MainMenu.3") % global.getInputText("menu_confirm")) + "    " + second_part + "[/right]"
        optionsMenuPrompt.bbcode_text = tr("UI.MainMenu.1") % global.getInputText("ui_start")
        selectTextPrompt.bbcode_text = global.getInputText("menu_confirm")

        if Input.is_action_just_pressed("menu_down"):
            uiLayer.pauseMenu.menuMoveSound.play()
            normalizeMainMenuPromptIndex(1)
            updateMenuText = true
        elif Input.is_action_just_pressed("menu_up"):
            uiLayer.pauseMenu.menuMoveSound.play()
            normalizeMainMenuPromptIndex(-1)
            updateMenuText = true

        if mainMenuPromptIndex == 0:
            player.applyGlitch(global.GlitchForm.NORMAL, true)
        if mainMenuPromptIndex == 1:
            player.applyGlitch(global.GlitchForm.FEATHER, true)
        if mainMenuPromptIndex == 2:
            player.applyGlitch(global.GlitchForm.FLOOR, true)

        selectPrompt.rect_position.y = 354.5 + (mainMenuPromptIndex*55)
        if updateMenuText:
            menuText.bbcode_text = ""
            for i in range(global.save_game_files.size()):
                if i != 0: menuText.bbcode_text += "\n"

                var fileText = (tr("UI.MainMenu.2") + str(i+1)) if global.doesSaveGameExist(i) else ("[color=gray]" + tr("UI.MainMenu.2_2") + str(i+1) + "[/color]")
                if mainMenuPromptIndex == i:
                    menuText.bbcode_text += "[wave]" + fileText + "[/wave]"
                else:
                    menuText.bbcode_text += fileText
        updateMenuText = false

        if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
            bellSound.play()
            if global.doesSaveGameExist(mainMenuPromptIndex):
                loadGame(mainMenuPromptIndex)
            else:
                startGame(mainMenuPromptIndex)
        elif Input.is_action_just_pressed("menu_delete"):
            if global.doesSaveGameExist(mainMenuPromptIndex):
                mainMenuState = MainMenuState.TRY_DELETE_FILE
                startDeleteSound.play()
            else:
                noBroomSound.play()
    
# @override
# func processPauseMenu():
#     pass

func processSkipPrompt(delta):
    var which_input_to_skip = "popup_menu"
    skipPrompt.bbcode_text = tr("UI.MainMenu.3") % global.getInputText(which_input_to_skip)
    if (
        Input.is_action_just_pressed("ui_right") or
        Input.is_action_just_pressed("ui_left") or
        Input.is_action_just_pressed("ui_up") or
        Input.is_action_just_pressed("ui_down") or
        Input.is_action_just_pressed("jump_button") or
        Input.is_action_just_pressed("sub_action_button") or
        Input.is_action_just_pressed("alt_action_button") or
        Input.is_action_just_pressed("left_button") or
        Input.is_action_just_pressed("restart_key") or 
        Input.is_action_just_pressed("ui_right") or
        Input.is_action_just_pressed("open_map") or
        Input.is_action_just_pressed("ui_cancel") or
        Input.is_action_just_pressed("ui_cancel_controller") or
        Input.is_action_just_pressed("ui_start")
    ) and not Input.is_action_just_pressed(which_input_to_skip):
        skipPrompt.visible = true
        hideSkipPromptTimer = 0
    if not skipPrompt.visible:
        if Input.is_action_just_pressed(which_input_to_skip):
            skipPrompt.visible = true
            hideSkipPromptTimer = 0
    else:
        if Input.is_action_just_pressed(which_input_to_skip):
            skipPrompt.visible = false
            was_intro_cutscene_skipped = 2
            player.grav = 28
            global.shouldRenderAsCinematic = false
            player.pauseInput = false
            global.has_really_started_game = true
            player.textBox.override_target_origin = dialogPosition.global_transform.origin
            player.sayThis(tr("Dialog.Player.1"))
            levelTiles.randomize_num = 3
            if musicPlayer.currentlyPlayingTheme != null:
                musicPlayer.stopAll()
                eventSoundWakeup.play()
            if babushkaCat.get_ref():
                if not babushkaCat.get_ref().override_press_move_right:
                    babushkaCat.get_ref().mySprite.updateBaseFrame(2, 2)
                    # babushkaCat.tryShowInteractPrompt(true, true)
                    if babushkaCat.get_ref().exclamationAniPlayer != null:
                        babushkaCat.get_ref().exclamationAniPlayer.play("exclaim")
                    babushkaCat.get_ref().mySprite.flip_h = true
                    babushkaCat.get_ref().mySprite.should_randomize_frame_delay = false
                    babushkaCat.get_ref().mySprite.frame_delay = 0.1
                    babushkaCat.get_ref().override_press_move_right = true
                # yield(get_tree().create_timer(1.0), "timeout")
                # if babushkaCat.get_ref(): babushkaCat.get_ref().glitchOut()
        else:
            hideSkipPromptTimer += (delta*11)
            if hideSkipPromptTimer >= hideSkipPromptTimeLimit:
                hideSkipPromptTimer = 0
                skipPrompt.visible = false

func normalizeMainMenuPromptIndex(change):
    mainMenuPromptIndex += change
    if mainMenuPromptIndex > 2:
        mainMenuPromptIndex = 0
    if mainMenuPromptIndex < 0:
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
