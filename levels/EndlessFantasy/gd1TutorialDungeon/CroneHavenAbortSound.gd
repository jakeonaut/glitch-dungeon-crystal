extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var frogCroneNPC = get_node("../../..")
onready var debugDoor = get_tree().get_root().get_node("Game/Viewport/level/DebugDoor")

func _ready():
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif memory:
      frogCroneNPC.queue_free()
      debugDoor.visible = true
        

func activateScript():
    level.summonSmokeClouds(frogCroneNPC.global_transform.origin, 3, true, true)
    global.activeInteractor = null
    frogCroneNPC.queue_free()
    global.setStaticLevelZoneLevelVar(level, self.name, true)
    debugDoor.visible = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true
