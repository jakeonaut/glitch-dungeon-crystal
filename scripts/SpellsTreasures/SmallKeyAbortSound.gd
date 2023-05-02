extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    global.memory["key"] += 1
    var key = get_node("../../..")
    global.pauseGame = false
    global.pauseMoveInput = false
    level.saveTheGame("got a key!")
    key.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
