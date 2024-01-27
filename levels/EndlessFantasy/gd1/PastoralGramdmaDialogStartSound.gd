extends AudioStreamPlayer

func _ready():
  pass

onready var NPC5 = get_node("../../../../NPC5") if has_node("../../../../NPC5") else null
func activateScript():
  if NPC5:
    NPC5.textBox.hideTextbox()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive():
  # OVERRIDE ME... if you dare
  return true
