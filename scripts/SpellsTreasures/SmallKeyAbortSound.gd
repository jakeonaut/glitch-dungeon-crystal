extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export(int, "NORMAL", "FISH", "PYRAMID", "SHROOM", "CAT") var key_type

func _ready():
    pass
    
onready var key = get_node("../../..")
func activateScript():
    global.getKeyInMemory(key_type, level)

    global.pauseGame = false
    global.pauseMoveInput = false
    level.spawnKeyFollower(level.player.global_transform.origin)
    key.okay_im_done = true
    key.queue_free()
    level.player.pauseInput = false
    level.player.aniPlayer.play("stand")

func isActive(_debug=false):
    return true
