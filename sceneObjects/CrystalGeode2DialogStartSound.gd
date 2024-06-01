extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var crystalGeode2 = get_node("../../../..")

func _ready():
  pass

func activateScript():
  if crystalGeode2.is_purified:
    var text = "•the crystal is shining brightly"
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = false
  else:
    var num_cubes = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
    if num_cubes >= crystalGeode2.num_gems_needed:  
      var text = "•offer " + str(crystalGeode2.num_gems_needed) + " crystal shards\n•to purify the crystal?"
      textBox.text_final = text
      textBox.textNode.bbcode_text = text
      textBox.showYesNoOptions = true
    else:
      var text = "•you feel corruption...\ncollect " + str(crystalGeode2.num_gems_needed) + " crystal shards\nto purify"
      textBox.text_final = text
      textBox.textNode.bbcode_text = text
      textBox.showYesNoOptions = false
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
