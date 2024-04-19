extends AudioStreamPlayer

func _ready():
  pass

onready var NPC5 = get_node("../../../../NPC5") if has_node("../../../../NPC5") else null
onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")
func activateScript():
  if NPC5:
    NPC5.textBox.hideTextbox()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  if "sweep" in textBox.text_final:
    var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
    textBox.text_final = "•some glitch dust appeared!\nhow odd... dearie, could you\nsweep up with [lb]" + sweep_button_text + "[rb]?"
    textBoxContainer.bbText = textBox.text_final

  return true
