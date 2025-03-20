extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
        

func activateScript():
    transition.long_fade_to("res://levels/EndlessFantasy/gd1/EndCredits.tscn")

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
