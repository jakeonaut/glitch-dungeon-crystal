extends AudioStreamPlayer

onready var textBox = get_node("..")


func _ready():
    pass
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
    textBox.text_final = "•every bug has life\n but I am very hungry.\n•hey you... can you help me out?\n•if you bring me dragonflies,\n snails, or other bugs,\n•i can trade many crystals"

    var num_bugs = 0
    if global.memory.has("dragonflies"):
        num_bugs += global.memory["dragonflies"]
    if global.memory.has("snails"):
        num_bugs += global.memory["snails"]
    if global.memory.has("cicadas"):
        num_bugs += global.memory["cicadas"]
        
    if num_bugs > 0:
        textBox.text_final += "\n•oh, you have some!\n okay, let's trade!\n•yee hee hee!!"
        
func isActive():
    # OVERRIDE ME... if you dare
    return true