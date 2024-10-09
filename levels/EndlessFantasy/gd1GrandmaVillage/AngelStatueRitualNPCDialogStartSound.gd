extends AudioStreamPlayer

onready var textBox = get_node("..")

func _ready():
  pass


func activateScript():
    var text = "•I will teach you Ritual. \nTo travel between Angels\n•like so:\ndo this:"
    for ritual_step in global.correct_ritual:
        text += global.getLargeInputText(ritual_step)
    text += "\n•Pray twice, dance, jump,\n    then Return."
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
