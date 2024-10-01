extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func activateScript():
  level.showInstructions = true
  global.okay_really_really_started_game = true
  musicPlayer.conductFromScenePath(level.getLevelName())
