extends AudioStreamPlayer

onready var textBox = get_node("..")

func _ready():
  set_process(true)
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  var initial_text = ""
  if global.memory["hammer"] == 0:
    initial_text = "•I lost my smithing hammer...\n•I can't work without it!\n•oh... this? this is my\nrecreational hammer...\n•howe shameful..."
    textBox.showYesNoOptions = false
  elif global.memory["hammer"] == 1:
    global.memory["hammer"] = 2
    initial_text = "•my hammer! I can smith again!\n•that broom.. well, it's\nno sword, but I can make do\n•speake with me to enchant it"
    textBox.showYesNoOptions = false
  elif not global.memory["broomerang"] or not global.memory["multi_broom"]:
    initial_text = "•I can infuse 20 shards\ninto your broom handle to\nenchant it. yes?"
    textBox.showYesNoOptions = true
  else:
    initial_text = "•I can helpe you no more."
    textBox.showYesNoOptions = false

  textBox.text_final = initial_text
  textBox.textNode.bbcode_text = initial_text
        
func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
