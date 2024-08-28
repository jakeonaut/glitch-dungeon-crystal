extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")

func _ready():
    pass
        

var which_one = 0
func activateScript():
  if which_one == 0:
    level.aniPlayer.play("appearEnd")
    NPC.textBoxContainer.bbText = "•curses!! 1000s of years\n studying glitch magick\n•and still bested by a hag.."
    NPC.textBoxContainer.setVars()
    which_one = 1
  elif which_one == 1:
    # NPC.mySprite.updateBaseFrame(6, 6)
    NPC.textBoxContainer.bbText = "•the GODDESS still hasn't\nshown herself to me\n•was I wrong?"
    NPC.textBoxContainer.setVars()
    which_one = 2
  elif which_one == 2:
    NPC.mySprite.updateBaseFrame(6, 6)
    NPC.textBoxContainer.bbText = "•well, this world must be ending soon.\nwhat do you care?"
    NPC.textBoxContainer.setVars()
    which_one = 3
  elif which_one == 3:
    NPC.is_active = false
    NPC.mySprite.updateBaseFrame(6, 7)
    yield(get_tree().create_timer(1.0), "timeout")
    level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
    NPC.visible = false
    which_one = 3
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true