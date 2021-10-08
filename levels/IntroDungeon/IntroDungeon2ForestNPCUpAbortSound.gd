extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    get_node("..").actuallyApplyJump()

func isActive():
    # OVERRIDE ME... if you dare
    return true