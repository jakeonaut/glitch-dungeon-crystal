extends AudioStreamPlayer

onready var textBox = get_node("..")
func _ready():
  pass

func activateScript():
  var newText = null

  if global.memory["zora_flippers"] and global.memory["mole_cricket"] and global.memory["mushroom_soul"]:
    newText = "*mewmew*\n(...seems like you've found\nall the SOULs)"
  else:
    newText = "*mew..* (smells like you're\n missing some SOULs.. try\n"
  if global.memory["zora_flippers"] == 0:
    newText += "search the fish village,"
  if global.memory["mole_cricket"] == 0:
    newText += "search the cricket caves,"
  elif global.memory["mushroom_soul"] == 0:
    newText += "search the fungus forest,"
    
  if newText != null:
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
