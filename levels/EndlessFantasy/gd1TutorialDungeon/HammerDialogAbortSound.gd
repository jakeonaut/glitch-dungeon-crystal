extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  if not textBox.showYesNoOptions or not textBox.selectedYesNoOption:
    return

  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  var num_gems_needed = 20
  if num_gems < 20:
    level.player.errorSound.play()
    level.player.sayThis("need " + str(num_gems_needed - num_gems) + " more shards")
    return

  if not global.memory["broomerang"]:
    global.incrementLevelZoneThing("num_mini_crystal_cubes", -num_gems_needed)
    global.memory["broomerang"] = 1
    var sweep_button_text = global.getLargeInputText("sub_action_button")
    level.player.sayThis("•\"BROOMERANG\" get: press " + sweep_button_text + " twice\nto throw your broom!!!")
    musicPlayer.playTreasureJingle(-20)
  elif not global.memory["multi_broom"]:
    global.incrementLevelZoneThing("num_mini_crystal_cubes", -num_gems_needed)
    global.memory["multi_broom"] = 1
    var sweep_button_text = global.getLargeInputText("sub_action_button")
    level.player.sayThis("•\"FLOATING BROOM\" get: \nhold " + sweep_button_text + " button\nkeep the broom swinging!!!")
    musicPlayer.playTreasureJingle(-20)
    
func preActivateScript():
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
