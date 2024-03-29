extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1

func setUpRoomInitializationOverride():
    if not global.doesSaveGameExist():
        startGame()

onready var menuOptionPointer = get_node("MenuOptionPointer")
onready var menuOptionPointer2 = get_node("MenuOptionPointer2")
var roomPath = "res://levels/EndlessFantasy/gd1/000PastoralScene.tscn"
func startGame():
    global.isEnteringRoom = true
    transition.really_long_fade_to(roomPath)

func loadGame():
    if global.loadGame():
        global.isRespawning = true
        if global.memory.has("roomPath"):
            roomPath = global.memory["roomPath"]
    startGame()

onready var continueText = get_node("../../UILayer/Options/Continue/OptionTextLabel")
onready var continueSelectHighlight = get_node("../../UILayer/Options/Continue/OptionTextLabeGlitched")
onready var newGameText = get_node("../../UILayer/Options/NewGame/OptionTextLabel")
onready var newGameSelectHighlight = get_node("../../UILayer/Options/NewGame/OptionTextLabeGlitched")

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

    if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
        var yy = 0
        if continueSelectHighlight.visible:
            yy = -9
            continueSelectHighlight.visible = false
            newGameSelectHighlight.visible = true
            continueText.bbcode_text = "[color=gray]continue...[/color]"
            newGameText.bbcode_text = "[wave]NEW GAME![/wave]"
        else:
            yy = -6
            continueSelectHighlight.visible = true
            newGameSelectHighlight.visible = false
            continueText.bbcode_text = "[wave]CONTINUE![/wave]"
            newGameText.bbcode_text = "[color=gray]new game...[/color]"
        menuOptionPointer.global_transform.origin.y = yy
        menuOptionPointer2.global_transform.origin.y = yy

    # switch_glitch_timer += (delta*22)
    # if switch_glitch_timer >= switch_glitch_time_limit:
    #     switch_glitch_timer = 0
    #     player.applyNextGlitch()

    if Input.is_action_just_pressed("sub_action_button"):
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if continueSelectHighlight.visible:
            loadGame()
        else:
            startGame()
