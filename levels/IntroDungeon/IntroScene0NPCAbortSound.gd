extends AudioStreamPlayer

var save_point = preload("res://sceneObjects/SavePoint.tscn")

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.is_active = false
    npc.can_activate = false

func isActive():
    # OVERRIDE ME... if you dare
    return true
