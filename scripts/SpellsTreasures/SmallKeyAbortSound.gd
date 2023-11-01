extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var followerRes = preload("res://sceneObjects/KeyFollower.tscn")

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
    key.queue_free()
    level.player.aniPlayer.play("stand")

    var newKeyFollower = followerRes.instance()
    level.add_child(newKeyFollower)

func isActive():
    return true
