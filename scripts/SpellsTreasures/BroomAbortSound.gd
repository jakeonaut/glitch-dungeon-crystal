extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var broom = get_node("../../..")
    broom.visible = false
    broom.is_active = false
    broom.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    level.player.getABroom()
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
