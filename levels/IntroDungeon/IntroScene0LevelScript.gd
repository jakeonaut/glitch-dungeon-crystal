extends "../../scripts/levelScript.gd"

var cutscene_timer = 0

func _ready():
	# stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
	_ready_impl()
	set_process(true)
	global.pauseMoveInput = true

func _process(delta):
	if player.physics_state != player.PhysicsState.NORMAL:
		cutscene_timer += (delta*22)
		if cutscene_timer > 40 and cutscene_timer < 45 and not get_node("NPC3/AnimationPlayer").is_playing():
			get_node("NPC3/AnimationPlayer").play("flickerOn")
		if cutscene_timer > 100:
			get_node("NPC3").passiveActivate(delta)
		if cutscene_timer > 115:
			global.pauseMoveInput = false
	elif cutscene_timer > 115 and global.activeInteractor == get_node("NPC3/NPC TextBox/TextBox"):
		global.activeInteractor.hideTextbox()
		get_node("NPC3/NPC TextBox/TextBox").text_final = "are you from\nthe outside world?"
		cutscene_timer = 0
