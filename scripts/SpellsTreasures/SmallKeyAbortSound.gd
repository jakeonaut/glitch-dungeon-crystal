extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var num_keys = global.getLevelZoneThing("key")
    if num_keys == null:
        global.setLevelZoneThing("key", 0)
    global.incrementLevelZoneThing("key", 1)
    var key = get_node("../../..")
    global.pauseGame = false
    global.pauseMoveInput = false
    key.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
