extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var crystalGeode2 = get_node("../../../..")

func _ready():
  pass

func activateScript():
  var textBox = get_node("..")
  if global.memory["crone"] == 0:
    return
  # elif global.memory["crone"] == 2:
  #   var text = "•trade " + str(global.NUM_GEMS_FOR_ENCHANTED_BAG) + " shards for\n[color=red]ENCHANTED BAG[/color]?"
  #   textBox.text_final = text
  #   textBox.textNode.bbcode_text = text
  #   textBox.showYesNoOptions = true
  elif (global.memory["hard_mode"] == 0 and global.memory["broomerang"] < 2) or (global.memory["hard_mode"] > 0 and global.memory["broomerang"] == 0):
    var text = tr("NPC.Crone.4_1") % str(global.NUM_GEMS_FOR_BROOMERANG)
    if global.memory["broomerang"] == 1:
      text = tr("NPC.Crone.4_2") % str(global.NUM_GEMS_FOR_BROOMERANG_WARP)
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = true
  else:
    var text = tr("NPC.Crone.7")
    if global.memory["clean_crystals"] >= 4:
      text = tr("NPC.Elder.6")
    
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
