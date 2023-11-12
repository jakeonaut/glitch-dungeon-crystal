extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC3 = get_node("../../..")

func _ready():
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif memory:
        NPC3.queue_free()
        

func activateScript():
    level.summonSmokeClouds(NPC3.global_transform.origin, 3, true, true)
    global.activeInteractor = null
    NPC3.queue_free()
    global.setStaticLevelZoneLevelVar(level, self.name, true)
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true
