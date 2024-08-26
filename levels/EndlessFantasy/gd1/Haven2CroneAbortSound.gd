extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

var NUM_GEMS_FOR_BROOMERANG = 30
var NUM_GEMS_FOR_BROOMERANG_WARP = 99
func activateScript():
  if global.memory["crone"] == 0:
    if not textBox.showYesNoOptions or not textBox.selectedYesNoOption:
        return
    global.memory["crone"] = 1
  elif global.memory["crone"] == 1:
    var num_cubes = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
    if global.memory["broomerang"] < 1 and textBox.selectedYesNoOption:
      if num_cubes >= NUM_GEMS_FOR_BROOMERANG:
        global.memory["broomerang"] = 1
        level.player.sayThis("BROOMERANG GET!\nsweep twice to THROW")
      else:
        level.player.errorSound.play()
        level.player.sayThis("need " + str(NUM_GEMS_FOR_BROOMERANG - num_cubes) + " more gems")
    elif global.memory["broomerang"] < 2 and textBox.selectedYesNoOption: 
      if num_cubes >= NUM_GEMS_FOR_BROOMERANG_WARP:
        global.memory["broomerang"] = 2
        level.player.sayThis("BROOMERANG WARP GET!\nsweep three times to WARP")
      else:
        level.player.errorSound.play()
        level.player.sayThis("need " + str(NUM_GEMS_FOR_BROOMERANG_WARP - num_cubes) + " more gems")

    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
