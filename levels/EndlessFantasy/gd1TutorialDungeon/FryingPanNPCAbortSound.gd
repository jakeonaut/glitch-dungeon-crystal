extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  global.memory["has_eggs_marked"] = true
  var numAngelEggs = global.getThingFromAllLevelZonez("angelEgg")
  if numAngelEggs >= global.MAX_ANGEL_EGGS and global.userSettings["allMyBrooms"].find(global.GrandmaBroom.FRYING_PAN) < 0:
    global.memory["currBroom"] = global.GrandmaBroom.FRYING_PAN
    global.userSettings["allMyBrooms"].push_back(global.GrandmaBroom.FRYING_PAN)
    global.saveUserSettings()
    level.player.playChangeOutfitSound()
    musicPlayer.playTreasureJingle(-20)
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
