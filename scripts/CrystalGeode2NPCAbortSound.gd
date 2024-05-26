extends AudioStreamPlayer

onready var crystalGeode2 = get_node("../../../..")
func _ready():
  pass

func activateScript():
  # OVERRIDE ME
  pass
    
func preActivateScript():
  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  crystalGeode2.num_gems_needed = 1
  if num_gems >= crystalGeode2.num_gems_needed:
    global.incrementLevelZoneThing("num_mini_crystal_cubes", -crystalGeode2.num_gems_needed)
    crystalGeode2.getPurified()

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
