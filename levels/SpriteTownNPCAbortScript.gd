extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    get_node("..").text_final = "maybe I could teach you\nsome time... if you find a\nBROOM or FISHING ROD"

func isActive():
    return true