extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")

onready var sunLight = get_node("../commonWorldEnvironment/The Sun")
onready var levelTiles = get_node("../LevelTiles")

onready var broom = get_node("CameraY/broom")
onready var broomSound = get_node("Sounds/BroomSound")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0

func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    if pauseMenu: pauseMenu.hide()

func floorGlitch():
    glitch_form = GlitchForm.FLOOR
    levelTiles.floorGlitch()
    mySprite.setClericCostume()

func featherGlitch():
    glitch_form = GlitchForm.FEATHER
    levelTiles.featherGlitch()
    mySprite.setMothCostume()

func ladderGlitch():
    glitch_form = GlitchForm.LADDER
    levelTiles.ladderGlitch()
    mySprite.setLuckyCatCostume()

func wearCostume(costume):
    if costume == "normal": 
        mySprite.setNormalClothes()
    elif costume == "moth": 
        mySprite.setMothCostume()
    elif costume == "bugcatcher": 
        mySprite.setBugCatcherCostume()
    elif costume == "cleric": 
        mySprite.setClericCostume()
        jumpSound = get_node("Sounds/JumpOverallsSound")
    elif costume == "luckycat": 
        mySprite.setLuckyCatCostume()
    elif costume == "nightgown": 
        mySprite.setNightgown()
    global.memory["player_costume"] = costume
    
func _process(delta):
    # ._process(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500

    if Input.is_action_just_pressed("ui_accept") and not global.pauseMoveInput:
        if not global.pauseGame:
            if pauseMenu: pauseMenu.show()
            global.pauseGame = true
        else:
            if pauseMenu: pauseMenu.hide()
            global.pauseGame = false


    if broom_state != 0:
        broom_timer += (delta*22)
        if broom_timer >= broom_time_limit:
            broom_timer = 0
            #var broom_mesh = broom.get_node("broom")
            var broom_sprite = broom.get_node("Sprite3D")
            if broom_state == 1:
                #broom_mesh.rotation_degrees.z = 10
                broom_sprite.updateBaseFrame(1, 0)
                broom_state = 2
            elif broom_state == 2:
                #broom_mesh.translation.x = 5
                broom_sprite.translation.x = -3
                broom_sprite.updateBaseFrame(0, 0)
                broom_state = 3
                broomSound.play()
            elif broom_state == 3:
                broom_sprite.updateBaseFrame(1, 0)
                broom_state = 4
            elif broom_state == 4:
                broom_sprite.translation.x = 0.5
                broom_state = -2
                broom.visible = false
            elif broom_state < 0:
                broom_state += 1
                if broom_state == 0:
                    can_broom = true


    tryRotateCamera(delta)

    if global.pauseGame: return

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500
    pass

func tryRotateCamera(delta):
    # if not Input.is_action_pressed("ui_ctrl"):
    if Input.is_action_pressed("ui_rotate_left"):
        cameraRotationCounter += delta
        getCamera().rotate_left((delta*66)+(cameraRotationCounter*36))
    elif Input.is_action_pressed("ui_rotate_right"):
        cameraRotationCounter += delta
        getCamera().rotate_right((delta*66)+(cameraRotationCounter*36))
    else: cameraRotationCounter = 0
        
    if cameraRotationCounter > 1: cameraRotationCounter = 1
    
    if Input.is_action_pressed("ui_rotate_up"):
        getCamera().rotate_up(3*(delta*66))
    if Input.is_action_pressed("ui_rotate_down"):
        getCamera().rotate_down(3*(delta*66))

    if Input.is_action_just_pressed("ui_focus_next"):
        getCamera().toggleNext()
    if Input.is_action_just_pressed("ui_focus_forward"):
        getCamera().focusForward(facing)

func tryDieToEnemy():
    if not transitioning:
        hurtSound.play()
        global.pauseGame = true
        global.pauseMoveInput = true
        self.playerRespawn("blink_fade")

func tryBroom():
    if can_broom:        
        var broom_sprite = broom.get_node("Sprite3D")
        if mySprite.isPlayerFacingDown():
            broom.rotation_degrees.y = 0
            broom_sprite.flip_h = false
        elif mySprite.isPlayerFacingRight():
            broom.rotation_degrees.y = 90
            broom_sprite.flip_h = false
        elif mySprite.isPlayerFacingUp():
            broom.rotation_degrees.y = 180
            broom_sprite.flip_h = true
        elif mySprite.isPlayerFacingLeft():
            broom.rotation_degrees.y = 270
            broom_sprite.flip_h = true

        broom.visible = true
        broom_state = 1
        broom_timer = 0
        can_broom = false
        broom_sprite.updateBaseFrame(1, 1)
        broom_sprite.max_frames = 1
        broomSound.play()
        pass # on_ground = false

func faceDown():
    mySprite.faceDown()

func lightsOff():
    sunLight.visible = false

func lightsOn():
    sunLight.visible = true