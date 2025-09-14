extends AudioStreamPlayer

onready var treasureChest = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var petToUnlock = global.PetFollower.CHICKEN

func _ready():
  if petToUnlock in global.memory["allMyPets"]:
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

  level.player.changePet(petToUnlock)
  level.saveTheGame()

func preActivateScript():
  if not petToUnlock in global.memory["allMyPets"]:
    global.memory["allMyPets"].push_back(petToUnlock)
