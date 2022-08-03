extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")
    
func _ready():
    pass
        
    
func preActivateScript():
    level.player.giveMeMiniCrystalCubes(global.num_mini_crystal_cubes)
            
func activateScript():
    pass
        
func isActive():
    # OVERRIDE ME... if you dare
    return true
