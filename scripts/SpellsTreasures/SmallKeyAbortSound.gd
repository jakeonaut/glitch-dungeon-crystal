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
        var key_name = "PHISHING KEY"
        if key_type == global.KeyItem.PYRAMID:
            key_name = "CRYPT KEY"
        elif key_type == global.KeyItem.SHROOM:
            key_name = "SHROOM KEY"
        elif key_type == global.KeyItem.CAT:
            key_name = "SPORE KEY"
        level.player.sayThis("Got the " + key_name + "!")
    else:
        var num_keys = global.memory["key"] if global.memory.has("key") else null
        if num_keys == null:
            global.memory["key"] = 0
            level.uiLayer.get_node("KeyStatusRect").visible = true
            level.uiLayer.get_node("KeyStatusRect").rect_scale = Vector2(1.5, 1.5)
            level.uiLayer.get_node("KeyStatusRect").rect_position = Vector2(200, 325)
        global.memory["key"] += 1
    global.pauseGame = false
    global.pauseMoveInput = false
    # level.spawnKeyFollower(level.player.global_transform.origin)
    key.okay_im_done = true
    key.queue_free()
    level.player.pauseInput = false
    level.player.aniPlayer.play("stand")

func isActive(_debug=false):
    return true
