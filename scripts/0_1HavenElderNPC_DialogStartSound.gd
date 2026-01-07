extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var elderTadpoleNPC = get_node("../../..")

func _ready():
  pass


func activateScript():
  var text = ""
  if global.memory["mushroom_soul"] <= 0 or global.memory["zora_flippers"] <= 0 or global.memory["mole_cricket"] <= 0:
    text = tr("NPC.Tutorial.SOUL_HINT") 
  else: 
    var how_many_more = global.MAX_CRYSTALS_FOR_TOWER - global.memory["clean_crystals"]
    text = tr("NPC.Elder.5") % str(how_many_more)
    if how_many_more <= 0:
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