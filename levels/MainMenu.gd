extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1

func setUpRoomInitializationOverride():
    global.isOnMainMenu = true
    transition.reverse_fade()
    # player.aniPlayer.stop()
    # player.aniPlayer.clear_queue()
    # player.aniPlayer.play("happyStand")

onready var eventSound1 = get_node("EventSound1")
onready var eventSound2 = get_node("EventSound2")
onready var eventSound3 = get_node("EventSound3")
onready var chicken10 = get_node("NPC10")
onready var chicken9 = get_node("NPC9")
onready var chicken3 = get_node("NPC3")
onready var glitchMoleCricket = get_node("GlitchMoleCricket")
onready var glitchMoleCricket2 = get_node("GlitchMoleCricket2")
onready var glitchMoleCricket3 = get_node("GlitchMoleCricket3")
onready var babushkaCat = get_node("BabushkaCat")
onready var chicken12 = get_node("NPC12")
onready var chicken13 = get_node("NPC13")
onready var chicken14 = get_node("NPC14")
onready var chicken15 = get_node("NPC15")
onready var croneNPC = get_node("CroneNPC")
onready var door2 = get_node("Door2")
onready var logoSprite = get_node("../../Viewport2/CanvasLayer/LogoSprite")
onready var glitchEnemy6 = get_node("GlitchEnemy6")
onready var colorRect = get_node("../../UILayer/MainMenu/ColorRect")
func startGame():
  logoSprite.visible = false
#   show_dither_effect = false
#   show_crt_effect = true
  has_started_game = true
  mainMenuUi.visible = false
  global.shouldRenderAsCinematic = true
  uiLayer.statsTitleRect.visible = false
  player.pauseInput = true
  uiLayer.get_node("GlitchSprite").visible = false
  uiLayer.get_node("GlitchStatusRect").visible = false
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  gameCamera.initial_size = 25
  gameCamera.zoomed_size = 25
  # gameCamera.can_i_move = false

  yield(get_tree().create_timer(1.5), "timeout")
  gameCamera.can_i_move = false
  player.override_press_move_right = true
  yield(get_tree().create_timer(0.2), "timeout")
  player.override_press_move_right = false
  # player.pauseAnimation = true
  yield(get_tree().create_timer(0.5), "timeout")
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(1.0), "timeout")
  player.override_press_move_left = true
  yield(get_tree().create_timer(0.1), "timeout")
  player.override_press_move_left = false
  yield(get_tree().create_timer(0.5), "timeout")
  player.aniPlayer.queue("sweepFloor")
  player.aniPlayer.queue("stand")
  yield(get_tree().create_timer(2.0), "timeout")
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  player.aniPlayer.play("happyStand")
  yield(get_tree().create_timer(2.0), "timeout")
  player.aniPlayer.play("fall")
  eventSound1.play()
  yield(get_tree().create_timer(1.0), "timeout")
  babushkaCat.mySprite.updateBaseFrame(2, 2)
  gameCamera.can_i_move = true
  eventSound1.play()
  chicken10.glitchOut()
  yield(get_tree().create_timer(1.0), "timeout")
  levelTiles.randomize_num = 3
  babushkaCat.mySprite.flip_h = true
  babushkaCat.mySprite.should_randomize_frame_delay = false
  babushkaCat.mySprite.frame_delay = 0.1
  babushkaCat.override_press_move_right = true
  player.mySprite.flip_h = not player.mySprite.flip_h
  eventSound1.play()
  chicken9.glitchOut()
  chicken3.glitchOut()
  yield(get_tree().create_timer(2.0), "timeout")
  eventSound2.play()
  player.override_press_move_right = true
  yield(get_tree().create_timer(3.0), "timeout")
  player.override_press_move_right = false
  eventSound1.play()
  chicken12.glitchOut()
#   var dig_time_limit = 2
#   glitchMoleCricket.mole_state_dig_time_limit = dig_time_limit
#   glitchMoleCricket.startDigging()
#   glitchMoleCricket2.mole_state_dig_time_limit = dig_time_limit
#   glitchMoleCricket2.startDigging()
#   glitchMoleCricket3.mole_state_dig_time_limit = dig_time_limit
#   glitchMoleCricket3.startDigging()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
  chicken13.glitchOut()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
  chicken14.glitchOut()
  yield(get_tree().create_timer(1.0), "timeout")
  eventSound1.play()
  croneNPC.visible = true
  summonSmokeClouds(croneNPC.global_transform.origin, 3, true, true)
  yield(get_tree().create_timer(1.0), "timeout")
  eventSound3.play()
#   global.memory["savePoint"] = "SavePoint"
#   global.memory["savedRoomPath"] = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_0.tscn"
  player.aniPlayer.stop()
  player.aniPlayer.clear_queue()
  player.aniPlayer.queue("teleport")
  glitchScreenEffect.visible = global.memory["canGlitchScreen"]
  glitchScreenEffect.material.set_shader_param("shake_power", 0.01)
  glitchScreenEffect.material.set_shader_param("shake_color_rate", 0.01)
  yield(get_tree().create_timer(1.0), "timeout")
  global.isEnteringRoom = true
  global.memory["roomPath"] = self.getLevelName()
  transition.really_really_long_fade_to(door2.path)
  eventSound1.play()
  glitchEnemy6.global_transform.origin = player.global_transform.origin
  glitchEnemy6.global_transform.origin.y += 1
  glitchEnemy6.global_transform.origin.z += 2

  # var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
  # pastoralGrannyNPC.textBox.text_final = "•some glitch dust appeared!\nhow odd... dearie, could you\nsweep up with [lb]" + sweep_button_text + "[rb]?"
  # pastoralGrannyNPC.textBoxContainer.bbText = pastoralGrannyNPC.textBox.text_final

  # NPC7.floating_text = true
  # NPC7.mySprite.pixel_size = 0.0001
  # NPC7.textBox.floating_text = true
  # var right_button_text = global.getKeyCodeStr(global.getKeyCode("ui_right"))
  # NPC7.textBox.text_final = "*meow!\n•up here dearie!\npress [lb]" + right_button_text + "[rb] to walk"
  # NPC7.textBox.showTextbox()

func loadGame():
    if global.loadGame():
        global.isRespawning = true
        if global.memory.has("roomPath"):
            var roomPath = global.memory["roomPath"]
            global.isEnteringRoom = true
            transition.really_long_fade_to(roomPath)
            return
    # default
    startGame()

func quitGame():
    get_tree().quit()

onready var mainMenuUi = get_node("../../UILayer/MainMenu")
onready var continuePrompt = get_node("../../UILayer/MainMenu/ContinuePrompt")
onready var newGamePrompt = get_node("../../UILayer/MainMenu/NewGamePrompt")
onready var quitPrompt = get_node("../../UILayer/MainMenu/QuitPrompt")
onready var menuText = get_node("../../UILayer/MainMenu/MenuText")

export var camera_size = 30
# Called every frame. 'delta' is the elapsed time since the previous frame.
var has_started_game = false
var mainMenuPromptIndex = 0
func _process(_delta):
    if not has_started_game:
        gameCamera.initial_size = camera_size
        gameCamera.zoomed_size = camera_size
        gameCamera.size = camera_size
        mainMenuUi.visible = not global.isPauseMenuOpen
    # gameCamera.can_i_move = false
    # global.pauseGame = true
    player.pauseInput = true

    # if uiLayer.title_display_state == 3:
    #     uiLayer.title_display_state = 0
    # uiLayer.setDisplayTitle("press [lb]" + global.getKeyCodeStr(global.getKeyCode("sub_action_button")) + "[rb]")

    # .process(delta) implicit
    # player.rotation_degrees.y += (delta)*direction
    # if player.rotation_degrees.y > 5:
    #     direction = -1
    # elif player.rotation_degrees.y < -5:
    #     direction = 1

    if mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
        mainMenuPromptIndex = 1
        colorRect.visible = false

    if global.isPauseMenuOpen:
        return

    if Input.is_action_just_pressed("ui_down"):
        mainMenuPromptIndex += 1
        if mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
            mainMenuPromptIndex = 1
    elif Input.is_action_just_pressed("ui_up"):
        mainMenuPromptIndex -= 1
        if mainMenuPromptIndex == 0 and not global.doesSaveGameExist():
            mainMenuPromptIndex = 2

    if mainMenuPromptIndex == 0 and not continuePrompt.visible:
        continuePrompt.visible = true
        newGamePrompt.visible = false
        quitPrompt.visible = false
        menuText.bbcode_text = "[wave]Continue...?[/wave]\n\nNew Game\n\nQUIT!!! bye."
    elif mainMenuPromptIndex == 1 and not newGamePrompt.visible:
        continuePrompt.visible = false
        newGamePrompt.visible = true
        quitPrompt.visible = false
        if global.doesSaveGameExist():
            menuText.bbcode_text = "Continue...?\n\n[wave]New Game[/wave]\n\nQUIT!!! bye."
        else:
            menuText.bbcode_text = "\n\n[wave]New Game[/wave]\n\nQUIT!!! bye."
    elif mainMenuPromptIndex == 2 and not quitPrompt.visible:
        continuePrompt.visible = false
        newGamePrompt.visible = false
        quitPrompt.visible = true
        if global.doesSaveGameExist():
            menuText.bbcode_text = "Continue...?\n\nNew Game\n\n[wave]QUIT!!! bye.[/wave]"
        else:
            menuText.bbcode_text = "\n\nNew Game\n\n[wave]QUIT!!! bye.[/wave]"


    # switch_glitch_timer += (delta*22)
    # if switch_glitch_timer >= switch_glitch_time_limit:
    #     switch_glitch_timer = 0
    #     player.applyNextGlitch()

    if Input.is_action_just_pressed("sub_action_button") and not has_started_game:
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if mainMenuPromptIndex == 0:
            loadGame()
        elif mainMenuPromptIndex == 1:
            startGame()
        else:
            quitGame()

# @override
# func processPauseMenu():
#     pass
