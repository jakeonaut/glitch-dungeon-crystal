extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")
var miniCrystalCubeRes = preload("res://sceneObjects/miniCubeCrystal.tscn")
    
func _ready():
    pass
        
    
func preActivateScript():
    var num_bugs = 0
    if global.memory.has("dragonflies"):
        num_bugs += global.memory["dragonflies"]
        global.memory["dragonflies"] = 0
    if global.memory.has("snails"):
        num_bugs += global.memory["snails"]
        global.memory["snails"] = 0
        
    for _i in range(num_bugs):
        var newCube = miniCrystalCubeRes.instance()
        level.add_child(newCube)
        newCube.global_transform.origin.x = npc.global_transform.origin.x + rand_range(-2, 2)
        newCube.global_transform.origin.y = npc.global_transform.origin.y + rand_range(-2, 2)
            
func activateScript():
    pass
        
func isActive():
    # OVERRIDE ME... if you dare
    return true