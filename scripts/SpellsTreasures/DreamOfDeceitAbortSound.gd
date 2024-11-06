extends AudioStreamPlayer

onready var treasureChest = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func activateScript():
  treasureChest.mySprite.visible = false
  treasureChest.okay_im_done = true
  
  global.pauseGame = false
  global.pauseMoveInput = false
  level.player.vv = 0
  level.player.linear_velocity.y = 0
  level.player.lv.y = 0
  level.player.aniPlayer = level.player.get_node("AnimationPlayer")
  level.player.aniPlayer.clear_queue()
  level.player.aniPlayer.queue("walkStop")
  level.player.aniPlayer.queue("stand")
  if level.player.glitch_form != global.GlitchForm.NORMAL:
    level.player.applyObeliskGlitch(level.player.glitch_form)
  level.saveTheGame()

func preActivateScript():
  if global.memory["angler_seaman_boss"] != 3:
    global.memory["angler_seaman_boss"] = 3
