extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var FrogCroneNPC = get_node("../../..")
onready var FrogCroneNPC2 = level.get_node("FrogCroneNPC2")

func _ready():
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif memory:
      FrogCroneNPC.queue_free()
      FrogCroneNPC2.visible = true
        

func activateScript():
  level.summonSmokeClouds(FrogCroneNPC.global_transform.origin, 3, true, true)
  global.activeInteractor = null
  FrogCroneNPC.queue_free()
  global.setStaticLevelZoneLevelVar(level, self.name, true)
  yield(get_tree().create_timer(0.5), "timeout")
  level.summonSmokeClouds(FrogCroneNPC2.global_transform.origin, 3, true, true)
  FrogCroneNPC2.visible = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
