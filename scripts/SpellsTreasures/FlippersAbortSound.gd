extends AudioStreamPlayer

onready var slippers = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var has_activated = false

func activateScript():
  slippers.mySprite.visible = false
  slippers.okay_im_done = true
  
  global.pauseGame = false
  global.pauseMoveInput = false
  level.player.vv = 0
  level.player.linear_velocity.y = 0
  level.player.lv.y = 0
  level.player.aniPlayer = level.player.get_node("AnimationPlayer")
  level.player.aniPlayer.clear_queue()
  level.player.aniPlayer.queue("walkStop")
  level.player.aniPlayer.queue("stand")
  level.player.glitchTickle()

  level.saveTheGame()

func preActivateScript():
  if not has_activated:
    global.memory["zora_flippers"] = 1
    has_activated = true
