extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  # OVERRIDE ME
  # textBox.text_final = "hi"
  # textBox.textNode.bbcode_text = "hi"
  level.player.stopTalking()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  level.player.sayThis("harumph!", 10.0)

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
