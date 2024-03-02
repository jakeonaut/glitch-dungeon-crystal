extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var levelDoor = get_tree().get_root().get_node("Game/Viewport/level/LevelDoor")
onready var levelDoor2 = get_tree().get_root().get_node("Game/Viewport/level/LevelDoor2")
onready var levelDoor3 = get_tree().get_root().get_node("Game/Viewport/level/LevelDoor3")
onready var levelDoor4 = get_tree().get_root().get_node("Game/Viewport/level/LevelDoor4")
onready var levelDoor5 = get_tree().get_root().get_node("Game/Viewport/level/LevelDoor5")

func _ready():
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif memory:
      levelDoor.visible = true
      levelDoor2.visible = true
      levelDoor3.visible = true
      levelDoor4.visible = true
      levelDoor5.visible = true
        

func activateScript():
  global.setStaticLevelZoneLevelVar(level, self.name, true)

  level.summonSmokeClouds(levelDoor.global_transform.origin, 3, true, true)
  levelDoor.visible = true
  yield(get_tree().create_timer(1.0), "timeout")
  level.summonSmokeClouds(levelDoor2.global_transform.origin, 3, true, true)
  levelDoor2.visible = true
  yield(get_tree().create_timer(0.5), "timeout")
  level.summonSmokeClouds(levelDoor3.global_transform.origin, 3, true, true)
  levelDoor3.visible = true
  yield(get_tree().create_timer(0.1), "timeout")
  level.summonSmokeClouds(levelDoor4.global_transform.origin, 3, true, true)
  levelDoor4.visible = true
  yield(get_tree().create_timer(0.1), "timeout")
  level.summonSmokeClouds(levelDoor5.global_transform.origin, 3, true, true)
  levelDoor5.visible = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true