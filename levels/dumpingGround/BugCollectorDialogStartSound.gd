extends AudioStreamPlayer

onready var textBox = get_node("..")


func _ready():
    pass
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():

    var num_bugs = 0
    if global.memory.has("dragonflies"):
        num_bugs += global.memory["dragonflies"]
    if global.memory.has("snails"):
        num_bugs += global.memory["snails"]
    if global.memory.has("cicadas"):
        num_bugs += global.memory["cicadas"]
        
func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true