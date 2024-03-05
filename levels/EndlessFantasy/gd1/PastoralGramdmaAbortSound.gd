extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
  if has_done_my_magick:
    return

  if "sweep" in textBox.text_final:
    global.activeInteractor = null
    level.player.force_a_sweep = true
  has_done_my_magick = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
