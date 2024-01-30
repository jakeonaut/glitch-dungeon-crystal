extends "TreasureCollectable.gd"

export var behavior_walking = true
export var behavior_was_thrown = true
export var message = "got a key!"

var land_count = 0
var land_count_limit = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(true)

    var memory = self.getMyStaticLevelZoneVar()
    # print("is static in level?: " + str(is_static_in_level) + ", name: " + self.name + ", " + (str(memory) if memory else "null"))
    if is_static_in_level and memory:
        # print("how did this happen?")
        visible = false

func _process(_delta):
    pauseSelf = not visible

func isActive():
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
    # level.displayMessageText(message)
