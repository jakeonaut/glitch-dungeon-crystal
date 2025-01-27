extends AudioStreamPlayer

var save_point = preload("res://sceneObjects/SavePoint.tscn")

func _ready():
    pass

func activateScript():
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
