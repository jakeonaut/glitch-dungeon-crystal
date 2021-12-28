extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
# String is a path to a file.
export(String, FILE) var path

onready var doorSound = get_node("DoorSound")
onready var lockedSound = get_node("LockedSound")

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

func passiveActivate():
    if not is_locked:
        transition.long_fade_to(path)
        if not doorSound.is_playing():
            doorSound.play()
    else:
        if not lockedSound.is_playing():
            lockedSound.play()

func passiveActivate(delta):
    pass
