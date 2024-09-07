extends AudioStreamPlayer

onready var textBox = get_node("..")
func _ready():
  pass

var NUM_CRYSTAL_GEODES_TO_BOSS = 4
func activateScript():
  var allCrystalGeodes = global.getThingFromAllLevelZonez("crystal_geode")
  if global.getLevelZoneThing("crystal_geode"):
    var newText = "*mewmew*\n(...you've already purified the\n[color=blue]CRYSTAL[/color] in this area!)\nthere are only "
    newText += str(NUM_CRYSTAL_GEODES_TO_BOSS - allCrystalGeodes) + " left"
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText
  else:
    var newText = "*meow*\n•(for some weird reason,\nyou can hear me?)\n•(i smell an unpurified\n[color=red]CRYSTAL[/color] in this area)"
    newText += "\n" + str(NUM_CRYSTAL_GEODES_TO_BOSS - allCrystalGeodes) + " total left!"
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
