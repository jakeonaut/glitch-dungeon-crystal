extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var molt_fruit = get_node("../../..")
func activateScript():
    molt_fruit.visible = false
    molt_fruit.is_active = false
    molt_fruit.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    global.num_cherries_gained = 1
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
