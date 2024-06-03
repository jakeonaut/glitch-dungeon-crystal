extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1

func setUpRoomInitializationOverride():
    pass
    # player.aniPlayer.stop()
    # player.aniPlayer.clear_queue()
    # player.aniPlayer.play("happyStand")

onready var eventSound1 = get_node("EventSound1")
onready var chicken10 = get_node("NPC10")
onready var chicken9 = get_node("NPC9")
onready var chicken3 = get_node("NPC3")
onready var glitchMoleCricket = get_node("GlitchMoleCricket")
onready var glitchMoleCricket2 = get_node("GlitchMoleCricket2")
onready var glitchMoleCricket3 = get_node("GlitchMoleCricket3")
onready var babushkaCat = get_node("BabushkaCat")
func startGame():
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

  yield(get_tree().create_timer(0.5), "timeout")
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
  eventSound1.play()
  chicken10.glitchOut()
  yield(get_tree().create_timer(1.0), "timeout")
  chicken9.glitchOut()
  var dig_time_limit = 2
  glitchMoleCricket.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket.startDigging()
  glitchMoleCricket2.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket2.startDigging()
  glitchMoleCricket3.mole_state_dig_time_limit = dig_time_limit
  glitchMoleCricket3.startDigging()

  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  chicken3.glitchOut()
  eventSound1.play()
  yield(get_tree().create_timer(0.33), "timeout")
  eventSound1.play()
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

onready var mainMenuUi = get_node("../../UILayer/MainMenu")
onready var continuePrompt = get_node("../../UILayer/MainMenu/ContinuePrompt")
onready var newGamePrompt = get_node("../../UILayer/MainMenu/NewGamePrompt")
onready var menuText = get_node("../../UILayer/MainMenu/MenuText")

export var camera_size = 30
# Called every frame. 'delta' is the elapsed time since the previous frame.
var has_started_game = false
func _process(_delta):
    if not has_started_game:
        gameCamera.initial_size = camera_size
        gameCamera.zoomed_size = camera_size
        gameCamera.size = camera_size
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

    if global.doesSaveGameExist():
        if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
            if continuePrompt.visible:
                continuePrompt.visible = false
                newGamePrompt.visible = true
                menuText.bbcode_text = "Continue...?\n\n[wave]New Game[/wave]"
            else:
                continuePrompt.visible = true
                newGamePrompt.visible = false
                menuText.bbcode_text = "[wave]Continue...?[/wave]\n\nNew Game"
    else:
        if continuePrompt.visible:
            continuePrompt.visible = false
            newGamePrompt.visible = true
            menuText.bbcode_text = "Continue...?\n\n[wave]New Game[/wave]"
        if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
            player.noSpellSound.play()

    # switch_glitch_timer += (delta*22)
    # if switch_glitch_timer >= switch_glitch_time_limit:
    #     switch_glitch_timer = 0
    #     player.applyNextGlitch()

    if Input.is_action_just_pressed("sub_action_button") and not has_started_game:
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if continuePrompt.visible:
            loadGame()
        else:
            startGame()
