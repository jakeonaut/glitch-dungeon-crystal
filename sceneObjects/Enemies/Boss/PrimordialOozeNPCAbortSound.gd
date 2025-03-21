extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
        

var has_activated = false
func activateScript():
    if has_activated:
        return
    has_activated = true
    # transition.end_the_game()
    level.get_node("AnimationPlayer").stop()
    level.get_node("AnimationPlayer").clear_queue()
    level.get_node("AnimationPlayer").play("finalJudgement")
    global.activeInteractor = null
    yield(get_tree().create_timer(4.0), "timeout")
    global.hasGottenLevelGeode = true
    global.isEndOfGame = true

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return not has_activated
