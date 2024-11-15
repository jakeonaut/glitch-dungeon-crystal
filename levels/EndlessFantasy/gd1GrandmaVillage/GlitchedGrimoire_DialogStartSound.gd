extends AudioStreamPlayer

func _ready():
  pass


func activateScript():
    var text = "•Grimoire Memory\nNow you can use 3 spells.\n" + global.getLargeInputText("left_button") + ", " + global.getLargeInputText("alt_action_button") + " swaps back and forth"
    var textBox = get_node("..")
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