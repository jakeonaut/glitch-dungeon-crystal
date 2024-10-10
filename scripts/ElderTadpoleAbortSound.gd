extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var elderTadpoleNPC = get_node("../../..")

func _ready():
  pass

func activateScript():
  if elderTadpoleNPC.am_i_sleepy or textBox.was_smacked:
    return
  if not elderTadpoleNPC.has_broom:
    # elderTadpoleNPC.has_broom = true
    # elderTadpoleNPC.secretAniPlayer.stop()
    # elderTadpoleNPC.secretAniPlayer.clear_queue()
    # elderTadpoleNPC.secretAniPlayer.play("snatchBroom")
    # level.summonSmokeClouds(elderTadpoleNPC.global_transform.origin, 3, false, false)
    # global.memory["has_gotten_broom"] = 0
    # global.memory["broom"] = false
    # level.player.glitchTickle()
    # level.player.nullify()
    # level.player.shroomAniPlayer.stop()
    # level.player.shroomAniPlayer.clear_queue()
    # level.player.shroomAniPlayer.queue("shrink")
    # level.player.shroomAniPlayer.queue("adjust")
    # level.player.nesting_doll_state = global.NestingDoll.BABY
    # global.memory["nesting_doll"] = global.NestingDoll.BABY
    # level.player.updateNestingDoll(global.NestingDoll.BABY)

    elderTadpoleNPC.textBoxContainer.bbText = "•We must awaken the Goddess.\nPlease, collect her 3 dreams,\nscattered in the darkest\ncorners of this dungeon."
    elderTadpoleNPC.textBoxContainer.setVars()
    # yield(get_tree().create_timer(0.1), "timeout")
    # elderTadpoleNPC.activate(true)
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
