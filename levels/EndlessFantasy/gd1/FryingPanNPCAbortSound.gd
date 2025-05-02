extends AudioStreamPlayer

func _ready():
  pass

func activateScript():
  var level = get_tree().get_root().get_node("Game/Viewport/level")
  var textBox = get_node("..")
  var NPC = textBox.textboxParent.get_ref()
  if textBox.was_smacked:
    return

  var num_cubes = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")

  if global.memory["crone"] == 0:
    global.memory["crone"] = 1
    yield(get_tree().create_timer(0.1), "timeout")
    NPC.showYesNoOptions = true
    NPC.activate(true)
  elif global.memory["crone"] == 1 and global.memory["broomerang"] < 1:
    if global.memory["broomerang"] < 1 and textBox.selectedYesNoOption:
      if num_cubes >= global.NUM_GEMS_FOR_BROOMERANG:
        global.incrementLevelZoneThing("num_mini_crystal_cubes", -global.NUM_GEMS_FOR_BROOMERANG)
        global.memory["broomerang"] = 1
        level.player.sayThis(tr("NPC.Crone.6"))
        global.memory["crone"] = 2
        if global.demo_mode <= 0: Steam.set_achievement("BROOMERANG")
      else:
        level.player.errorSound.play()
        level.player.sayThis(tr("NPC.Crone.5") % str(global.NUM_GEMS_FOR_BROOMERANG - num_cubes))
  elif global.memory["crone"] == 2 or global.memory["broomerang"] == 1:
    if textBox.selectedYesNoOption: 
      if num_cubes >= global.NUM_GEMS_FOR_BROOMERANG_WARP:
        global.incrementLevelZoneThing("num_mini_crystal_cubes", -global.NUM_GEMS_FOR_BROOMERANG_WARP)
        global.memory["broomerang"] = 2
        level.player.sayThis(tr("NPC.Treasure.10"))
        global.memory["crone"] = 3
      else:
        level.player.errorSound.play()
        level.player.sayThis(tr("NPC.Crone.5") % str(global.NUM_GEMS_FOR_BROOMERANG_WARP - num_cubes))
  # elif global.memory["crone"] == 3 or (global.memory["broomerang"] == 1): # and global.memory["max_hp"] >= 2):
  #   if global.memory["broomerang"] < 2 and textBox.selectedYesNoOption: 
  #     if num_cubes >= global.NUM_GEMS_FOR_BROOMERANG_WARP:
  #       global.incrementLevelZoneThing("num_mini_crystal_cubes", -global.NUM_GEMS_FOR_BROOMERANG_WARP)
  #       global.memory["broomerang"] = 2
  #       level.player.sayThis("BROOMERANG WARP GET!\nsweep three times to WARP")
  #     else:
  #       level.player.errorSound.play()
  #       level.player.sayThis("need " + str(global.NUM_GEMS_FOR_BROOMERANG_WARP - num_cubes) + " more shards.\n" + suffix)

    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
