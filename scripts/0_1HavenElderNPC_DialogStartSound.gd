extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var elderTadpoleNPC = get_node("../../..")

func _ready():
  pass


func activateScript():
  var how_many_more = global.MAX_CRYSTALS_FOR_TOWER - global.memory["clean_crystals"]
  var text = "just " + str(how_many_more) + " more Crystals to awaken!\nour prayers are stronger together."
  if how_many_more <= 0:
    text = "thank you young one! we will meet\nat the holy site at top of tower.\nmake haste!"
  
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