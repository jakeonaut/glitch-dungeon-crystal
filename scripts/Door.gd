extends Spatial

onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false

func _ready():
	animationPlayer.clear_queue()
	animationPlayer.stop()
	if is_locked:
		animationPlayer.queue("doorClose")
		animationPlayer.queue("locked")
	if not is_locked: 
		animationPlayer.play("doorOpen")

func isActive():
	return true

func activate():
	if not is_locked:
		transition.fade_to("res://levels/IntroDungeon/IntroScene1.tscn")

func passiveActivate(delta):
	pass
