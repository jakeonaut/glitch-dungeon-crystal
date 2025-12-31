extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var NPC = get_node("../../..")
func _ready():
  pass

var NUM_CRYSTAL_GEODES_TO_BOSS = 4
func activateScript():
  if textBox.was_smacked:
    self.pitch_scale = 1.4
    return
  self.pitch_scale = .7

  if global.memory["priestess"] == 0 and not global.getLevelZoneThing("crystal_geode"):
    global.setLevelZoneThing("babushkaCatSniffed", 1)
    if global.getLevelZoneThing("crystal_geode"):
      var newText = "*mewmew*\n(...you've already awoken the\n[color=#0798bf]Crystal[/color] in this zone!)"
      newText += "\n*sniff* (but is someone else in that place?)"
        
      
      textBox.text_final = newText
      textBox.textNode.bbcode_text = newText
    else:
      var newText = tr("NPC.BabushkaCat.2")
      # if global.memory["has_map_item"]:
      #   newText += tr("NPC.BabushkaCat.2_2")
      textBox.text_final = newText
      textBox.textNode.bbcode_text = newText
      level.redrawMap()

  elif global.memory["world_of_ruin"] > 0:
    var newText = "*meow*, (seems like this place\nis falling apart. let's get out!!\ncheck your map?)"
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
