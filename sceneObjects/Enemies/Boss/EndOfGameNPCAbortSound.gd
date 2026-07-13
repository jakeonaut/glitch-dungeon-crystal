extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
        

var has_activated = false
func activateScript():
    if has_activated:
        return
    has_activated = true
    # TODO(jaketrower): DLC
    if global.isSecretEndingEnabled():
        global.memory["world_of_ruin"] = true
        transition.long_fade_to("res://levels/EndlessFantasy/gd1CrystalTower/HighPriestessRoom.tscn")
    else:
        transition.long_fade_to("res://levels/EndlessFantasy/gd1/EndCredits.tscn")

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return not has_activated
