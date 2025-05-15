extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  var text = tr("NPC.LostSoul.1")
  if global.memory.has("flowerPot") and global.memory["flowerPot"]:
    if global.memory["mole_cricket"] == 0:
      text += "\n" + tr("NPC.LostSoul.2")
    else:
      text = tr("NPC.LostSoul.3")
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
