extends CanvasLayer

onready var heartsRect = get_node("HeartsRect")
var heart_recovery_timer = 0
var heart_recovery_time_limit = 5

onready var powerupRect = get_node("PowerupRect")
onready var powerupSprite = get_node("PowerupRect/ColorRect/ColorRect/PowerupSprite")
onready var powerupRectTextLabel = get_node("PowerupRect/ColorRect/ColorRect/RichTextLabel")

onready var miniCrystalCubeRect = get_node("MiniCrystalCubeRect")
onready var miniCrystalCubeTextLabel = get_node("MiniCrystalCubeRect/ColorRect/ColorRect/RichTextLabel")

onready var inventoryControl = get_node("Inventory")
var inventory_index = 0
func getInventoryBBText():
  if inventory_index == 0:
    return "GRIMOIRE spells:\n  •floor\n  •feather"
  if inventory_index == 1:
    return "...hi!!! hi!!! hi hi hi!..."

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
  recreateHeartSprites()
  hiscoreRect.visible = false
  congratsHiscoreLabel.visible = false
  crystalCubeHiscoreLabel.visible = false
  glitchTilesHiscoreLabel.visible = false
  angelHiscoreLabel.visible = false
  deathsHiscoreLabel.visible = false
  jumpsHiscoreLabel.visible = false
  totalHiscoreLabel.visible = false
  pressEnterLabel.visible = false

func recreateHeartSprites():
  var heartSprite = heartsRect.get_node("ColorRect/ColorRect/HeartSprite")
  heartSprite.visible = false
  var heartSpritesArray = heartsRect.get_node("ColorRect/ColorRect").get_children()
  for i in range(heartSpritesArray.size() - 1):
    heartSpritesArray[heartSpritesArray.size() - i - 1].queue_free()
  for i in range(global.memory["max_hp"] - 1):
    heartSprite.visible = true
    var newHeartSprite = heartSprite.duplicate()
    newHeartSprite.visible = true
    newHeartSprite.global_position.x = 72 + i * 48
    heartsRect.get_node("ColorRect/ColorRect").add_child(newHeartSprite)

onready var glitchStatusText1 = get_node("GlitchStatusRect/RichTextLabel")
onready var glitchStatusText2 = get_node("GlitchStatusRect/RichTextLabel2")
onready var keyStatusRect = get_node("KeyStatusRect")
onready var keyStatusText1 = get_node("KeyStatusRect/RichTextLabel")
onready var keyStatusText2 = get_node("KeyStatusRect/RichTextLabel2")
onready var pauseMenu = get_node("PauseMenu")
func _process(delta):
  processControlsLogic(delta)
  processQuitGameRenderLogic(delta)
  processCutsceneRenderLogic(delta)
  processHiscoreRenderLogic(delta)
  # TODO(jaketrower):
  if global.memory.has("key"):
    keyStatusRect.visible = true
    keyStatusText1.text = str(global.memory["key"])
    keyStatusText2.text = str(global.memory["key"])
  else:
    keyStatusRect.visible = false
    
  # if global.memory["max_mp"] <= 0:
  #  get_node("GlitchStatusRect").visible = false
  # statsTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = "MAGICK: "+ str(global.memory["mp"]) + " / " + str(global.memory["max_mp"]) + " CRYSTALS"
  var glitchStatusText = str(global.getLevelZoneThing("num_mini_crystal_cubes")) # str(global.memory["mp"]) + " /\n" + str(global.memory["max_mp"])
  glitchStatusText1.text = glitchStatusText 
  glitchStatusText2.text = glitchStatusText
  #it's okay to let the UI go fast, even if it's hearts # delta = delta * global.time_dilation_multiplier

  inventoryControl.visible = global.isInventoryOpen
  pauseMenu.visible = global.isPauseMenuOpen

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
    

  if title_display_state < 3 and display_title != "???" and (not global.memory.has("roomPath") or "DebugTown" in global.memory["roomPath"]):
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
  if global.activeInteractor or global.isPauseMenuOpen:
    levelTitleRect.rect_scale.x = 0
    title_display_timer = 0
    title_display_state = 3

  if should_display_saving_text:
    saving_text_timer += (delta*22)
    if saving_text_timer >= saving_text_time_limit:
      should_display_saving_text = false
      savingTextLabel.visible = false

  if should_display_spell_message_text:
    spell_message_text_timer += (delta*22)
    if spell_message_text_timer >= spell_message_text_time_limit:
      should_display_spell_message_text = false
      spellMessageTextLabel.visible = false

  if should_display_message_text:
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

  # tryLerpSpriteFromCenter(get_node("GlitchSprite"), delta, Vector2(0, 1))
  # tryLerpFromCenter(get_node("GlitchStatusRect"), delta, Vector2(3, 66))
  if global.memory.has("tutorial_spellbookPage") and global.memory["tutorial_spellbookPage"]:
    tryLerpFromCenter(get_node("EquipmentRect"), delta, Vector2(65, 3))
    tryLerpFromCenter(get_node("EquipmentStatusRect"), delta, Vector2(68, 79))
    if global.memory.has("spellbookPage") and global.memory["spellbookPage"].size() > 1:
      get_node("EquipmentStatusRect/RichTextLabel").text = "swing BROOM"

  if global.memory.has("spellbookPage"):
    var equipSlotSprite = get_node("EquipmentRect/ColorRect/ColorRect/ColorRect2/ColorRect3/EquipmentSlotSprite")
    if global.memory["spellbookPage"].size() <= 1 and (
       global.memory["spellbookPage"].size() != 1 or getPlayer().glitch_form != global.GlitchForm.NORMAL):
      equipSlotSprite.frame = 6
    else:
      var glitch = global.memory["spellbookPage"][0]
      if glitch == global.GlitchForm.FLOOR: equipSlotSprite.frame = 0
      elif glitch == global.GlitchForm.FEATHER: equipSlotSprite.frame = 14
      elif glitch == global.GlitchForm.LADDER: equipSlotSprite.frame = 25
      elif glitch == global.GlitchForm.INVISIBLE: equipSlotSprite.frame = 21
      elif glitch == global.GlitchForm.WALK_THROUGH_WALLS: equipSlotSprite.frame = 32

onready var quitGameRect = get_node("QuitGameRect")
onready var quitGameText = get_node("QuitGameRect/ColorRect/ColorRect/RichTextLabel")
var quitGameTimer = 0
var quitGameTimeLimit = 20
func processQuitGameRenderLogic(delta):
  if not global.isPauseMenuOpen:
    if global.pauseMoveInput or global.pauseGame or global.hasGottenLevelGeode or global.hasLevelGeodeBeenSmacked:
      quitGameTimer = 0
      quitGameRect.visible = false
      return

  if Input.is_action_pressed("ui_cancel"):
    quitGameRect.visible = true
    quitGameTimer += (delta*11)
    if quitGameTimer < 5:
      quitGameText.text = "hold ESC to quit: ... 3"
    elif quitGameTimer < 10:
      quitGameText.text = "hold ESC to quit: ... 3 ... 2"
    elif quitGameTimer < 15:
      quitGameText.text = "hold ESC to quit: ... 3 ... 2 ... 1!"
    if quitGameTimer >= quitGameTimeLimit:
      level.get_tree().quit()
  else:
    quitGameRect.visible = false
    quitGameTimer = 0

onready var cinematicTopRect = get_node("CinematicTopRect")
onready var cinematicBottomRect = get_node("CinematicBottomRect")
onready var cinematicAniPlayer = get_node("CinematicAnimationPlayer")
func initiateCutsceneRenderLogic():
  if global.pauseMoveInput:
    cinematicAniPlayer.play("startCutsceneImmediate")

func processCutsceneRenderLogic(_delta):
  var aa = cinematicAniPlayer.assigned_animation
  if global.pauseMoveInput and not "startCutscene" in aa and not global.isRespawning:
    cinematicAniPlayer.play("startCutscene")
  elif not global.pauseMoveInput and aa != null and not "endCutscene" in aa and not aa == "":
    cinematicAniPlayer.play("endCutscene")


onready var hiscoreRect = get_node("HiscoreRect")
onready var congratsHiscoreLabel = get_node("CongratsHiscoreLabel")
onready var crystalCubeHiscoreLabel = get_node("CrystalCubeHiscoreLabel")
onready var glitchTilesHiscoreLabel = get_node("GlitchTilesHiscoreLabel")
onready var deathsHiscoreLabel = get_node("DeathsHiscoreLabel")
onready var angelHiscoreLabel = get_node("AngelHiscoreLabel")
onready var jumpsHiscoreLabel = get_node("JumpsHiscoreLabel")
onready var totalHiscoreLabel = get_node("TotalHiscoreLabel")
onready var pressEnterLabel = get_node("PressEnterLabel")
var hiscoreDisplayIndex = 0
var hiscoreCounter = 0
var totalHiscoreCounter = 0
var hiscoreTimer = 0
var hiscoreTimeLimit = 1
func processHiscoreRenderLogic(delta):
  if not global.hasGottenLevelGeode or global.hasLevelGeodeBeenSmacked:
    hiscoreRect.visible = false
    congratsHiscoreLabel.visible = false
    crystalCubeHiscoreLabel.visible = false
    glitchTilesHiscoreLabel.visible = false
    angelHiscoreLabel.visible = false
    deathsHiscoreLabel.visible = false
    jumpsHiscoreLabel.visible = false
    totalHiscoreLabel.visible = false
    pressEnterLabel.visible = false
    return
  hiscoreRect.visible = true
  congratsHiscoreLabel.visible = true
  congratsHiscoreLabel.text = "   CONGRATS:\nU won a dungeon!!"

  hiscoreTimer += (delta*11)
  if hiscoreTimer >= hiscoreTimeLimit:
    glitchStatusText1.visible = false
    glitchStatusText2.visible = false
    hiscoreTimer = 0
    # TODO(jaketrower): can consolidate this but i'm lazy rn
    if hiscoreDisplayIndex == 0:
      totalHiscoreLabel.visible = true
      crystalCubeHiscoreLabel.visible = true
      crystalCubeHiscoreLabel.text = "mini crystals: " + str(hiscoreCounter) + "   (* 3) = " + str(hiscoreCounter * 3)
      var hiscoreSource = global.getLevelZoneThing("num_mini_crystal_cubes")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter += 1
        totalHiscoreCounter += 3
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
    elif hiscoreDisplayIndex == 1:
      deathsHiscoreLabel.visible = true
      deathsHiscoreLabel.text = "+ deaths: " + str(hiscoreCounter) + "   (* 1 ) = " + str(hiscoreCounter * 1)
      var hiscoreSource = global.getLevelZoneThing("num_deaths")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter += 1
        totalHiscoreCounter += 1
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
    elif hiscoreDisplayIndex == 2:
      angelHiscoreLabel.visible = true
      angelHiscoreLabel.text = "+ angels: " + str(hiscoreCounter) + "   (* 20) = " + str(hiscoreCounter * 20)
      var hiscoreSource = global.getLevelZoneThing("angelTadpole")
      if hiscoreSource != null and hiscoreCounter < hiscoreSource:
        hiscoreCounter += 1
        totalHiscoreCounter += 20
      else:
        hiscoreDisplayIndex += 1
        hiscoreCounter = 0
        hiscoreTimeLimit = 5
    elif hiscoreDisplayIndex == 3:
      glitchTilesHiscoreLabel.visible = true
      glitchTilesHiscoreLabel.text = "broom sweeps: " + str(global.getLevelZoneThing("num_broom_sweeps"))
      hiscoreDisplayIndex += 1
    elif hiscoreDisplayIndex == 4:
      jumpsHiscoreLabel.visible = true
      jumpsHiscoreLabel.text = "jumps: " + str(global.getLevelZoneThing("num_jumps"))
      hiscoreDisplayIndex += 1
    elif hiscoreDisplayIndex == 5:
      pressEnterLabel.visible = not pressEnterLabel.visible
      pressEnterLabel.text = "press enter\nto continue"
    totalHiscoreLabel.text = "= total score: " + str(totalHiscoreCounter)
    if level.has_node("CubeCrystal"):
      global.setLevelZoneThing("hiscore", totalHiscoreCounter)
  
  if hiscoreDisplayIndex >= 5 and (Input.is_action_just_pressed("ui_start") or Input.is_action_just_pressed("sub_action_button")):  
    transition.long_fade_to("res://levels/EndlessFantasy/gd1/005DebugTown.tscn")

func tryLerpFromCenter(rect, delta, final_pos):
  if rect.rect_scale.x > 1:
    rect.rect_scale.x = rect.rect_scale.x + (1 - rect.rect_scale.x) * (delta*2)
    rect.rect_scale.y = rect.rect_scale.y + (1 - rect.rect_scale.y) * (delta*2)
    if stepify(rect.rect_scale.x, 0.1) == 1:
      rect.rect_scale = Vector2(1, 1)
  if rect.rect_position.x > final_pos.x:
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

func displaySavingText(message = "saving (not really)"):
  savingTextLabel.visible = true
  savingTextLabel.bbcode_text = "[wave] "+message+"[/wave]"
  should_display_saving_text = true
  saving_text_timer = 0

func displaySpellMessageText(message):
  spellMessageTextLabel.visible = true
  spellMessageTextLabel.bbcode_text = "[wave] "+message+"[/wave]"
  should_display_spell_message_text = true
  spell_message_text_timer = 0

func displayMessageText(message):
  messageTextLabel.visible = true
  messageTextLabel.bbcode_text = "[wave] "+message+"[/wave]"
  should_display_message_text = true
  message_text_timer = 0

func setDisplayTitle(title):
  display_title = title
  levelTitleRect.get_node("ColorRect/ColorRect/RichTextLabel").bbcode_text = ("[wave amp=50 freq=2]" + title + "[/wave]")

onready var glitchSprite = get_node("GlitchSprite")
func normalGlitch():
  glitchSprite.visible = false
  glitchSprite.frame = 0

func glitch(_palette):
  glitchSprite.visible = true

func floorGlitch():
  glitch(global.red_palette)
  glitchSprite.frame = 2

func featherGlitch():
  glitch(global.green_palette)
  glitchSprite.frame = 1

func ladderGlitch():
  glitch(global.yellow_palette)
  glitchSprite.frame = 4

func invisibleGlitch():
  glitch(global.black_palette)
  glitchSprite.frame = 3

func walkThroughWallsGlitch():
  glitch(global.white_palette)

onready var rightSprite = get_node("PauseMenu/RightSprite")
onready var rightSpriteAniPlayer = get_node("PauseMenu/RightSprite/AnimationPlayer")
onready var rightTextLabel = get_node("PauseMenu/RightTextLabel")
onready var leftSprite = get_node("PauseMenu/LeftSprite")
onready var leftSpriteAniPlayer = get_node("PauseMenu/LeftSprite/AnimationPlayer")
onready var leftTextLabel = get_node("PauseMenu/LeftTextLabel")
onready var downSprite = get_node("PauseMenu/DownSprite")
onready var downSpriteAniPlayer = get_node("PauseMenu/DownSprite/AnimationPlayer")
onready var downTextLabel = get_node("PauseMenu/DownTextLabel")
onready var upSprite = get_node("PauseMenu/UpSprite")
onready var upSpriteAniPlayer = get_node("PauseMenu/UpSprite/AnimationPlayer")
onready var upTextLabel = get_node("PauseMenu/UpTextLabel")
onready var jumpSprite = get_node("PauseMenu/JumpSprite")
onready var jumpSpriteAniPlayer = get_node("PauseMenu/JumpSprite/AnimationPlayer")
onready var jumpTextLabel = get_node("PauseMenu/JumpTextLabel")
onready var sweepSprite = get_node("PauseMenu/SweepSprite")
onready var sweepSpriteAniPlayer = get_node("PauseMenu/SweepSprite/AnimationPlayer")
onready var sweepTextLabel = get_node("PauseMenu/SweepTextLabel")
onready var castSprite = get_node("PauseMenu/CastSprite")
onready var castSpriteAniPlayer = get_node("PauseMenu/CastSprite/AnimationPlayer")
onready var castTextLabel = get_node("PauseMenu/CastTextLabel")
onready var menuMoveSound = get_node("PauseMenu/MenuMoveSound")
onready var inputText = get_node("PauseMenu/InputRect/ColorRect/ColorRect/RichTextLabel")

var areControlsAnimating = false
var control_index = 0
var last_control_index = -1
var is_reading_input = false

func _input(ev):
  # TODO(jaketrower): don't allow players to set a key that's already being used
  var keyText = OS.get_scancode_string(ev.scancode)

  if keyText != "Escape" and keyText != "Enter":
      erase_action_events(input_action_to_read)

func processControlsLogic(_delta):
  if global.isPauseMenuOpen:
    if is_reading_input:
      inputText.bbcode_text = "press key"
    else:
      inputText.bbcode_text = "press X to change key"

    if is_reading_input:
      pass
    else:
      if Input.is_action_just_pressed("sub_action_button"):
        is_reading_input = true
        last_control_index = -1
      elif Input.is_action_just_pressed("ui_down"):
        control_index += 1
        menuMoveSound.play()
      elif Input.is_action_just_pressed("ui_up"):
        control_index -= 1
        menuMoveSound.play()

    if control_index < 0:
      control_index = 6
    if control_index > 6:
      control_index = 0

    var normal_size = Vector2(2, 2)
    var big_size = Vector2(3, 3)
    rightSprite.scale = normal_size
    
    leftSprite.scale = normal_size
    downSprite.scale = normal_size
    upSprite.scale = normal_size
    jumpSprite.scale = normal_size
    sweepSprite.scale = normal_size
    castSprite.scale = normal_size
    if control_index != 0: rightTextLabel.bbcode_text = "[color=gray]right[/color]"
    if control_index != 1: leftTextLabel.bbcode_text = "[color=gray]left[/color]"
    if control_index != 2: downTextLabel.bbcode_text = "[color=gray]down[/color]"
    if control_index != 3: upTextLabel.bbcode_text = "[color=gray]up[/color]"
    if control_index != 4: jumpTextLabel.bbcode_text = "[color=gray]z[/color]"
    if control_index != 5: sweepTextLabel.bbcode_text = "[color=gray]x[/color]"
    if control_index != 6: castTextLabel.bbcode_text = "[color=gray]c[/color]"
    if control_index == 0:
      rightSprite.scale = big_size
      if control_index != last_control_index:
        rightTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]right[/wave]"
    elif control_index == 1:
      leftSprite.scale = big_size
      if control_index != last_control_index: 
        leftTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]left[/wave]"
    elif control_index == 2:
      downSprite.scale = big_size
      if control_index != last_control_index: 
        downTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]down[/wave]"
    elif control_index == 3:
      upSprite.scale = big_size
      if control_index != last_control_index: 
        upTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]up[/wave]"
    elif control_index == 4:
      jumpSprite.scale = big_size
      if control_index != last_control_index: 
        jumpTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]z[/wave]"
    elif control_index == 5:
      sweepSprite.scale = big_size
      if control_index != last_control_index: 
        sweepTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]x[/wave]"
    elif control_index == 6:
      castSprite.scale = big_size
      if control_index != last_control_index: 
        castTextLabel.bbcode_text = "[wave]press key[/wave]" if is_reading_input else "[wave]c[/wave]"

    if not areControlsAnimating:
      leftSpriteAniPlayer.play("idle")
      rightSpriteAniPlayer.play("idle")
      downSpriteAniPlayer.play("idle")
      upSpriteAniPlayer.play("idle")
      jumpSpriteAniPlayer.play("idle")
      sweepSpriteAniPlayer.play("idle")
      castSpriteAniPlayer.play("idle")
      areControlsAnimating = true
    last_control_index = control_index
  else:
    control_index = 0
    last_control_index = -1
    if areControlsAnimating:
      leftSpriteAniPlayer.stop()
      rightSpriteAniPlayer.stop()
      downSpriteAniPlayer.stop()
      upSpriteAniPlayer.stop()
      jumpSpriteAniPlayer.stop()
      sweepSpriteAniPlayer.stop()
      castSpriteAniPlayer.stop()
      areControlsAnimating = false

var castSpritePalette = 0
func changeCastSpritePalette():
  if castSpritePalette == 0:
    castSprite.material.set_shader_param("palette_out", global.green_palette)
    castSpritePalette = 1
  elif castSpritePalette == 1:
    castSprite.material.set_shader_param("palette_out", global.red_palette)
    castSpritePalette = 2
  elif castSpritePalette == 2:
    castSprite.material.set_shader_param("palette_out", global.grey_player_palette)
    castSpritePalette = 0
