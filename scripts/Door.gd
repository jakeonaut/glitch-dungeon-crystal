extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false

func _ready():
    if is_locked:
        animationPlayer.queue("doorClose")
        animationPlayer.queue("locked")
    else: 
        animationPlayer.play("doorOpen")

func isActive():
    return true

func activate():
    transition.fade_to("res://levels/IntroDungeon/IntroScene1.tscn")

func passiveActivate(delta):
    pass