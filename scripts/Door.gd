extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false

func _ready():
    if is_locked:
        animationPlayer.queue("doorClose")
        animationPlayer.queue("locked")
    else: 
        animationPlayer.play("doorOpen")