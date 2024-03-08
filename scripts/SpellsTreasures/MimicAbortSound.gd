extends AudioStreamPlayer

onready var mimic = get_node("../../../..")
onready var mimicNPC = get_node("../../../../MimicNPC")
onready var treasureSpellCollectable = get_node("../../../../TreasureSpellCollectable")
func _ready():
  pass

func activateScript():
  # OVERRIDE ME
  pass
    
func preActivateScript():
  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  if num_gems >= mimic.num_gems_needed:
    global.incrementLevelZoneThing("num_mini_crystal_cubes", -mimic.num_gems_needed)
    treasureSpellCollectable.passiveActivate(0, true)

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
