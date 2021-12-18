extends AudioStreamPlayer

func _ready():
	pass

func activateScript():
	var npc = get_node("../../..")
	npc.visible = false

func isActive():
	# OVERRIDE ME... if you dare
	return true
