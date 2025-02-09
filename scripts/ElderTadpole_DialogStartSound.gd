extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var elderTadpoleNPC = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  pass


func activateScript():
  if elderTadpoleNPC.am_i_sleepy:
    return

  var levelZoneName = global.currLevelZone
  if levelZoneName == "gd1GrandmaVillage" or levelZoneName == "gd1PrimordialOoze":
    return
  var text = "•ok I'm up.!"
  match levelZoneName:
    "gd1TutorialDungeon":
      var how_many_more = global.MAX_CRYSTALS_FOR_TOWER - global.memory["clean_crystals"]
      if not global.getStaticLevelZoneLevelVar(level, elderTadpoleNPC):
        if how_many_more > 0:
          text = "•ok I'm up.! [wave]*cough*[/wave] \nwhere am i? i still feel weak.\noh, you're trying to tidy up?\nwell, awaken my 3 other sisters\nwe can pray to Goddess\nand clean up this world"
        elif how_many_more <= 0:
          text = "•ok I'm up.! [wave]*cough*[/wave] \nwhere am i? i still feel weak.\noh, you already woke up my sisters?\nwell, we will meet\nat the holy site at top of tower.\nmake haste!"
      elif how_many_more <= 0:
        text = "thank you young one! we will meet\nat the holy site at top of tower.\nmake haste!"
      elif global.getStaticLevelZoneLevelVar(level, elderTadpoleNPC):
        text = "•awaken my 3 other sisters\nwe can pray to Goddess\nand clean up this world"
    "gd1FishingVillage":
      text = "hi! thanks *bloop*\ni'll go meet my other sisters.\nbye bye"
    "gd1ToxicJungle":
      text = "hey! thanks *kiki*\ni'll go meet my other sisters.\nbye bye"
    "gd1ShiftingSandLand":
      text = "hello! thanks *squirm*\ni'll go meet my other sisters.\nbye bye"
  
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
