extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    # OVERRIDE ME
    pass
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true
