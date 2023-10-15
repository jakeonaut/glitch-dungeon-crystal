extends AudioStreamPlayer

onready var NPC = get_node("../../..")
onready var NPCSmallInteractionArea = get_node("../../../SmallInteractionArea")

func _ready():
    pass

func activateScript():
    NPCSmallInteractionArea.global_transform.origin = NPC.global_transform.origin + Vector3(3, -1, 0)
    NPC.textBoxContainer.bbText = "•i don't know how to\nget down yet"
    NPC.textBoxContainer.setVars()
    
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    activateScript()

func isActive():
    # OVERRIDE ME... if you dare
    return true
