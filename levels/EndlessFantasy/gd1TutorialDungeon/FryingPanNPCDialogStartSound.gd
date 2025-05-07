extends AudioStreamPlayer

onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  var numAngelEggs = global.getThingFromAllLevelZonez("angelEgg")
  var text = tr("NPC.FryingPan.1") + tr("NPC.BabushkaCat.2_2")
  if numAngelEggs >= global.MAX_ANGEL_EGGS:
    text = tr("NPC.FryingPan.2")
  
  textBox.text_final = text
  textBox.textNode.bbcode_text = text
  textBox.showYesNoOptions = false
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
