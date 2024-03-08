extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
onready var floorSpell = get_node("../../../../FloorSpell")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    if not has_done_my_magick:
        NPC.textBoxContainer.bbText = ""
        NPC.textBoxContainer.setVars()
        NPC.pressing_move_left = true
        yield(get_tree().create_timer(1.00), "timeout")
        floorSpell.passiveActivate(1.0)
        yield(get_tree().create_timer(3.30), "timeout")
        NPC.pressing_move_left = false
        NPC.aniPlayer.stop()
        NPC.aniPlayer.clear_queue()
        NPC.textBoxContainer.bbText = "•your broom... how did you do that?\n... \npress UP to enter door"
        NPC.textBoxContainer.setVars()
        NPC.textBox.is_important = true
        NPC.textBox.is_really_important = true
        has_done_my_magick = true
    elif has_done_my_magick:
        level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
        NPC.visible = false
        NPC.can_activate = false
        NPC.is_active = false
        global.doorSound.play()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
