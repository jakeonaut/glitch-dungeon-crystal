extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")

func _ready():
  set_process(true)
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  var finalText = tr("NPC.Angel.1")
  textBox.text_final = finalText
  textBox.textNode.bbcode_text = finalText
        
func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
