extends AudioStreamPlayer

func _ready():
  pass

onready var NPC5 = get_node("../../../../NPC5") if has_node("../../../../NPC5") else null
onready var textBox = get_node("..")
func activateScript():
  if NPC5:
    NPC5.textBox.hideTextbox()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(debug=false):
  if "sweep" in textBox.text_final:
    var sweep_button_text = global.getKeyCodeStr(global.getKeyCode("sub_action_button"))
    textBox.text_final = "•this dust just showed up!\nhow odd... dearie, could you\nsweep up with " + sweep_button_text + "?"
  return true
