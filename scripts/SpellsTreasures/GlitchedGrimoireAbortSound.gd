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
  level.player.pauseInput = false

  # IFNDEF SpellbookIntroLevelScript.gd
  # if level.has_node("NPC5"):
  #   level.get_node("NPC5").textBox.text_final = "•use [C] to switch between\nyour last two colors!"
  #   level.get_node("NPC5").textBox.has_been_shown = false
  #   level.get_node("NPC5").textBox.tinify()
  
  #if level.has_node("NPC"):
  #    level.get_node("NPC").textBox.text_final = "•wow you got it......i bet all\nkinds of new paths will open up\nfor you now in swamp home......\n•i could never cast spells\nlike you can... i'm just\na lowly frog wizard."
  level.saveTheGame()

func preActivateScript():
  global.memory["forget_me_not"] = true
  global.memory["glitch_world"] = 1
  transition.tryUpdateMapManagerToGlitchedMap()
  if not global.memory["glitched_grimoire"]:
    global.memory["glitched_grimoire"] = true
    global.memory["glitched_grimoire2"] = true
    if not global.memory.has("spellbookPage"):
      if level.player.glitch_form != global.GlitchForm.NORMAL:
        global.memory["spellbookPage"] = [level.player.glitch_form]
      else:
        global.memory["spellbookPage"] = []
    if level.has_node("LadderSpell") and level.has_node("InvisibleSpell") and level.has_node("SavePoint"):
      yield(get_tree().create_timer(0.5), "timeout")
      var ladderSpell = level.ladderSpell
      level.summonSmokeClouds(ladderSpell.global_transform.origin, 3, true, true)
      ladderSpell.visible = true
      yield(get_tree().create_timer(0.5), "timeout")
      var invisibleSpell = level.invisibleSpell
      level.summonSmokeClouds(invisibleSpell.global_transform.origin, 3, true, true)
      invisibleSpell.visible = true
      yield(get_tree().create_timer(0.5), "timeout")
      var savePoint = level.savePoint
      level.summonSmokeClouds(savePoint.global_transform.origin, 2, true, true)
      savePoint.visible = true
