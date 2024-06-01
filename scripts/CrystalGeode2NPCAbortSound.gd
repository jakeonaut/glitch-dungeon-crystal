extends AudioStreamPlayer

onready var crystalGeode2 = get_node("../../../..")
onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  if crystalGeode2.is_purified:
    return
    
  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  if textBox.selectedYesNoOption and num_gems >= crystalGeode2.num_gems_needed:
    global.incrementLevelZoneThing("num_mini_crystal_cubes", -crystalGeode2.num_gems_needed)
    crystalGeode2.getPurified()
    
func preActivateScript():
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
