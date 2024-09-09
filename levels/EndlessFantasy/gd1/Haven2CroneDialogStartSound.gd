extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var crystalGeode2 = get_node("../../../..")

func _ready():
  pass


func activateScript():
  if global.memory["crone"] == 0:
    return
  elif global.memory["crone"] == 2:
    var text = "•trade " + str(global.NUM_GEMS_FOR_ENCHANTED_BAG) + " shards for\n[color=red]ENCHANTED BAG[/color]?"
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = false
  elif (global.memory["crone"] == 1 or global.memory["crone"] == 3) and global.memory["broomerang"] < 2:
    var text = "•trade " + str(global.NUM_GEMS_FOR_BROOMERANG) + " shards for\n[color=red]BROOMERANG[/color]?"
    if global.memory["broomerang"] == 1:
      text = "•trade " + str(global.NUM_GEMS_FOR_BROOMERANG_WARP) + " shards for\n[color=red]BROOMERANG WARP[/color]?"
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = true
  else:
    var text = "•keeheehee\nyou've taken all I can offer\n•please, purify the crystals"
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
