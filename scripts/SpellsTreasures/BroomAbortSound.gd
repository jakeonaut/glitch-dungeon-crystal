extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var broomLevel = 0

func _ready():
    pass

func activateScript():
    var broom = get_node("../../..")
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    level.player.getABroom(broomLevel)
        
    level.restartMusic()
    level.saveTheGame()

    broom.queue_free()

func isActive():
    return true
