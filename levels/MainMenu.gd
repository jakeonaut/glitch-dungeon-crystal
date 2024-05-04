extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1

func setUpRoomInitializationOverride():
    pass

onready var menuOptionPointer = get_node("MenuOptionPointer")
onready var menuOptionPointer2 = get_node("MenuOptionPointer2")
var roomPath = "res://levels/000Intro.tscn"
func startGame():
    global.isEnteringRoom = true
    transition.really_long_fade_to(roomPath)

func loadGame():
    if global.loadGame():
        global.isRespawning = true
        if global.memory.has("roomPath"):
            roomPath = global.memory["roomPath"]
    startGame()

onready var continuePrompt = get_node("../../UILayer/ContinuePrompt")
onready var newGamePrompt = get_node("../../UILayer/NewGamePrompt")
onready var menuText = get_node("../../UILayer/MenuText")

export var camera_size = 30
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    gameCamera.initial_size = camera_size
    gameCamera.zoomed_size = camera_size
    gameCamera.size = camera_size
    # gameCamera.can_i_move = false
    global.pauseGame = true
    global.pauseMoveInput = true

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

    if Input.is_action_just_pressed("sub_action_button"):
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if continuePrompt.visible:
            loadGame()
        else:
            startGame()
