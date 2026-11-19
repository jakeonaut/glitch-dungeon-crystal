extends AudioStreamPlayer

func _ready():
  pass


func activateScript():
    var text = "•You got \"Little Bird\". It can \nfly you to angel statues.\npress " + global.getLargeInputText("open_inventory") + " to select from map"
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