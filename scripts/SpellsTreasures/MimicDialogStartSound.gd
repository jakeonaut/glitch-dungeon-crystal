extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")
onready var mimic = get_node("../../../..")
onready var mimicNPC = get_node("../../../../MimicNPC")
onready var treasureSpellCollectable = get_node("../../../../TreasureSpellCollectable")

func _ready():
  set_process(true)
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  var initial_text = ""
  if treasureSpellCollectable.okay_im_done:
    initial_text = "•sorry old-timer,\ni got nothin else."
    textBox.showYesNoOptions = false
  else:
    initial_text = "•pssst, i'll trade you\n" + mimic.trade_item + ", for " + str(mimic.num_gems_needed) + " shards.\nwhaddyasay..?"
    textBox.showYesNoOptions = true

  var finalText = initial_text
      
  # if treasureSpellCollectable.okay_im_done:
  #   var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  #   if num_gems > mimic.num_gems_needed:
  #     finalText += "\n•youve got the goods.. fair trade!"

  textBox.text_final = finalText
  textBox.textNode.bbcode_text = finalText
        
func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
