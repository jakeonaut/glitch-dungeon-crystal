extends AudioStreamPlayer

func _ready():
	pass

func activateScript():
	var textBox = get_node("..")
	textBox.text_final = "it's really nice up here"
	get_node("../../..").jump_force = 2

func isActive():
	# OVERRIDE ME... if you dare
	return true
