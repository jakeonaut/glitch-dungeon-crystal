extends AudioStreamPlayer

onready var NPC = get_node("../../..")
onready var NPCSmallInteractionArea = get_node("../../../SmallInteractionArea")

func _ready():
    pass

func activateScript():
    NPCSmallInteractionArea.global_transform.origin = NPC.global_transform.origin
    NPCSmallInteractionArea.get_node("CollisionShape").shape.set_extents(Vector3(2, 1.3, 1.3))
    
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    activateScript()

func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true
