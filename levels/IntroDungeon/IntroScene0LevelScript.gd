extends "../../scripts/levelScript.gd"

var cutscene_timer = 0

func _ready():
	# stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
	_ready_impl()
	set_process(true)

func _process(delta):
	if player.physics_state != player.PhysicsState.NORMAL:
		cutscene_timer += (delta*22)
		if cutscene_timer > 45:
			get_node("NPC3").passiveActivate(delta)
	elif global.activeInteractor == get_node("NPC3/NPC TextBox/TextBox"):
		global.activeInteractor.stopInteract()
