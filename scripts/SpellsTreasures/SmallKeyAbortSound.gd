extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var keyFollowerRes = preload("res://sceneObjects/KeyFollower.tscn")

func _ready():
    pass
    
onready var key = get_node("../../..")
func activateScript():
    var num_keys = global.getLevelZoneThing("key")
    if num_keys == null:
        global.setLevelZoneThing("key", 0)
    global.incrementLevelZoneThing("key", 1)
    global.pauseGame = false
    global.pauseMoveInput = false
    level.spawnKeyFollower(key.global_transform.origin)
    key.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
