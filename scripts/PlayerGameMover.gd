extends "GameMover.gd"

var broom_timer = 0
var broom_time_limit = 2
var broom_state = 0
var can_broom = global.can_broom
var jump_press_timer = 999
var jump_press_time_limit = 5

func _ready():
    set_physics_process(true)
    set_process(true)
    
func _process(delta):
    if jump_press_timer <= jump_press_time_limit:
        jump_press_timer += 1

    if justPressedJump():
        jump_press_timer = 0

# @override
func respawn():
    playerRespawn("long_fade")

# param transition name only used as a crappy enum
func playerRespawn(transition_name):
    if transitioning: return
        
    fallSound.play()
    global.isRespawning = true
    # global transition scene, see res://scripts/transition.gd
    var currLevelPath = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
    transitioning = true

    if transition_name == "long_fade":
        transition.long_fade_to(currLevelPath)
    elif transition_name == "blink_fade":
        transition.blink_fade_to(currLevelPath)
    else:
        transition.fade_to(currLevelPath)

# @override
func justPressedDown():
    return Input.is_action_just_pressed("ui_fall_down")

# @override
func pressingDown():
    return Input.is_action_pressed("ui_fall_down")

# @override
func justPressedJump():
    return Input.is_action_just_pressed("ui_jump") or should_magic_jump
    
# @override
func recentlyJustPressedJump():
    return jump_press_timer < jump_press_time_limit

# @override
func pressingJump():
    return Input.is_action_pressed("ui_jump")

# @override
func pressingMoveForward():
    return Input.is_action_pressed("ui_up")
    
# @override
func pressingMoveDown():
    return Input.is_action_pressed("ui_down")
    
# @override
func pressingMoveLeft():
    return Input.is_action_pressed("ui_left")

# @override
func pressingMoveRight():
    return Input.is_action_pressed("ui_right")

func magicJump():
    should_magic_jump = true

# @override
func landed():
    if is_falling:
        transition.interrupt()
        is_falling = false
        fallSound.stop()
        transitioning = false
        global.isRespawning = false
    .landed() #super