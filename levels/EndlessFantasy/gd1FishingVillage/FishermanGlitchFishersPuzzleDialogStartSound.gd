extends AudioStreamPlayer

onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  pass # i moved him, so not a good joke anymore
  # if not global.memory["zora_flippers"]:
  #   return
  # if global.memory["zora_flippers"] < 3:
  #   var newText = "...i'm just going to\nforget i saw that"
  #   textBox.text_final = newText
  #   textBox.textNode.bbcode_text = newText
  #   global.memory["zora_flippers"] = 3
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
