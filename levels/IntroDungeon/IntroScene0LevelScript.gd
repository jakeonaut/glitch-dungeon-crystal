extends "../../scripts/levelScript.gd"

var cutscene_timer = 0

var has_player_died = false

# @override
func _ready_impl():
	._ready_impl()
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
		cutscene_timer = 0
		get_node("NPC3").textBox.hideTextbox()
		get_node("NPC3").textBox.has_been_shown = false

func overrideLevelRespawnEvent():
	print("OVERRIDE LEVEL RESPAWN EVENT: " + str(has_player_died))
	if has_player_died:
		var npc = get_node("NPC8")
		npc.textBox.has_been_shown = (npc.textBox.text_final == "what, you don't\nlike it?")
		npc.textBox.text_final = "what, you don't\nlike it?"
	has_player_died = true
