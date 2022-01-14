extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    get_node("..").text_final = "maybe I could teach you\nsome time... if only you\ncould find a fishing rod"

func isActive():
    return true