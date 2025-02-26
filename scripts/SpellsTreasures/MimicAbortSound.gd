extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var mimic = get_node("../../../..")
onready var mimicNPC = get_node("../../../../MimicNPC")
onready var treasureSpellCollectable = get_node("../../../../TreasureSpellCollectable")
onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  if not treasureSpellCollectable.okay_im_done and textBox.selectedYesNoOption:
    var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
    if num_gems >= mimic.num_gems_needed:
      global.incrementLevelZoneThing("num_mini_crystal_cubes", -mimic.num_gems_needed)
      treasureSpellCollectable.passiveActivate(0, true)
      mimicNPC.is_active = false
    else:
      level.player.errorSound.play()
      level.player.sayThis(tr("NPC.TreasureMimic.3") % str(mimic.num_gems_needed - num_gems))
  level.player.pauseInput = false
    
func preActivateScript():
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
