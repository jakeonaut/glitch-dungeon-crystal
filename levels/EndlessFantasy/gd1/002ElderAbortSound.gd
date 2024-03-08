extends AudioStreamPlayer

onready var NPC = get_node("../../..")

func _ready():
    pass

func activateScript():
    NPC.can_camera_zoom = false
    NPC.textBox.can_camera_zoom = false
    NPC.textBoxContainer.bbText = "•a little tip:\nyou can sweep up color\nspells as well..."
    NPC.textBoxContainer.setVars()

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
