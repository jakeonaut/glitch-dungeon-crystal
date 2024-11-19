extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
func _ready():
  pass

func activateScript():
  var newText = null

  if (
    global.memory["zora_flippers"] and global.memory["mole_cricket"] and global.memory["mushroom_soul"] and
    global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.FISH) and
    global.memory["key_items"].has(global.KeyItem.CAT) and global.memory["key_items"].has(global.KeyItem.PYRAMID)
  ):
    newText = "*mewmew*\n(...i can only smell the goddess..)"
  else:
    newText = "*mew..* (smells like you're\n missing some key items.."
    if global.memory["zora_flippers"] == 0 or not (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.CAT)):
      newText += "\nsearch tadpole bog"
    if global.memory["mole_cricket"] == 0 or not (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.FISH)):
      newText += ",\nsearch cricket caves"
    if global.memory["mushroom_soul"] == 0 or not (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.PYRAMID)):
      newText += ",\nsearch moldy dogwoods"
    newText += "\ni'll mark your map!)"
    level.redrawMap()

  if newText != null:
    textBox.text_final = newText
    textBox.textNode.bbcode_text = newText

  var tempLevelZone = global.currLevelZone
  for levelZone in ["gd1FishingVillage", "gd1ToxicJungle", "gd1ShiftingSandLand"]:
    global.currLevelZone = levelZone
    global.setLevelZoneThing("babushkaCatSniffed", 2)
  global.currLevelZone = tempLevelZone
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
