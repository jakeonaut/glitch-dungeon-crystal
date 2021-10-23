extends AudioStreamPlayer

func _ready():
	pass

func activateScript():
	var npc = get_node("../../..") 
	npc.pressing_jump = true
	npc.just_pressed_jump = true
	npc.glitch_form = npc.GlitchForm.FEATHER
	npc.jump_force = 3
	npc.feather_jump_time_limit = 999
	npc.true_terminal_vel = 1

func isActive():
	# OVERRIDE ME... if you dare
	return true
