extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC3 = get_node("../../..")
onready var textBox = get_node("..")

func _ready():
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    if global.memory["clean_crystals"] >= 1:
        NPC3.queue_free()
        return

    var memory = global.getStaticLevelZoneLevelVar(level, self)
    if memory:
        doActivateScriptStuff()
        

# var has_talked = false
func activateScript():
    # if not has_talked:
    doActivateScriptStuff()
    # if textBox.was_smacked:
    #     level.summonSmokeClouds(NPC3.global_transform.origin, 3, true, true)
    #     global.activeInteractor = null
    #     NPC3.queue_free()
    #     global.setStaticLevelZoneLevelVar(level, self, true)

func doActivateScriptStuff():
    var door = level.get_node("Door")

    if door.is_locked:
        NPC3.textBoxContainer.bbText = "•I think the crystals are ahead\nbut I can't get past this door.."
    else:
        NPC3.textBoxContainer.bbText ="•Ah! great work.\nI'll meet you on ahead"
    NPC3.textBoxContainer.setVars()
    global.setStaticLevelZoneLevelVar(level, self, true)
    NPC3.can_camera_zoom = false
    NPC3.textBox.can_camera_zoom = false
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
