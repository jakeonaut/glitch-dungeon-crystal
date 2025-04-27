extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export(int, "NORMAL", "FISH", "PYRAMID", "SHROOM", "CAT") var key_type

func _ready():
    pass
    
onready var heart = get_node("../../..")
func activateScript():
    # global.getKeyInMemory(key_type, level)

    var levelZoneName = global.currLevelZone
    
    match levelZoneName:
        "gd1FishingVillage":
            global.memory["angler_heart"] = 1
        "gd1ToxicJungle":
            global.memory["baba_heart"] = 1
        "gd1ShiftingSandLand":
            global.memory["claydol_heart"] = 1

    global.pauseGame = false
    global.pauseMoveInput = false
    # level.spawnKeyFollower(level.player.global_transform.origin)
    heart.okay_im_done = true
    heart.queue_free()
    level.player.pauseInput = false
    level.player.aniPlayer.play("stand")

func isActive(_debug=false):
    return true
