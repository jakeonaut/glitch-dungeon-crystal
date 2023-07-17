extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    if not global.memory.has("key"):
        global.memory["key"] = 0
    global.memory["key"] += 1
    var key = get_node("../../..")
    global.pauseGame = false
    global.pauseMoveInput = false
    key.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
