extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  if textBox.has_been_shown and global.memory.has("fishingRod") and global.memory["fishingRod"]:
    if global.memory["zora_flippers"] == 0:
      npc.textBoxContainer.bbText = tr("NPC.BigFisherman.2")
    else:
      npc.textBoxContainer.bbText = tr("NPC.BigFisherman.3")
    
    npc.textBoxContainer.setVars()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
