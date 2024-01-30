extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export(int, "NORMAL", "FISH", "PYRAMID", "SHROOM", "CAT") var key_type

func _ready():
    pass
    
onready var key = get_node("../../..")
func activateScript():
    if key_type != 0: # thank god
        if not global.memory.has("key_items"):
            global.memory["key_items"] = {}
        global.memory["key_items"][key_type] = global.ItemState.GOT_IT
        
    var num_keys = global.getLevelZoneThing("key")
    if num_keys == null:
        global.setLevelZoneThing("key", 0)
    global.incrementLevelZoneThing("key", 1)
    global.pauseGame = false
    global.pauseMoveInput = false
    level.spawnKeyFollower(key.global_transform.origin)
    key.okay_im_done = true
    key.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
