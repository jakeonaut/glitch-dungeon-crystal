extends AudioStreamPlayer

onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  if global.memory.has("roomPath") and "FlingAndFlung" in global.memory["roomPath"]:
    var newText = "oh, you fell! if you glitch out\nyou can Return.\nto that other room"
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText
    # global.memory["zora_flippers"] = 3
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
