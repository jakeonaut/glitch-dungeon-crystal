extends AudioStreamPlayer

onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  # OVERRIDE ME
  # textBox.text_final = "hi"
  # textBox.textNode.bbcode_text = "hi"
  pass
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
