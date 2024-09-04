extends AudioStreamPlayer

# onready var textBox = get_node("..")
# onready var textBoxContainer = get_node("../..")
# onready var npc = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var fishingRodShortcut = get_tree().get_root().get_node("Game/Viewport/level/FishingRodShortcut")


func _ready():
  set_process(true)
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  if global.getStaticLevelZoneLevelVar(level, fishingRodShortcut):
      doActivateScriptStuff()
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass
    
func activateScript():
  if global.getStaticLevelZoneLevelVar(level, fishingRodShortcut):
    return
  doActivateScriptStuff()
  global.setStaticLevelZoneLevelVar(level, fishingRodShortcut, true)

func doActivateScriptStuff():
  fishingRodShortcut.depth = 19
  fishingRodShortcut.is_reeled_in = true
        
func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
