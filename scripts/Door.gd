extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
# String is a path to a file.
export(String, FILE) var path

func _ready():
    animationPlayer.clear_queue()
    animationPlayer.stop()
    if is_locked:
        animationPlayer.queue("doorClose")
        animationPlayer.queue("locked")
    else: 
        animationPlayer.play("doorOpen")

func isActive():
    return true

func activate():
    if not is_locked:
        transition.fade_to(path)

func passiveActivate(delta):
    pass
