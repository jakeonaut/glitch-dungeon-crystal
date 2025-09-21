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
onready var towerSprite1 = get_node("TowerSprite1")
onready var towerSprite2 = get_node("TowerSprite2")

enum MainMenuState {
    MAIN_MENU,
    TRY_DELETE_FILE,
    TRY_GO_CREDITS,
    MAIN_MENU_TRY_QUIT_GAME,
    NORMAL_GAMEPLAY,
    TRY_CONTINUE,
}
var mainMenuState = MainMenuState.MAIN_MENU

func setUpRoomInitializationOverride():
    for sprite in [player.mySprite, player.grandmaHatSprite, player.grandmaHandSprite]:
        sprite.material_override.set_shader_param("black_offset", 0)
    if not global.has_started_game:
        global.isOnMainMenu = true
        player.normalGlitch()
        player.pauseInput = true
        show_dither_effect = false
        show_crt_effect = true
        mainMenuState = MainMenuState.MAIN_MENU
        logoSprite.visible = true
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
        if global.memory["clean_crystals"] >= 4:
            towerSprite1.visible = true
            towerSprite2.visible = true
    if global.pauseGame:
        transition.reverse_fade()
    uiLayer.remove_child(uiLayer.textBoxes)
    uiLayer.add_child(uiLayer.textBoxes)

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
onready var demoSprite = get_node("../../Viewport2/CanvasLayer/LogoSprite/DemoSprite")
var logoTex2 = preload("res://assets/sprites/logo2.png")
var logoTex3 = preload("res://assets/sprites/logo3.png")
var logo_default_pos = Vector2(308, 750)
var logo_min_pos = Vector2(308, 154)
var logo_max_pos = Vector2(980, 816)
var logo_dir = Vector2(2, 2)
var logo_timer = 0
var logo_time_limit = 360
onready var overlayRect = get_node("OverlayRect")
onready var glitchEnemy6 = get_node("GlitchEnemy6")
onready var colorRect = get_node("../../Viewport2/UILayer/MainMenu/ColorRect")
onready var cameraTarget = get_node("cameraTarget")
onready var dialogPosition = get_node("DialogPosition")

var saved_games_cache = null
func getAndCacheSavedGames():
    if saved_games_cache == null:
        saved_games_cache = [
            global.loadGame(0, {}) if global.doesSaveGameExist(0) else {},
            global.loadGame(1, {}) if global.doesSaveGameExist(1) else {},
            global.loadGame(2, {}) if global.doesSaveGameExist(2) else {},
            global.loadGame(3, {}) if global.doesSaveGameExist(3) else {},
        ]
    return saved_games_cache

var was_intro_cutscene_skipped = 0
var skip_intro_cutscene_reset_timer = 0
var skip_intro_cutscene_reset_time_limit = 10
func startGame(saveGameIndex, shouldResetMemory = true):
  global.save_game_index = saveGameIndex
  mainMenuState = MainMenuState.NORMAL_GAMEPLAY
  global.isOnMainMenu = false
  if shouldResetMemory:
    global.resetMemory()
  global.okay_really_really_started_game = false
  global.has_started_game = true
  global.setLevelZoneStartTime()
  global.shouldRenderAsCinematic = true
  uiLayer.statsTitleRect.visible = false
  player.pauseInput = true
  player.applyGlitch(global.GlitchForm.NORMAL, true)
  uiLayer.glitchSprite.visible = false
  uiLayer.get_node("GlitchStatusRect").visible = false
  if player.sleepy_timer >= player.sleepy_time_limit:
    player.exclamationAniPlayer.play("exclaim")
    player.aniPlayer.play("fall")
  player.sleepy_time_limit *= 2
  if global.display_mode > 0:
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

  summonSmokeClouds(Vector3(21.5, 3.5, 0), 3)
  var cell_index = Vector3(20, 2, 0)
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
  babushkaCat.get_ref().override_press_jump = true
  player.mySprite.flip_h = not player.mySprite.flip_h
  eventSound1.play()
  yield(get_tree().create_timer(0.2), "timeout")
  secretGlitchyNPC5.glitchOut()
  yield(get_tree().create_timer(0.2), "timeout")
  player.mySprite.flip_h = not player.mySprite.flip_h
  secretGlitchyNPC6.glitchOut()
  babushkaCat.get_ref().override_press_jump = false

  summonSmokeClouds(Vector3(28, 2, 0), 3)
  cell_index = Vector3(27, 1, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(29, 1, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(28, 2, 0)
  levelTiles.set_cell_item(cell_index.x, cell_index.y, cell_index.z, 51)
  cell_index = Vector3(29, 2, 0)
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

func newGamePlus(saveGameIndex):
    mainMenuState = MainMenuState.NORMAL_GAMEPLAY
    global.has_started_game = true
    if global.loadGame(saveGameIndex):
        global.has_really_started_game = true
        global.okay_really_really_started_game = true
        global.newGamePlusMemoryReset()
        global.setLevelZoneThing("start_time", null)
    # default
    startGame(saveGameIndex, false)

func loadGame(saveGameIndex):
    mainMenuState = MainMenuState.NORMAL_GAMEPLAY
    global.has_started_game = true
    if global.loadGame(saveGameIndex):
        global.has_really_started_game = true
        global.okay_really_really_started_game = true
        global.isRespawning = true
        global.setLevelZoneThing("start_time", null)
        if global.memory.has("savedRoomPath") or global.memory.has("roomPath"):
            var roomPath = global.memory["savedRoomPath"] if global.memory.has("savedRoomPath") else global.memory["roomPath"]
            global.isEnteringRoom = true
            transition.long_fade_to(roomPath)
            return
    # default
    startGame(saveGameIndex)

func quitGame():
    get_tree().quit()

onready var mainMenuUi = get_node("../../Viewport2/UILayer/MainMenu")
onready var optionsMenuPrompt = get_node("../../Viewport2/UILayer/MainMenu/OptionsMenuPrompt")
onready var selectPrompt = get_node("../../Viewport2/UILayer/MainMenu/SelectPrompt")
onready var selectTextPrompt = get_node("../../Viewport2/UILayer/MainMenu/SelectPrompt/TextPrompt")
onready var menuText = get_node("../../Viewport2/UILayer/MainMenu/MenuText")
onready var pressCText = get_node("../../Viewport2/UILayer/MainMenu/PressC")
onready var deleteConfirmationLayer = get_node("../../Viewport2/UILayer/MainMenu/DeleteConfirmationLayer")
onready var deleteConfirmationLayerText =  get_node("../../Viewport2/UILayer/MainMenu/DeleteConfirmationLayer/PopupRect/ColorRect/ColorRect/RichTextLabel")
onready var skipPrompt = get_node("../../Viewport2/UILayer/SkipPrompt")
var hideSkipPromptTimer = 0
var hideSkipPromptTimeLimit = 15

# @override
func canOpenPauseMenu():
  return mainMenuState != MainMenuState.TRY_DELETE_FILE and mainMenuState != MainMenuState.TRY_GO_CREDITS

export var camera_size = 30
var updateMenuText = true
var has_reset_transition = false
func _process(delta):
    global.isEndOfGame = false
    if not transition.aniPlayer.is_playing() and not has_reset_transition:
        transition.colorRect.rect_position = Vector2(320, 28)
        transition.colorRect.rect_size = Vector2(1280, 1024)
        has_reset_transition = true
    if mainMenuState == MainMenuState.TRY_DELETE_FILE:
        deleteConfirmationLayer.visible = true
        if deleteConfirmationLayerText.bbcode_text == "":
            deleteConfirmationLayerText.bbcode_text = tr("UI.MainMenu.5") % [str(global.mainMenuPromptIndex + 1), global.getInputText("menu_confirm"), global.getInputText("menu_cancel")]
        if (Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))) and not Input.is_action_pressed("menu_delete"):
            if global.doesSaveGameExist(global.mainMenuPromptIndex):
                global.tryDeleteGame(global.mainMenuPromptIndex)
            mainMenuState = MainMenuState.MAIN_MENU
            deleteSound.play()
            updateMenuText = true
        elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
            reliefSound.play()
            broomSound.play()
            yield(get_tree().create_timer(0.15), "timeout")
            mainMenuState = MainMenuState.MAIN_MENU
        elif Input.is_action_just_pressed("menu_delete"):
            noBroomSound.play()
        return
    elif mainMenuState == MainMenuState.TRY_GO_CREDITS:
        deleteConfirmationLayer.visible = true
        if deleteConfirmationLayerText.bbcode_text == "":
            deleteConfirmationLayerText.bbcode_text = tr("UI.MainMenu.CreditsPrompt") + " " + tr("UI.MainMenu.CreditsConfirm") % [global.getInputText("menu_confirm"), global.getInputText("menu_cancel")]
        if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
            global.has_really_started_game = true
            global.okay_really_really_started_game = true
            global.isEnteringRoom = true
            transition.long_fade_to("res://levels/EndlessFantasy/gd1/EndCredits.tscn")
            global.isRespawning = true
        elif Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
            reliefSound.play()
            broomSound.play()
            yield(get_tree().create_timer(0.15), "timeout")
            mainMenuState = MainMenuState.MAIN_MENU
        elif Input.is_action_just_pressed("menu_delete"):
            noBroomSound.play()
        return
    deleteConfirmationLayer.visible = false
    deleteConfirmationLayerText.bbcode_text = ""

    if mainMenuState == MainMenuState.NORMAL_GAMEPLAY:
        if global.has_started_game and not global.isRespawning:
            player.camera_y_offset = 5
            if global.has_really_started_game:
                skipPrompt.visible = false
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
        global.spellCastPauseIndex = 0
        player.spellCastPauseIndex = 0
        demoSprite.visible = global.demo_mode > 0
        player.camera_y_offset = -20
        gameCamera.initial_size = camera_size
        gameCamera.zoomed_size = camera_size
        gameCamera.size = camera_size
        mainMenuUi.visible = true
        if mainMenuState == MainMenuState.MAIN_MENU_TRY_QUIT_GAME:
            pressCText.bbcode_text = "[right]press " + global.getInputText("menu_cancel") + " to cancel, " + global.getInputText("menu_confirm") + " to start[/right]"
        else:
            var secondPartTemp = tr("UI.MainMenu.4") % global.getInputText("menu_delete")
            var second_part = secondPartTemp if global.doesSaveGameExist(global.mainMenuPromptIndex) else ("[color=grey]" + secondPartTemp + "[/color]")
            pressCText.bbcode_text = "[right]" + (tr("UI.MainMenu.3") % global.getInputText("menu_confirm")) + "    " + second_part + "[/right]"
        optionsMenuPrompt.bbcode_text = (tr("UI.MainMenu.1") % global.getInputText("ui_start")) + "\n[right]" + (global.getInputText("menu_cancel")) + ": " + tr("UI.MainMenu.CreditsPrompt") + "[/right]"
        selectTextPrompt.bbcode_text = global.getInputText("menu_confirm")

        if player.justPressedMenuDown():
            jostlePlayer()
            uiLayer.pauseMenu.menuMoveSound.play()
            normalizeMainMenuPromptIndex(1)
            updateMenuText = true
            if logo_timer < logo_time_limit:
                logo_timer = 0
        elif player.justPressedMenuUp():
            jostlePlayer()
            uiLayer.pauseMenu.menuMoveSound.play()
            normalizeMainMenuPromptIndex(-1)
            updateMenuText = true
            if logo_timer < logo_time_limit:
                logo_timer = 0
        else:
            pass
            # logo_timer += (delta*11)
            # if logo_timer >= logo_time_limit:
            #     logoSprite.position += logo_dir
            #     var should_toggle_color = false
            #     if logoSprite.position.x >= logo_max_pos.x:
            #         logoSprite.position.x = logo_max_pos.x
            #         logo_dir.x *= -1
            #         should_toggle_color = true
            #     elif logoSprite.position.x <= logo_min_pos.x:
            #         logoSprite.position.x = logo_min_pos.x
            #         logo_dir.x *= -1
            #         should_toggle_color = true
            #     if logoSprite.position.y >= logo_max_pos.y:
            #         logoSprite.position.y = logo_max_pos.y
            #         logo_dir.y *= -1
            #         should_toggle_color = true
            #     if logoSprite.position.y <= logo_min_pos.y:
            #         logoSprite.position.y = logo_min_pos.y
            #         logo_dir.y *= -1
            #         should_toggle_color = true
            #     if should_toggle_color:
            #         if logoSprite.texture == logoTex2:
            #             logoSprite.texture = logoTex3
            #         else:
            #             logoSprite.texture = logoTex2
        
        var temp = getAndCacheSavedGames()[global.mainMenuPromptIndex]
        player.changeOutfit(temp["currOutfit"] if temp.has("currOutfit") else global.GrandmaOutfit.BABUSHKA, false)
        
        if global.mainMenuPromptIndex == 0:
            player.applyGlitch(global.GlitchForm.NORMAL, true)
        if global.mainMenuPromptIndex == 1:
            player.applyGlitch(global.GlitchForm.FEATHER, true)
        if global.mainMenuPromptIndex == 2:
            player.applyGlitch(global.GlitchForm.FLOOR, true)
        if global.mainMenuPromptIndex == 3:
            player.applyGlitch(global.GlitchForm.LADDER, true)

        selectPrompt.rect_position.y = 300.5 + (global.mainMenuPromptIndex*55)
        if updateMenuText:
            menuText.bbcode_text = ""
            for i in range(global.save_game_files.size()):
                if i != 0: menuText.bbcode_text += "\n"

                var fileText = (tr("UI.MainMenu.2") + str(i+1)) if global.doesSaveGameExist(i) else ("[color=teal]" + tr("UI.MainMenu.2") + str(i+1) + "[/color]")
                if global.mainMenuPromptIndex == i:
                    menuText.bbcode_text += "[wave]" + fileText + "[/wave]"
                else:
                    menuText.bbcode_text += fileText
        updateMenuText = false

        if Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
            if global.doesSaveGameExist(global.mainMenuPromptIndex):
                # if global.loadGame(global.mainMenuPromptIndex, {})["has_beat_the_game"]:
                #     mainMenuState = MainMenuState.TRY_CONTINUE
                #     mainMenuUi.visible = false
                #     player.sayThis(tr("UI.NewGame.Plus"), 0.0, true)
                # else:
                bellSound.play()
                loadGame(global.mainMenuPromptIndex)
            else:
                startGame(global.mainMenuPromptIndex)
        elif Input.is_action_just_pressed("menu_delete"):
            if global.doesSaveGameExist(global.mainMenuPromptIndex):
                mainMenuState = MainMenuState.TRY_DELETE_FILE
                startDeleteSound.play()
            else:
                noBroomSound.play()
        elif Input.is_action_just_pressed("menu_cancel"):
            mainMenuState = MainMenuState.TRY_GO_CREDITS
            broomSound.play()
    elif mainMenuState == MainMenuState.TRY_CONTINUE:
        if Input.is_action_just_pressed("menu_delete") or Input.is_action_just_pressed("menu_cancel") or Input.is_action_just_pressed("ui_start"):
            mainMenuUi.visible = true
            mainMenuState = MainMenuState.MAIN_MENU
            uiLayer.pauseMenu.menuMoveSound.play()
            if global.activeInteractor != null:
                global.activeInteractor.hideTextbox()
        elif Input.is_action_just_pressed("menu_confirm") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")):
            bellSound.play()
            if global.activeInteractor != null and global.activeInteractor.selectedYesNoOption:
                newGamePlus(global.mainMenuPromptIndex)
            else:
                loadGame(global.mainMenuPromptIndex)
    
# @override
# func processPauseMenu():
#     pass

func jostlePlayer():
    # player.global_transform.origin.y = 0.5
    # player.on_ground = false
    player.miniWakeup()

func processSkipPrompt(delta):
    var which_input_to_skip = "popup_menu"
    skipPrompt.bbcode_text = "[right]" + tr("UI.MainMenu.3") % global.getInputText(which_input_to_skip) + "[/right]"
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
            player.override_press_move_left = false
            player.override_press_move_right = false
            global.has_really_started_game = true
            player.textBox.override_target_origin = dialogPosition.global_transform.origin
            player.sayThis(tr("Dialog.Player.1"))
            levelTiles.randomize_num = 3
            gameCamera.can_i_move = true
            if cameraTarget != null:
                cameraTarget.queue_free()
                cameraTarget = null
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
                    babushkaCat.get_ref().override_press_jump = true
                    yield(get_tree().create_timer(0.5), "timeout")
                    babushkaCat.get_ref().override_press_jump = false
                # yield(get_tree().create_timer(1.0), "timeout")
                # if babushkaCat.get_ref(): babushkaCat.get_ref().glitchOut()
        else:
            hideSkipPromptTimer += (delta*11)
            if hideSkipPromptTimer >= hideSkipPromptTimeLimit:
                hideSkipPromptTimer = 0
                skipPrompt.visible = false

func normalizeMainMenuPromptIndex(change):
    global.mainMenuPromptIndex += change
    if global.mainMenuPromptIndex > global.save_game_files.size() - 1:
        global.mainMenuPromptIndex = 0
    if global.mainMenuPromptIndex < 0:
        global.mainMenuPromptIndex = global.save_game_files.size() - 1

var has_ever_started_music = false
# @override
func playMenuMusic():
    # if not musicPlayer.currentlyPlayingTheme:
    #     musicPlayer.conductFromScenePath(getLevelName())
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    pass
    
# @override
func restartMusic():
    if not has_ever_started_music:
        musicPlayer.conductFromScenePath(getLevelName())
        has_ever_started_music = true
