extends AudioStreamPlayer

onready var npcAniPlayer = get_node("../../../AnimationPlayer")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
        
var has_activated = false
func activateScript():
    if has_activated:
        return
    has_activated = true
    npcAniPlayer.stop()
    npcAniPlayer.clear_queue()
    npcAniPlayer.play("goodbye_goodbye_goodbye")

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return not has_activated
