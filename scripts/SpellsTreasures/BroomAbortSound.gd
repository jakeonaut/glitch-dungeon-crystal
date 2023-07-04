extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var broom = get_node("../../..")
    
    global.pauseGame = false
    global.pauseMoveInput = false
    var aniPlayer = level.player.get_node("AnimationPlayer")
    aniPlayer.clear_queue()
    aniPlayer.queue("walkStop")
    aniPlayer.queue("stand")
    level.player.getABroom()
    level.player.textBox.hideTextbox()
        
    # level.restartMusic()
    # level.saveTheGame()

    broom.queue_free()

func isActive():
    return true
