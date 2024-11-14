extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
func _ready():
  pass

var NUM_CRYSTAL_GEODES_TO_BOSS = 4
func activateScript():
  if textBox.was_smacked:
    return

  if global.memory["priestess"] == 0:
    var allCrystalGeodes = global.getThingFromAllLevelZonez("crystal_geode")
    if global.getLevelZoneThing("crystal_geode"):
      var newText = "*mewmew*\n(...you've already purified the\n[color=#0798bf]Crystal[/color] in this zone!)"
      if global.memory["demo_mode"] >= 2:
        pass
      else:
        newText += "\nthere are only " + str(NUM_CRYSTAL_GEODES_TO_BOSS - allCrystalGeodes) + " left"
      
      textBox.text_final = newText
      textBox.textNode.bbcode_text = newText
    else:
      var newText = "*meow*\n•(for some weird reason,\nyou can hear me?)\n•(i smell an unpurified\n[color=red]Crystal[/color] in this zone)"
      if global.memory["demo_mode"] >= 2:
        pass
      else:
        newText += "\n      " + str(NUM_CRYSTAL_GEODES_TO_BOSS - allCrystalGeodes) + " total left!"
      textBox.text_final = newText
      textBox.textNode.bbcode_text = newText
  else:
    var levelZoneName = level.getLevelZoneName()
    var has_key = false
    var has_soul = false
    if "ToxicJungle" in levelZoneName:
      has_key = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.CAT))
      has_soul = global.memory["mushroom_soul"] > 0
    elif "FishingVillage" in levelZoneName:
      has_key = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.FISH))
      has_soul = global.memory["zora_flippers"] > 0
    if "ShiftingSandLand" in levelZoneName:
      has_key = (global.memory.has("key_items") and global.memory["key_items"].has(global.KeyItem.PYRAMID))
      has_soul = global.memory["mole_cricket"] > 0

    if has_key and has_soul:
      var newText = "*mew?*\n•(seems like you've found most\nimportant stuff in this zone)"
      textBox.text_final = newText
      textBox.textNode.bbcode_text = newText
    if not has_key or not has_soul:
      var newText = "*meow*, *sniff, sniff*\n•(seems like there's still:\n" + ("a key" if not has_key else "") + ((" and a soul" if not has_key else "a soul") if not has_soul else "") + " in this zone)."
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
