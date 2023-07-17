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
    transition.path = roomPath
    transition.change_scene()

func loadGame():
    if global.loadGame():
        global.isRespawning = true
        if global.memory.has("roomPath"):
            roomPath = global.memory["roomPath"]
    startGame()

onready var continueSelectHighlight = get_node("UILayer/Options/Continue/OptionTextLabeGlitched")
onready var newGameSelectHighlight = get_node("UILayer/Options/NewGame/OptionTextLabeGlitched")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
        else:
            yy = -6
            continueSelectHighlight.visible = true
            newGameSelectHighlight.visible = false
        menuOptionPointer.global_transform.origin.y = yy
        menuOptionPointer2.global_transform.origin.y = yy

    switch_glitch_timer += (delta*22)
    if switch_glitch_timer >= switch_glitch_time_limit:
        switch_glitch_timer = 0
        player.applyNextGlitch()

    if Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("sub_action_button"):
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        if continueSelectHighlight.visible:
            loadGame()
        else:
            startGame()
