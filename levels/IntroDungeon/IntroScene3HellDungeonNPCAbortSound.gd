extends AudioStreamPlayer


var savePoint = preload("res://sceneObjects/SavePoint.tscn")
var new_self = null

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")

func _ready():
    pass
    
func preActivateScript():
    pass

func activateScript():
   pass

func isActive():
    # OVERRIDE ME... if you dare
    return true
