extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var mimic = get_node("../../../..")
onready var mimicNPC = get_node("../../../../MimicNPC")
onready var treasureSpellCollectable = get_node("../../../../TreasureSpellCollectable")
func _ready():
  pass

func activateScript():
  if not treasureSpellCollectable.okay_im_done:
    if global.memory.has("fishingRod") and global.memory["fishingRod"] and global.memory["zora_flippers"] == 0:
      treasureSpellCollectable.passiveActivate(0, true)
      mimicNPC.is_active = false
  level.player.pauseInput = false
    
func preActivateScript():
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
