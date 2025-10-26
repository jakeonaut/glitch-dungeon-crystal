extends CanvasLayer

onready var heartsRect = get_node("HeartsRect")
var heart_recovery_timer = 0
var heart_recovery_time_limit = 5

onready var powerupRect = get_node("PowerupRect")
onready var powerupSprite = get_node("PowerupRect/ColorRect/ColorRect/PowerupSprite")
onready var powerupRectTextLabel = get_node("PowerupRect/ColorRect/ColorRect/RichTextLabel")

onready var miniCrystalCubeRect = get_node("MiniCrystalCubeRect")
onready var miniCrystalCubeTextLabel = get_node("MiniCrystalCubeRect/ColorRect/ColorRect/RichTextLabel")

onready var glitchStatusRect = get_node("GlitchStatusRect")
onready var miniCrystalTextureRect = get_node("GlitchStatusRect/TextureRect") if has_node("GlitchStatusRect/TextureRect") else null
onready var miniCrystalViewport = get_node("GlitchStatusRect/Viewport") if has_node("GlitchStatusRect/Viewport") else null
onready var savingTextureRect = get_node("SavingTextLabel/TextureRect") if has_node("SavingTextLabel/TextureRect") else null
onready var savingViewport = get_node("SavingTextLabel/Viewport") if has_node("SavingTextLabel/Viewport") else null
onready var savingSprite3D = get_node("SavingTextLabel/Viewport/SavingSprite3D") if has_node("SavingTextLabel/Viewport/SavingSprite3D") else null

var display_title = "???"
onready var levelTitleRect = get_node("LevelTitle")
var title_display_timer = 10
var title_display_time_limit = 30
# LIKE AN ENUM-LESS fsm
var title_display_state = 0

onready var statsTitleRect = get_node("StatsTitle")

onready var savingTextLabel = get_node("SavingTextLabel")
var should_display_saving_text = false
var saving_text_timer = 0
var saving_text_time_limit = 60

onready var spellMessageTextLabel = get_node("SpellMessageTextLabel")
var should_display_spell_message_text = false
var spell_message_text_timer = 0
var spell_message_text_time_limit = 60

onready var messageTextLabel = get_node("MessageTextLabel")
var should_display_message_text = false
var message_text_timer = 0
var message_text_time_limit = 60

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var gameCamera = null
func getGameCamera():
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

func _ready():
  levelTitleRect.rect_pivot_offset = levelTitleRect.rect_size / 2
  levelTitleRect.rect_scale = Vector2(0, 1)
  set_process(true)
  # recreateHeartSprites()
  hiscoreRect.visible = false
  congratsHiscoreLabel.visible = false
  crystalCubeHiscoreLabel.visible = false
  glitchTilesHiscoreLabel.visible = false
  angelHiscoreLabel.visible = false
  deathsHiscoreLabel.visible = false
  jumpsHiscoreLabel.visible = false
  pressEnterLabel.visible = false

# func recreateHeartSprites():
#   var heartSprite = heartsRect.get_node("ColorRect/ColorRect/HeartSprite")
#   heartSprite.visible = false
#   var heartSpritesArray = heartsRect.get_node("ColorRect/ColorRect").get_children()
#   for i in range(heartSpritesArray.size() - 1):
#     heartSpritesArray[heartSpritesArray.size() - i - 1].queue_free()
#   for i in range(global.memory["max_hp"] - 1):
#     heartSprite.visible = true
#     var newHeartSprite = heartSprite.duplicate()
#     newHeartSprite.visible = true
#     newHeartSprite.global_position.x = 72 + i * 48
#     heartsRect.get_node("ColorRect/ColorRect").add_child(newHeartSprite)

onready var glitchStatusText1 = get_node("GlitchStatusRect/RichTextLabel")
onready var keyStatusRect = get_node("KeyStatusRect")
onready var keyStatusText1 = get_node("KeyStatusRect/RichTextLabel")
onready var keyStatusText2 = get_node("KeyStatusRect/RichTextLabel2")
onready var pauseMenu = get_node("PauseMenu")
onready var betaBuildLabel = get_node("BetaBuildLabel")
onready var textBoxes = get_node("TextBoxes")
onready var edgeDistortion = get_node("EdgeDistortion")
onready var edgeDistortionLeft = get_node("EdgeDistortion/LeftDistortion")
onready var edgeDistortionRight = get_node("EdgeDistortion/RightDistortion")
onready var edgeDistortionTop = get_node("EdgeDistortion/TopDistortion")
onready var edgeDistortionBottom = get_node("EdgeDistortion/BottomDistortion")
onready var equipmentRect = get_node("EquipmentRect")
onready var glitchSpellSprite1 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect1/ColorRect/EquipmentSlotSprite")
onready var glitchSpellSprite2 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect2/ColorRect/EquipmentSlotSprite")
onready var glitchSpellSprite3 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect3/ColorRect/EquipmentSlotSprite")
onready var glitchSpellSprite4 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect4/ColorRect/EquipmentSlotSprite")
onready var glitchSpellRect1 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect1")
onready var glitchSpellRect2 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect2")
onready var glitchSpellRect3 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect3")
onready var glitchSpellRect4 = get_node("EquipmentRect/ColorRect/ColorRect/GlitchRect4")
onready var extension = get_node("EquipmentRect/ColorRect/ColorRect/Extension")
onready var livesRect = get_node("LivesRect")
onready var grannyLifeSprite1 = get_node("LivesRect/LifeSprite")
onready var grannyLifeSprite2 = get_node("LivesRect/LifeSprite2")
onready var grannyLifeSprite3 = get_node("LivesRect/LifeSprite3")
onready var grannyLifeSprite4 = get_node("LivesRect/LifeSprite4")
onready var grannyLifeSprite5 = get_node("LivesRect/LifeSprite5")
onready var grannyLifeSprite6 = get_node("LivesRect/LifeSprite6")
onready var grannyLifeSprite7 = get_node("LivesRect/LifeSprite7")
onready var grannyLifeSprite8 = get_node("LivesRect/LifeSprite8")
onready var grannyLifeSprite9 = get_node("LivesRect/LifeSprite9")
onready var deadTextLabel = get_node("LivesRect/DeadTextLabel")
onready var bossLifeSprite1 = get_node("LivesRect/BossLifeSprite")
onready var bossLifeSprite2 = get_node("LivesRect/BossLifeSprite2")
onready var bossLifeSprite3 = get_node("LivesRect/BossLifeSprite3")
onready var bossLifeSprite4 = get_node("LivesRect/BossLifeSprite4")
onready var bossLifeSprite5 = get_node("LivesRect/BossLifeSprite5")
onready var bossLifeSprite6 = get_node("LivesRect/BossLifeSprite6")
onready var bossTextLabel = get_node("LivesRect/BossTextLabel")

var UI_DIFF = 6.0
func _process(delta):
  if not level or not level.hasGameFrameBackground:
    return

  textBoxes.visible = not global.isPauseMenuOpen
  pauseMenu.visible = global.isPauseMenuOpen
  betaBuildLabel.visible = pauseMenu.visible or global.isOnMainMenu
  processCutsceneRenderLogic(delta)
  processHiscoreRenderLogic(delta)
  # TODO(jaketrower):
  if global.memory.has("key"):
    keyStatusRect.visible = not global.isPauseMenuOpen
    keyStatusText1.text = str(global.memory["key"])
    keyStatusText2.text = str(global.memory["key"])
  else:
    keyStatusRect.visible = false
    
  # if global.memory["max_mp"] <= 0:
  #  glitchStatusRect.visible = false
  # statsTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = "MAGICK: "+ str(global.memory["mp"]) + " / " + str(global.memory["max_mp"]) + " CRYSTALS"
  var glitchStatusText = str(global.getThingFromAllLevelZonez("num_mini_crystal_cubes")) # str(global.memory["mp"]) + " /\n" + str(global.memory["max_mp"])
  glitchStatusText1.text = glitchStatusText 
  #it's okay to let the UI go fast, even if it's hearts # delta = delta * global.time_dilation_multiplier

  # if not global.memory.has("max_hp") or global.memory["max_hp"] <= 1:
  #   heartsRect.visible = false
  # else:
  #   heartsRect.visible = true

  #   if global.memory["hearts_recovering"]:
  #     heart_recovery_timer += (delta*22)
  #     if heart_recovery_timer >= heart_recovery_time_limit:
  #       heart_recovery_timer = 0
  #       global.memory["hp"] += 1
  #     if global.memory["hp"] == global.memory["max_hp"]:
  #       global.memory["hearts_recovering"] = false
  #       heart_recovery_timer = 0

  #   for i in range(global.memory["max_hp"]):
  #     var heartSprite = heartsRect.get_node("ColorRect/ColorRect").get_child(i)
  #     if (i+1) <= global.memory["hp"]:
  #       heartSprite.updateBaseFrame(2, 0)
  #       heartSprite.max_frames = 1
  #     else:
  #       if getPlayer().glitch_death_timer != 0:
  #         heartSprite.updateBaseFrame(0, 1)
  #         heartSprite.max_frames = 3
  #       else:
  #         heartSprite.updateBaseFrame(0, 0)
  #         heartSprite.max_frames = 1
    

  if global.isPauseMenuOpen:
    levelTitleRect.visible = false
  elif title_display_state < 3 and display_title != "???":
    levelTitleRect.visible = true
    title_display_timer += (delta*22)
    if title_display_timer >= title_display_time_limit:
      if title_display_state == 0:
        levelTitleRect.rect_scale.x = levelTitleRect.rect_scale.x + (1 - levelTitleRect.rect_scale.x) * (delta*5)
        if stepify(levelTitleRect.rect_scale.x, 0.1) == 1:
          levelTitleRect.rect_scale.x = 1
          title_display_timer = 0
          title_display_state = 1
      elif title_display_state == 1:
        title_display_timer = 0
        title_display_state = 2
      elif title_display_state == 2:
        levelTitleRect.rect_scale.x = levelTitleRect.rect_scale.x + (0 - levelTitleRect.rect_scale.x) * (delta*5)
        if stepify(levelTitleRect.rect_scale.x, 0.1) == 0:
          levelTitleRect.rect_scale.x = 0
          title_display_timer = 0
          title_display_state = 3
  # if global.activeInteractor:
  #   levelTitleRect.rect_scale.x = 0
  #   title_display_timer = 0
  #   title_display_state = 3

  if should_display_saving_text:
    saving_text_timer += (delta*22)
    savingSprite3D.rotation_degrees.y -= delta*22*5
    if saving_text_timer >= saving_text_time_limit:
      should_display_saving_text = false
      savingTextLabel.visible = false
      savingSprite3D.rotation_degrees.y = 0

  if global.isPauseMenuOpen: spellMessageTextLabel.visible = false
  elif should_display_spell_message_text:
    spell_message_text_timer += (delta*22)
    if spell_message_text_timer >= spell_message_text_time_limit:
      should_display_spell_message_text = false
      spellMessageTextLabel.visible = false

  if global.isPauseMenuOpen: messageTextLabel.visible = false
  elif should_display_message_text:
    message_text_timer += (delta*22)
    if message_text_timer >= message_text_time_limit:
      should_display_message_text = false
      messageTextLabel.visible = false

  if global.collectable_key_recently_got != null:
    powerupRect.visible = true
    powerupRect.rect_scale.x = 1.0
    if global.collectable_key_recently_got == "dragonflies":
      powerupSprite.updateBaseFrame(0, 1)
    if global.collectable_key_recently_got == "snails":
      powerupSprite.updateBaseFrame(4, 3)
    if global.collectable_key_recently_got == "cicadas":
      powerupSprite.updateBaseFrame(0, 4)
    powerupRectTextLabel.text = str(global.memory[global.collectable_key_recently_got]) 
    
    global.collectable_key_recently_got_timer += (delta*22)
    powerupRect.rect_scale.x = min(1.0, 1 - pow(global.collectable_key_recently_got_timer / global.collectable_key_recently_got_time_limit - 0.3, 2.0))
    if stepify(global.collectable_key_recently_got_timer, 0.1) >= global.collectable_key_recently_got_time_limit:
      global.collectable_key_recently_got = null
  elif global.num_cherries_eaten > 0:
    powerupRect.visible = true
    powerupRect.rect_scale.x = 1
    powerupSprite.updateBaseFrame(4, 2)
    powerupRectTextLabel.text = str(global.num_cherries_eaten)
  else:
    powerupRect.visible = false

  # if global.num_mini_crystal_cubes > 0 and global.activeInteractor == null:
  #   miniCrystalCubeRect.visible = true
  #   miniCrystalCubeTextLabel.text = str(global.num_mini_crystal_cubes)
  # else:
  miniCrystalCubeRect.visible = false

  var pLeft = level.player.getDistToLeftEdge()
  var pTop = level.player.getDistToTopEdge()
  var pRight = level.player.getDistToRightEdge()
  equipmentRect.visible = global.memory.has("spellbookPage") and not global.isPauseMenuOpen
  glitchSpriteContainer.visible = (global.memory["hasEverTouchedObelisk"] or level.player.glitch_form != global.GlitchForm.NORMAL) and not global.memory.has("spellbookPage") and not global.isPauseMenuOpen and not global.isOnMainMenu
  var pTopLeft = Vector2(pLeft, pTop)
  var pTopRight = Vector2(pRight, pTop)
  var vec0 = Vector2(0.0, 0.0)
  if pTopLeft.distance_to(vec0) <= UI_DIFF and not global.isPauseMenuOpen:
    var modVal = min(max(sqrt(pTopLeft.distance_to(vec0)) / UI_DIFF, 0.0), 1.0)
    equipmentRect.modulate.a = modVal
    glitchSpriteContainer.modulate.a = modVal
  else:
    equipmentRect.modulate.a = 1.0
    glitchSpriteContainer.modulate.a = 1.0

  if pTop <= UI_DIFF and not global.isPauseMenuOpen:
    var modVal = min(max(1 - ((UI_DIFF - pTop) / UI_DIFF), 0.0), 1.0)
    livesRect.modulate.a = modVal
  else:
    livesRect.modulate.a = 1.0

  if pTopRight.distance_to(vec0) <= UI_DIFF and not global.isPauseMenuOpen:
    var modVal = min(max(sqrt(pTopRight.distance_to(vec0)) / UI_DIFF, 0.0), 1.0)
    keyStatusRect.modulate.a = modVal
    glitchStatusRect.modulate.a = modVal
  else:
    keyStatusRect.modulate.a = 1.0
    glitchStatusRect.modulate.a = 1.0



  # tryLerpSpriteFromCenter(get_node("GlitchSprite"), delta, Vector2(0, 1))
  if savingTextureRect != null and savingTextureRect.texture == null and savingViewport != null:
    savingTextureRect.texture = savingViewport.get_texture()
  if global.memory["tutorial_gem"] == 1:
    if miniCrystalTextureRect != null and miniCrystalTextureRect.texture == null and miniCrystalViewport != null:
      miniCrystalTextureRect.texture = miniCrystalViewport.get_texture()
    glitchStatusRect.visible = true
    tryLerpFromCenter(glitchStatusRect, delta, Vector2(530, 8))
  var num_keys = global.memory["key"] if global.memory.has("key") else null
  if num_keys != null and num_keys > 0:
    keyStatusRect.visible = true
    tryLerpFromCenter(keyStatusRect, delta, Vector2(462, 8))
  # tryLerpFromCenter(get_node("EquipmentStatusRect"), delta, Vector2(68, 79))
  if not global.memory.has("spellbookPage"):
    tryLerpFromCenter(glitchSpriteContainer, delta, Vector2(7.5, 7))
  else:
    tryLerpFromCenter(get_node("EquipmentRect"), delta, Vector2(7, 4))
  tryLerpFromCenter(spellMessageTextLabel, delta, Vector2(9.5, 73.5))

  if global.memory.has("spellbookPage"):
    var spellbookSprite = get_node("EquipmentRect/ColorRect/ColorRect/EquipmentSprite")
    if global.memory["glitched_grimoire"]:
      spellbookSprite.frame = 3
    else:
      spellbookSprite.frame = 0
      
    var spellbook = global.memory["spellbookPage"]
    var spellbookSize = spellbook.size()
    var activeColor = Color("#dcdcdc")
    var inactiveColor = Color("#006400")
    var index = level.player.spellCastPauseIndex
    if global.memory["glitched_grimoire"]:
      glitchSpellRect1.color = activeColor if index == 0 else inactiveColor
      glitchSpellRect2.color = activeColor if index == 1 else inactiveColor
      glitchSpellRect3.color = activeColor if index == 2 else inactiveColor
      glitchSpellRect4.color = activeColor if index == 3 else inactiveColor
      glitchSpellRect3.visible = true
      glitchSpellRect4.visible = true
      extension.visible = true
      setGlitchSprite(glitchSpellSprite1, spellbook[0] if spellbookSize >= 1 else level.player.glitch_form)
      if spellbookSize >= 2:
        setGlitchSprite(glitchSpellSprite2, spellbook[1])
      else:
        setGlitchSprite(glitchSpellSprite2, global.GlitchForm.NORMAL)
      if spellbookSize >= 3:
        setGlitchSprite(glitchSpellSprite3, spellbook[2])
      else:
        setGlitchSprite(glitchSpellSprite3, global.GlitchForm.NORMAL)
      if spellbookSize >= 4:
        setGlitchSprite(glitchSpellSprite4, spellbook[3])
      else:
        setGlitchSprite(glitchSpellSprite4, global.GlitchForm.NORMAL)
    else:
      glitchSpellRect1.color = activeColor
      glitchSpellRect2.color = inactiveColor
      glitchSpellRect3.visible = false
      glitchSpellRect4.visible = false
      extension.visible = false
      setGlitchSprite(glitchSpellSprite1, spellbook[level.player.spellCastPauseIndex] if spellbookSize >= 2 else level.player.glitch_form)
      if spellbookSize == 1 and level.player.glitch_form == global.GlitchForm.NORMAL:
        setGlitchSprite(glitchSpellSprite2, spellbook[0])
      elif spellbookSize >= 2:
        index = (index + 1) % spellbookSize
        setGlitchSprite(glitchSpellSprite2, spellbook[index])
      else:
        setGlitchSprite(glitchSpellSprite2, global.GlitchForm.NORMAL)
  else:
    setGlitchSprite(glitchSpellSprite1, level.player.glitch_form)

  if global.userSettings["canGlitchScreen"] and level.pacman_wrapping and not global.isPauseMenuOpen:
    edgeDistortion.visible = true # a little visually glitchy at times in a way i dont like
    # x_edge/y_edge is finnicky in PoisonShroomCove/LostWoods1
    # edgeDistortionLeft.visible = (level.gameCamera.x_edge == -1 or level.gameCamera.x_edge == 2)
    # edgeDistortionRight.visible = (level.gameCamera.x_edge == 1 or level.gameCamera.x_edge == 2)
    # edgeDistortionBottom.visible = (level.gameCamera.y_edge == -1 or level.gameCamera.y_edge == 2)
    # edgeDistortionTop.visible = (level.gameCamera.y_edge == 1 or level.gameCamera.y_edge == 2)
  elif global.userSettings["canGlitchScreen"] and level.horizontal_pacman_wrapping and not global.isPauseMenuOpen:
    edgeDistortion.visible = true # a little visually glitchy at times in a way i dont like
    edgeDistortionLeft.visible = true #(level.gameCamera.x_edge == -1 or level.gameCamera.x_edge == 2)
    edgeDistortionRight.visible = true # (level.gameCamera.x_edge == 1 or level.gameCamera.x_edge == 2)
    edgeDistortionBottom.visible = false # (level.gameCamera.y_edge == -1 or level.gameCamera.y_edge == 2)
    edgeDistortionTop.visible = false # (level.gameCamera.y_edge == 1 or level.gameCamera.y_edge == 2)
  else:
    edgeDistortion.visible = false


func setGlitchSprite(sprite, glitch):
  # TODO(jaketrower): dedupe (1) with Player.gd
  if glitch == global.GlitchForm.NORMAL: sprite.frame = 9
  elif glitch == global.GlitchForm.FLOOR: sprite.frame = 1
  elif glitch == global.GlitchForm.FEATHER: sprite.frame = 0
  elif glitch == global.GlitchForm.LADDER: sprite.frame = 2
  elif glitch == global.GlitchForm.INVISIBLE: sprite.frame = 3
  elif glitch == global.GlitchForm.WALK_THROUGH_WALLS: sprite.frame = 5
  elif glitch == global.GlitchForm.BUBBLE: sprite.frame = 4

onready var cinematicTopRect = get_node("CinematicTopRect")
onready var cinematicBottomRect = get_node("CinematicBottomRect")
onready var cinematicAniPlayer = get_node("CinematicAnimationPlayer")
func shouldRenderAsCinematic():
  return global.shouldRenderAsCinematic or level.getLevelName().find("000IntroCutscene") > 0

func initiateCutsceneRenderLogic():
  if shouldRenderAsCinematic():
    cinematicAniPlayer.play("startCutsceneImmediate")

func processCutsceneRenderLogic(_delta):
  var aa = cinematicAniPlayer.assigned_animation
  if shouldRenderAsCinematic() and not "startCutscene" in aa and not global.isRespawning:
    cinematicAniPlayer.play("startCutscene")
  elif not shouldRenderAsCinematic() and aa != null and not "endCutscene" in aa and not aa == "":
    cinematicAniPlayer.play("endCutscene")


onready var endOfLevel = get_node("EndOfLevel")
onready var hiscoreRect = get_node("EndOfLevel/HiscoreRect")
onready var congratsHiscoreLabel = get_node("EndOfLevel/CongratsHiscoreLabel")
onready var crystalCubeHiscoreLabel = get_node("EndOfLevel/CrystalCubeHiscoreLabel")
onready var glitchTilesHiscoreLabel = get_node("EndOfLevel/GlitchTilesHiscoreLabel")
onready var deathsHiscoreLabel = get_node("EndOfLevel/DeathsHiscoreLabel")
onready var angelHiscoreLabel = get_node("EndOfLevel/AngelHiscoreLabel")
onready var jumpsHiscoreLabel = get_node("EndOfLevel/JumpsHiscoreLabel")
onready var loveHiscoreLabel = get_node("EndOfLevel/LoveHiscoreLabel")
onready var timeHiscoreLabel = get_node("EndOfLevel/TimeHiscoreLabel")

onready var pressEnterLabel = get_node("EndOfLevel/PressEnterLabel")
var hiscoreDisplayIndex = 0
var hiscoreCounter = 0
# var totalHiscoreCounter = 0
var hiscoreTimer = 0
var hiscoreTimeLimit = 1
var stupidTimeAgedStartTimeTemp = null
func processHiscoreRenderLogic(delta):
  if not global.hasGottenLevelGeode:
    endOfLevel.visible = false
    hiscoreRect.visible = false
    congratsHiscoreLabel.visible = false
    crystalCubeHiscoreLabel.visible = false
    glitchTilesHiscoreLabel.visible = false
    angelHiscoreLabel.visible = false
    deathsHiscoreLabel.visible = false
    jumpsHiscoreLabel.visible = false
    loveHiscoreLabel.visible = false
    timeHiscoreLabel.visible = false
    pressEnterLabel.visible = false

    glitchStatusText1.visible = true
    return
  # global.pauseMoveInput = true
  if stupidTimeAgedStartTimeTemp == null:
    stupidTimeAgedStartTimeTemp = global.getLevelZoneThing("start_time")
    global.updateLevelZoneTime()
    global.setLevelZoneStartTime()
  endOfLevel.visible = true
  hiscoreRect.visible = true
  if not congratsHiscoreLabel.visible:
    congratsHiscoreLabel.visible = true
    congratsHiscoreLabel.bbcode_text = "[center]" + (tr("NPC.Crystal.1") if not global.isEndOfGame else tr("NPC.Crystal.End")) + "[/center]"

  if timeHiscoreLabel.visible and stupidTimeAgedStartTimeTemp != null:
    var total_time = global.getThingFromAllLevelZonez("total_time")
    # print(total_time)
    var time_aged = total_time if total_time != null else tr("NPC.Crystal.NULL")
    if not global.isEndOfGame and total_time != null and stupidTimeAgedStartTimeTemp != null:
      time_aged += (Time.get_unix_time_from_system() - stupidTimeAgedStartTimeTemp)
    # @warning_ignore("integer_division")
    var SECONDS_IN_MINUTE = 60
    var SECONDS_IN_HOUR = SECONDS_IN_MINUTE * SECONDS_IN_MINUTE
    var hours = int(time_aged) / int(SECONDS_IN_HOUR)
    time_aged -= (hours * SECONDS_IN_HOUR)
    var minutes = int(time_aged) / int(SECONDS_IN_MINUTE)
    var optional_minute_zero = "" if minutes >= 10 else "0"
    time_aged -= (minutes * SECONDS_IN_MINUTE)
    var seconds = int(time_aged) / 1
    var optional_second_zero = "" if seconds >= 10 else "0"
    var time_aged_formatted = str(hours) + ":" + optional_minute_zero + str(minutes) + ":" + optional_second_zero + str(seconds)
    timeHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.9") + " " + time_aged_formatted + "[/center]"

  hiscoreTimer += (delta*11)
  if hiscoreTimer >= hiscoreTimeLimit:
    glitchStatusText1.visible = false
    hiscoreTimer = 0
    # TODO(jaketrower): can consolidate this but i'm lazy rn
    if hiscoreDisplayIndex == 0:
      crystalCubeHiscoreLabel.visible = false # true
      crystalCubeHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.7") + str(hiscoreCounter) + "[/center]"
      var hiscoreSource = global.getThingFromAllLevelZonez("num_mini_crystal_cubes")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter = hiscoreSource
        # totalHiscoreCounter += 1
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
    elif hiscoreDisplayIndex == 1:
      deathsHiscoreLabel.visible = true
      deathsHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.2") + str(hiscoreCounter) + "[/center]"
      var hiscoreSource = global.getThingFromAllLevelZonez("num_deaths")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter = hiscoreSource
        # totalHiscoreCounter += 1
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
    elif hiscoreDisplayIndex == 2:
      angelHiscoreLabel.visible = true
      angelHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.3") + str(hiscoreCounter) + "[/center]"
      var hiscoreSource = global.getThingFromAllLevelZonez("angelEgg")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter += 1
        # totalHiscoreCounter += 1
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
        hiscoreTimeLimit = 5
    elif hiscoreDisplayIndex == 3:
      glitchTilesHiscoreLabel.visible = true
      glitchTilesHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.4") + str(global.getThingFromAllLevelZonez("num_broom_sweeps")) + "[/center]"
      hiscoreDisplayIndex += 1
    elif hiscoreDisplayIndex == 4:
      jumpsHiscoreLabel.visible = true
      jumpsHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.5") + str(global.getThingFromAllLevelZonez("num_jumps")) + "[/center]"
      hiscoreDisplayIndex += 1
    elif hiscoreDisplayIndex == 5:
      loveHiscoreLabel.visible = true
      loveHiscoreLabel.bbcode_text = "[center]" + tr("NPC.Crystal.8") + str(global.getThingFromAllLevelZonez("num_glitch_tiles")) + "/" + str(global.getThingFromAllLevelZonez("total_num_glitch_tiles")) + "[/center]"
      hiscoreDisplayIndex += 1
    elif hiscoreDisplayIndex == 6:
      timeHiscoreLabel.visible = true
      timeHiscoreLabel.bbcode_text = ""
      hiscoreDisplayIndex += 1
      hiscoreTimeLimit = 15
    elif hiscoreDisplayIndex == 7:
      pressEnterLabel.visible = not pressEnterLabel.visible
      var sweep_button_text = global.getInputText("talk_button")
      pressEnterLabel.bbcode_text = "[center]" + (tr("NPC.Crystal.Final") % sweep_button_text) + "[/center]"
      hiscoreDisplayIndex += 1
      hiscoreTimeLimit = 5
      if global.isEndOfGame and global.demo_mode <= 0: Steam.set_achievement("GRANDMA_WIN")
  
  if (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("talk_button") or Input.is_action_just_pressed("sub_action_button") or (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))):
    if hiscoreDisplayIndex >= 8:
      # global.isEnteringRoom = true
      global.hasGottenLevelGeode = false
      global.hasLevelGeodeBeenSmacked = false
      if global.isEndOfGame:
        var endOfGameNPC = level.get_node("PrimordialOozeBoss/EndOfGameNPC") if level.has_node("PrimordialOozeBoss/EndOfGameNPC") else null
        if endOfGameNPC: endOfGameNPC.activate(true)
      else:
        global.pauseMoveInput = false
        global.pauseGame = false
        global.isEnteringRoom = false
        level.player.pauseSelf = false
        level.player.physics_state = level.player.PhysicsState.NORMAL
        level.player.pauseInput = false
        level.player.ignorePhysics = false
        global.shouldRenderAsCinematic = false
        global.isPauseMenuOpen = false
    else:
      hiscoreTimer = hiscoreTimeLimit

func tryLerpFromCenter(rect, delta, final_pos):
  if rect.rect_scale.x != 1:
    rect.rect_scale.x = rect.rect_scale.x + (1 - rect.rect_scale.x) * (delta*2)
    rect.rect_scale.y = rect.rect_scale.y + (1 - rect.rect_scale.y) * (delta*2)
    if stepify(rect.rect_scale.x, 0.1) == 1:
      rect.rect_scale = Vector2(1, 1)
  if rect.rect_position.x != final_pos.x:
    rect.rect_position.x = rect.rect_position.x + (final_pos.x - rect.rect_position.x) * (delta*2)
    rect.rect_position.y = rect.rect_position.y + (final_pos.y - rect.rect_position.y) * (delta*2)
    if stepify(rect.rect_position.x, 0.1) == stepify(final_pos.x, 0.1):
      rect.rect_position = final_pos

func tryLerpSpriteFromCenter(sprite, delta, final_pos):
  if sprite.scale.x > 1:
    sprite.scale.x = sprite.scale.x + (1 - sprite.scale.x) * (delta*2)
    sprite.scale.y = sprite.scale.y + (1 - sprite.scale.y) * (delta*2)
    if stepify(sprite.scale.x, 0.1) == 1:
      sprite.scale = Vector2(1, 1)
  if sprite.position.x > final_pos.x:
    sprite.position.x = sprite.position.x + (final_pos.x - sprite.position.x) * (delta*2)
    sprite.position.y = sprite.position.y + (final_pos.y - sprite.position.y) * (delta*2)
    if stepify(sprite.position.x, 0.1) == stepify(final_pos.x, 0.1):
      sprite.position = final_pos

func displaySavingText(_message = "saving (not really)"):
  savingTextLabel.visible = true
  savingTextLabel.bbcode_text = "" # [wave] "+message+"[/wave]"
  should_display_saving_text = true
  saving_text_timer = 0

func displaySpellMessageText(message):
  spellMessageTextLabel.visible = true
  spellMessageTextLabel.bbcode_text = "[wave] "+message+"[/wave]"
  should_display_spell_message_text = true
  spell_message_text_timer = 0

func displayMessageText(message):
  messageTextLabel.visible = true
  messageTextLabel.bbcode_text = "[center][wave]" + message + "[/wave][/center]"
  should_display_message_text = true
  message_text_timer = 0

func setDisplayTitle(title):
  display_title = title
  levelTitleRect.get_node("RichTextLabel").bbcode_text = ("[center][wave amp=50 freq=2]" + title + "[/wave][/center]")
  title_display_timer = 0
  title_display_state = 0
  levelTitleRect.rect_pivot_offset = levelTitleRect.rect_size / 2
  levelTitleRect.rect_scale = Vector2(0, 1)

onready var glitchSpriteContainer = get_node("GlitchSpriteColorRect")
onready var glitchSprite = get_node("GlitchSpriteColorRect/ColorRect2/ColorRect3/GlitchSprite")
func normalGlitch():
  glitchSprite.frame = 9

func floorGlitch():
  glitchSprite.frame = 1

func featherGlitch():
  glitchSprite.frame = 0

func ladderGlitch():
  glitchSprite.frame = 2

func invisibleGlitch():
  glitchSprite.frame = 3

func walkThroughWallsGlitch():
  glitchSprite.frame = 5

func changeCastSpritePalette():
  pauseMenu.changeCastSpritePalette()

onready var glitchedSkullSprite = get_node("LivesRect/GlitchedSkullSprite")
var curr_glitched_skull_sprite_x = 0
var curr_glitched_skull_sprite_y = 0
func cloneGlitchedSkullSprite():
  # global.lifeUISound.play()
  if not glitchedSkullSprite.visible:
    glitchedSkullSprite.visible = true
    curr_glitched_skull_sprite_x = glitchedSkullSprite.position.x
    curr_glitched_skull_sprite_y = glitchedSkullSprite.position.y
  else:
    var newSkullSprite = glitchedSkullSprite.duplicate()
    newSkullSprite.visible = true
    livesRect.add_child(newSkullSprite)
    curr_glitched_skull_sprite_x += 28
    if curr_glitched_skull_sprite_x >= global.OFFSET_X:
      curr_glitched_skull_sprite_x = -global.OFFSET_X
      curr_glitched_skull_sprite_y += 28
    newSkullSprite.position.x = curr_glitched_skull_sprite_x
    newSkullSprite.position.y = curr_glitched_skull_sprite_y