extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var elderTadpoleNPC = get_node("../../..")

func _ready():
  pass

func activateScript():
  if not elderTadpoleNPC.has_broom:
    elderTadpoleNPC.has_broom = true
    elderTadpoleNPC.secretAniPlayer.stop()
    elderTadpoleNPC.secretAniPlayer.clear_queue()
    elderTadpoleNPC.secretAniPlayer.play("snatchBroom")
    level.summonSmokeClouds(elderTadpoleNPC.global_transform.origin, 3, false, false)
    global.memory["has_gotten_broom"] = 0
    global.memory["broom"] = false
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
