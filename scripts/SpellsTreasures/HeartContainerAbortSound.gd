extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_mimic = false

onready var heart = get_node("../../..")
func _ready():
    yield(TempTimer.idle_frame(self), "timeout")
    heart.message = tr("NPC.Crystal.6") + " +1"
    
var override_level_zone = null
func activateScript():
    # global.getKeyInMemory(key_type, level)

    if is_mimic:
        global.memory["mimic_heart"] += 1
    else:
        var levelZoneName = global.currLevelZone if override_level_zone == null else override_level_zone
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
    level.player.sayThis(tr("NPC.Crystal.6") + " +1\n")

func isActive(_debug=false):
    return true
