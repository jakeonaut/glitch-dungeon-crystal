extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var crystalGeode2 = get_node("../../../..")

func _ready():
  pass

var NUM_GEMS_FOR_BROOMERANG = 30
var NUM_GEMS_FOR_BROOMERANG_WARP = 99
func activateScript():
  if global.memory["crone"] == 0:
    return
  elif global.memory["crone"] == 1 and global.memory["broomerang"] < 2:
    var text = "•trade " + str(NUM_GEMS_FOR_BROOMERANG) + " gems for\n[color=red]BROOMERANG[/color]?"
    if global.memory["broomerang"] == 1:
      text = "•trade " + str(NUM_GEMS_FOR_BROOMERANG_WARP) + " gems for\n[color=red]BROOMERANG WARP[/color]?"
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = true
  else:
    var text = "•keeheehee\nyou've taken all I can offer"
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
