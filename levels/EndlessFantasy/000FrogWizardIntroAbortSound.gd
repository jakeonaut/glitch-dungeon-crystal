extends AudioStreamPlayer

onready var NPC = get_node("../../..")
onready var floorSpell = get_node("../../../../FloorSpell")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    if not has_done_my_magick:
        NPC.pressing_move_left = true
        yield(get_tree().create_timer(0.5), "timeout")
        floorSpell.passiveActivate(1.0)
        yield(get_tree().create_timer(3.0), "timeout")
        NPC.pressing_move_left = false
        NPC.textBoxContainer.bbText = "•GODDESS is source of all life\n•but sHe has been broken up\n•into 100 pieces.\n•you just collected 3!!\npress DOWN to enter door"
        NPC.textBoxContainer.setVars()
        NPC.textBox.is_important = true
        NPC.textBox.is_really_important = true
        has_done_my_magick = true
    elif has_done_my_magick:
        NPC.visible = false
        NPC.can_activate = false
        NPC.is_active = false
        global.doorSound.play()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true