extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")

func _ready():
  pass

func activateScript():
  if global.memory.has("flowerPot") and global.memory["flowerPot"]:
    if global.memory["mole_cricket"] == 0:
      npc.textBoxContainer.bbText = tr("NPC.LostSoul.2")
    else:
      npc.textBoxContainer.bbText = tr("NPC.LostSoul.3")
    
    npc.textBoxContainer.setVars()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
