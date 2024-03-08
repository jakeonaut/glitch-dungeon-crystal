extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    pass
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    if level.has_node("CubeCrystal"):
        level.get_node("CubeCrystal").visible = true

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true