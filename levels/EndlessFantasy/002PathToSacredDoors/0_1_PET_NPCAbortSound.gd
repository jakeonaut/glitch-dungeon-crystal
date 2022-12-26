extends AudioStreamPlayer

onready var NPC = get_node("../../..")
onready var CHUNKY = get_node("../../../../CHUNKY")

func _ready():
    pass

func activateScript():
    global.activeInteractor = null
    global.memory["max_mp"] += 5
    global.memory["mp"] = global.memory["max_mp"]
    if not global.memory.has("inventory"):
        global.memory["inventory"] = []
    global.memory["inventory"].append(global.Inventory.PET_0)
    global.pauseGame = false
    global.pauseMoveInput = false
    CHUNKY.queue_free()
    NPC.queue_free()
    
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    activateScript()

func isActive():
    # OVERRIDE ME... if you dare
    return true
