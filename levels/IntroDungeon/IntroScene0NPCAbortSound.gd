extends AudioStreamPlayer

var save_point = preload("res://sceneObjects/SavePoint.tscn")

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.get_node("NPC TextBox/TextBox").text_final = "are you corporeal?"

func isActive():
    # OVERRIDE ME... if you dare
    return true
