extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  pass

func activateScript():
  pass
  # if level.player.transformation != level.player.TransformationState.CHICKEN:
  #   var text = tr("NPC.ChickenSecret.2")
  #   textBox.text_final = text
  #   textBox.textNode.bbcode_text = text
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
