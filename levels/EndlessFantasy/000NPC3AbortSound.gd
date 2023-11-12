extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC3 = get_node("../../..")

func _ready():
    yield(get_tree().create_timer(0.5), "timeout")
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif not memory:
        doActivateScriptStuff()
    elif memory:
        NPC3.queue_free()
        

var has_talked = false
func activateScript():
    if not has_talked:
        doActivateScriptStuff()
    else:
        level.summonSmokeClouds(NPC3.global_transform.origin, 3, true, true)
        global.activeInteractor = null
        NPC3.queue_free()
        global.setStaticLevelZoneLevelVar(level, self.name, true)

func doActivateScriptStuff():
    NPC3.textBoxContainer.bbText = "• truthfully, i have nothing\nmore to say"
    NPC3.textBoxContainer.setVars()
    global.setStaticLevelZoneLevelVar(level, self.name, false)
    NPC3.can_camera_zoom = false
    NPC3.textBox.can_camera_zoom = false
    has_talked = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true