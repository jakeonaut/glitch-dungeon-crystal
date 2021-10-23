extends AudioStreamPlayer

func _ready():
	pass

func activateScript():
	var textBox = get_node("..")
	textBox.text_final = "it's really nice up here"

func isActive():
	# OVERRIDE ME... if you dare
	return true
