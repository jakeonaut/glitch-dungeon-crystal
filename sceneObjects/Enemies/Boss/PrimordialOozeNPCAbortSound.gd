extends AudioStreamPlayer

onready var endOfGameNPC = get_node("../../../../EndOfGameNPC")
        

func activateScript():
    transition.end_the_game()
    global.activeInteractor = null
    endOfGameNPC.activate(true)

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
