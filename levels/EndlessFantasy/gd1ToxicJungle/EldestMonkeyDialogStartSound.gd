extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  var text = tr("NPC.EldestCreature.1")
  if global.memory.has("cutePet") and global.memory["cutePet"]:
    if global.memory["mushroom_soul"] == 0:
      text += "\n" + tr("NPC.EldestCreature.2")
    else:
      text = tr("NPC.EldestCreature.3")
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
