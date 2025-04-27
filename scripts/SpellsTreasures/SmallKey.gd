extends "TreasureCollectable.gd"

export var behavior_walking = true
export var behavior_was_thrown = true
export var message = "UI.Alert.0"

var land_count = 0
var land_count_limit = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(false)
    message = tr(message)

    var memory = self.getMyStaticLevelZoneVar()
    if is_static_in_level and memory:
        visible = false
        landSound.volume_db = -80
        grav = 0

# @override
func collideWithWall(local_lv):
    behavior_was_thrown = false
    behavior_walking = false
    hv.x = 0
    dir.x = 0
    lv.x = 0
    linear_velocity.x = 0
    override_press_move_left = false
    override_press_move_right = false
    .collideWithWall(local_lv)
    return local_lv

func isActive(_debug=false):
    return visible and on_ground

# @override
func justPressedJump():
    return behavior_was_thrown and on_ground

# @override
func alignMySprite():
    pass

func landed():
    get_node("SecretAnimationPlayer").play("land")
    landSound.play()
    jump_force /= 2
    land_count += 1
    if land_count >= land_count_limit:
        behavior_was_thrown = false

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)
    collectSound.play()
    level.displayMessageText(message)
