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
  var text = ""
  match levelZoneName:
    "gd1TutorialDungeon":
      var how_many_more = global.MAX_CRYSTALS_FOR_TOWER - global.memory["clean_crystals"]
      if not global.getStaticLevelZoneLevelVar(level, elderTadpoleNPC):
        if how_many_more > 0:
          text = tr("NPC.Elder.3")
        elif how_many_more <= 0:
          text = tr("NPC.Elder.3_2")
      elif how_many_more <= 0:
        text = tr("NPC.Elder.6")
      elif global.getStaticLevelZoneLevelVar(level, elderTadpoleNPC):
        text = tr("NPC.Elder.5") % "3"
    "gd1FishingVillage":
      text = tr("NPC.Elder.4")
    "gd1ToxicJungle":
      text = tr("NPC.Elder.4")
    "gd1ShiftingSandLand":
      text = tr("NPC.Elder.4")
  
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
