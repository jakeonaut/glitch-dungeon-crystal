extends AudioStreamPlayer

onready var treasureChest = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  if global.GrandmaOutfit.WITCH_HAT in global.memory["allMyOutfits"]:
    treasureChest.youAlreadyGotMe()

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

  level.player.changeOutfit(global.GrandmaOutfit.WITCH_HAT)
  level.saveTheGame()

func preActivateScript():
  if not global.GrandmaOutfit.WITCH_HAT in global.memory["allMyOutfits"]:
    global.memory["allMyOutfits"].push_back(global.GrandmaOutfit.WITCH_HAT)
