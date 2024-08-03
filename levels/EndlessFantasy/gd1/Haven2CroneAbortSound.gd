extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var textBox = get_node("..")

func _ready():
  pass

func activateScript():
  if global.memory["crone"] == 0:
    global.memory["crone"] = 1
    yield(get_tree().create_timer(1.0), "timeout")
    level.summonSmokeClouds(level.door5.global_transform.origin, 3, true, true)
    level.door5.visible = true
    yield(get_tree().create_timer(1.0), "timeout")
    level.summonSmokeClouds(level.door4.global_transform.origin, 3, true, true)
    level.door4.visible = true
    yield(get_tree().create_timer(1.0), "timeout")
    level.summonSmokeClouds(level.door3.global_transform.origin, 3, true, true)
    level.door3.visible = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  # OVERRIDE ME
  pass

func cutOffEarlyActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
  pass

func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
