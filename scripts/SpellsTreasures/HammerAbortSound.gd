extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var hammer = get_node("../../..")
func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.pauseInput = false
    var aniPlayer = level.player.get_node("AnimationPlayer")
    aniPlayer.clear_queue()
    aniPlayer.queue("walkStop")
    aniPlayer.queue("stand")
    global.memory["hammer"] = 1
    hammer.queue_free()

func isActive(_debug=false):
    return true
