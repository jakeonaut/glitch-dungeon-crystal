extends AudioStreamPlayer

onready var treasureChest = get_node("../../..")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  if global.memory["has_map_item"] and global.memory["angel_flute"]:
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

  # IFNDEF SpellbookIntroLevelScript.gd
  # if level.has_node("NPC5"):
  #   level.get_node("NPC5").textBox.text_final = "•use [C] to switch between\nyour last two colors!"
  #   level.get_node("NPC5").textBox.has_been_shown = false
  #   level.get_node("NPC5").textBox.tinify()
  
  #if level.has_node("NPC"):
  #    level.get_node("NPC").textBox.text_final = "•wow you got it......i bet all\nkinds of new paths will open up\nfor you now in swamp home......\n•i could never cast spells\nlike you can... i'm just\na lowly frog wizard."
  level.saveTheGame()

func preActivateScript():
  global.memory["has_map_item"] = true
  global.memory["angel_flute"] = true
