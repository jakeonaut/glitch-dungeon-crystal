extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var crystalGeode2 = get_node("../../../..")

func _ready():
  pass


func activateScript():
  var isElderTadpole = global.memory["priestess"] > 0

  if global.memory["crone"] == 0:
    return
  # elif global.memory["crone"] == 2:
  #   var text = "•trade " + str(global.NUM_GEMS_FOR_ENCHANTED_BAG) + " shards for\n[color=red]ENCHANTED BAG[/color]?"
  #   textBox.text_final = text
  #   textBox.textNode.bbcode_text = text
  #   textBox.showYesNoOptions = true
  elif global.memory["broomerang"] < 1:
    var text = "•trade " + str(global.NUM_GEMS_FOR_BROOMERANG) + " shards for\n[color=red]BROOMERANG[/color]?"
    # if global.memory["broomerang"] == 1:
    #   text = "•trade " + str(global.NUM_GEMS_FOR_BROOMERANG_WARP) + " shards for\n[color=red]BROOMERANG WARP[/color]?"
    textBox.text_final = text
    textBox.textNode.bbcode_text = text
    textBox.showYesNoOptions = true
  else:
    var text = "•keeheehee\nyou've taken all I can offer\n•please, purify the crystals" if not isElderTadpole else "•your broom is very mighty!\nplease find mother's dreams.\nso we may awaken her."
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
