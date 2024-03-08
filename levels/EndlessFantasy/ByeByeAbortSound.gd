extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")

func _ready():
    pass

func activateScript():
    level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
    NPC.visible = false
    NPC.can_activate = false
    NPC.is_active = false
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true