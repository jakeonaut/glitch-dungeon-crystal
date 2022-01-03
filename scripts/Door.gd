extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
# String is a path to a file.
export(String, FILE) var path

onready var doorSound = get_node("DoorSound")
onready var lockedSound = get_node("LockedSound")

onready var myOtherSprite = get_node("Sprite3D2")
var is_passive_activate = false

func _ready():
    animationPlayer.clear_queue()
    animationPlayer.stop()
    if is_locked:
        animationPlayer.queue("doorClose")
        animationPlayer.queue("locked")
    else: 
        animationPlayer.play("doorOpen")

func _process(delta):
    if not is_passive_activate:
        myOtherSprite.visible = false
    else:
        is_passive_activate = false

func isActive():
    return true

func activate():
    if not is_locked:
        transition.long_fade_to(path)
        if not doorSound.is_playing():
            doorSound.play()
    else:
        if not lockedSound.is_playing():
            lockedSound.play()

func passiveActivate(delta):
    # myOtherSprite.visible = true
    is_passive_activate = true
