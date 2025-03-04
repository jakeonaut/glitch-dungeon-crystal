extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")
onready var NPC = get_node("../../..")
onready var brothCauldron = get_node("../../../..")

func _ready():
  pass

func activateScript():
  if not brothCauldron.is_active:
    return
  if not textBox.showYesNoOptions or not textBox.selectedYesNoOption:
    return
  
  level.player.glitch_death_timer = 10
  level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
  brothCauldron.warpSound.play()
  global.prepareForTransition(level)
  global.isBrothWarping = true
  transition.granny_teleport_to(brothCauldron.path)

    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
