extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")
onready var mimicNPC = get_node("../../../../MimicNPC")
onready var treasureSpellCollectable = get_node("../../../../TreasureSpellCollectable")

var initial_text = ""
func _ready():
  set_process(true)
  initial_text = "•pssst, i'll trade you SLIPPERS\nfor " + str(mimicNPC.num_gems_needed) + " gems.\nwhaddyasay..?"
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  var finalText = initial_text
      
  var num_gems = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
  if num_gems > mimicNPC.num_gems_needed:
    finalText += "\n•youve got the goods.. fair trade!"

  textBox.text_final = finalText
  textBox.textNode.bbcode_text = finalText
        
func isActive():
  # OVERRIDE ME... if you dare
  return true
