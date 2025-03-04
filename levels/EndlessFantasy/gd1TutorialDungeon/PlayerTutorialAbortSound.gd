extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func preActivateScript():
  global.pauseMoveInput = false

func activateScript():
  if not global.okay_really_really_started_game or not global.another_start_game_variable:
    level.showInstructions = true
    global.okay_really_really_started_game = true
    global.another_start_game_variable = true
    musicPlayer.conductFromScenePath(level.getLevelName())
