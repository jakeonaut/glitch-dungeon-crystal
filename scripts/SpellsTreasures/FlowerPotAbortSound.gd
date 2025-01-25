extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var treasureChest = get_node("../../..")

func _ready():
  pass

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
  level.player.pauseInput = false
  
  if not global.memory.has("flowerPot") or not global.memory["flowerPot"]:
    global.memory["flowerPot"] = true
      
  level.saveTheGame()

func isActive(_debug=false):
  return true
