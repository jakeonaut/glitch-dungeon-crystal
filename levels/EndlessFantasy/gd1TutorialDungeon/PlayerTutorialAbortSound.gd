extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func activateScript():
  level.showInstructions = true
  musicPlayer.conductFromScenePath(level.getLevelName())
