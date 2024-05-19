extends AudioStreamPlayer

onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  if global.getLevelZoneThing("crystal_geode"):
    var newText = "*mewmew*\n(...you've already purified the\n[color=blue]CRYSTAL[/color] in this area!)"
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
