extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")

var initial_text = ""
func _ready():
  set_process(true)

func _process(_delta):
  if initial_text == "" and textBox:
    initial_text = textBox.textNode.bbcode_text
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  var finalText = initial_text
      
  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  if num_gems > 50:
    finalText += "\n•youve got the goods.. fair trade!"

  textBox.text_final = finalText
  textBox.textNode.bbcode_text = finalText
        
func isActive():
  # OVERRIDE ME... if you dare
  return true
