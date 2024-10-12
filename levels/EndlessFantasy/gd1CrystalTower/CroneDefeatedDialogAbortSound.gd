extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass
        

var has_talked = false
func activateScript():
  has_talked = true
  yield(get_tree().create_timer(1.0), "timeout")
  level.playGlitchTransitionAnimation()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return not has_talked