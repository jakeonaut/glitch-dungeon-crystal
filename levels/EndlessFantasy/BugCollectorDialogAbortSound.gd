extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")
    
func _ready():
    pass
        
    
func preActivateScript():
    var num_bugs = 0
    if global.memory.has("dragonflies"):
        num_bugs += global.memory["dragonflies"]*2
        global.memory["dragonflies"] = 0
    if global.memory.has("snails"):
        num_bugs += global.memory["snails"]*3
        global.memory["snails"] = 0
    if global.memory.has("cicadas"):
        num_bugs += global.memory["cicadas"]*3
        global.memory["cicadas"] = 0
        
    print("Give me bugs: " + str(num_bugs))
    level.player.giveMeMiniCrystalCubes(num_bugs)
            
func activateScript():
    pass
        
func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true
