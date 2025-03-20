extends AudioStreamPlayer

onready var endOfGameNPC = get_node("../../../../EndOfGameNPC")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
        

func activateScript():
    # transition.end_the_game()
    level.get_node("AnimationPlayer").play("finalJudgement")
    global.activeInteractor = null
    yield(get_tree().create_timer(4.0), "timeout")
    endOfGameNPC.activate(true)

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
