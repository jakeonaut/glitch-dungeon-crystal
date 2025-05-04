extends AudioStreamPlayer

onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  if not global.memory.has("spellbookPage"):
    var text = tr("NPC.Tutorial.10_2")
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
