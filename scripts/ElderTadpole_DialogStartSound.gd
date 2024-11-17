extends AudioStreamPlayer

func _ready():
  pass


func activateScript():
  var levelZoneName = global.currLevelZone
  if levelZoneName == "gd1GrandmaVillage" or levelZoneName == "gd1PrimordialOoze":
    return
  var text = "•ok I'm up."
  match levelZoneName:
    "gd1TutorialDungeon":
        text = "[wave]*cough*[/wave]where am i?"
    "gd1FishingVillage":
        text = "[wave]*cough*[/wave]where am i?"
    "gd1ToxicJungle":
        text = "[wave]*cough*[/wave]where am i?"
    "gd1ShiftingSandLand":
        text = "[wave]*cough*[/wave]where am i?"
  
  var textBox = get_node("..")
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