extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var textBox = get_node("..")
    textBox.text_final = "•it's really nice up here"
    # textBox.tinify()
    textBox.has_been_shown = false
    textBox.textboxParent.jump_force = 2

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
