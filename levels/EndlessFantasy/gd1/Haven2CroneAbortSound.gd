extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var NPC = get_node("../../..")

func _ready():
  pass

func activateScript():
  var num_cubes = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")

  if global.memory["crone"] == 0:
    if not textBox.showYesNoOptions or not textBox.selectedYesNoOption:
        return
    global.memory["crone"] = 1
    yield(get_tree().create_timer(0.1), "timeout")
    NPC.activate(true)
  elif global.memory["crone"] == 1:
    if global.memory["broomerang"] < 1 and textBox.selectedYesNoOption:
      if num_cubes >= global.NUM_GEMS_FOR_BROOMERANG:
        global.memory["broomerang"] = 1
        level.player.sayThis("BROOMERANG GET!\nsweep twice to THROW")
        global.memory["crone"] = 2
      else:
        level.player.errorSound.play()
        level.player.sayThis("need " + str(global.NUM_GEMS_FOR_BROOMERANG - num_cubes) + " more gems")
  elif global.memory["crone"] == 2:
    global.memory["crone"] = 3
  elif global.memory["crone"] == 3:
    if global.memory["broomerang"] < 2 and textBox.selectedYesNoOption: 
      if num_cubes >= global.NUM_GEMS_FOR_BROOMERANG_WARP:
        global.memory["broomerang"] = 2
        level.player.sayThis("BROOMERANG WARP GET!\nsweep three times to WARP")
      else:
        level.player.errorSound.play()
        level.player.sayThis("need " + str(global.NUM_GEMS_FOR_BROOMERANG_WARP - num_cubes) + " more gems")

    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
