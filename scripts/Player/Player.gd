extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var hurt3Sound = get_node("Sounds/HurtSound3")
onready var broomSound = get_node("Sounds/BroomSound")
onready var noBroomSound = get_node("Sounds/NoBroomSound")
onready var errorSound = get_node("Sounds/ErrorSound")
onready var blinkSound = get_node("Sounds/BlinkSound")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var returnSound = get_node("Sounds/ReturnSound")
onready var grannyLandSound = get_node("Sounds/GrannyLandSound")
onready var poisonWaterSound = get_node("Sounds/PoisonWaterSound")
onready var reversePoisonWaterSound = get_node("Sounds/PoisonWaterReverseSound")
onready var footstepSound = get_node("Sounds/FootstepSound")
onready var hookSound = get_node("Sounds/HookSound")
onready var reelSound = get_node("Sounds/ReelSound")
onready var digSound = get_node("Sounds/DigSound")
onready var saveSound = get_node("Sounds/SaveSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")
onready var mpNumSprite = get_node("MPNumSprite")
onready var mpNumSprite2 = get_node("MPNumSprite/MPNumSprite2")
onready var chickenSprite = get_node("SpriteContainer/InnerSpriteContainer/ChickenSprite")
onready var fishySprite = get_node("SpriteContainer/InnerSpriteContainer/FishySprite")
onready var mushroomSpriteAnimated = get_node("SpriteContainer/Sprite3DMushroomAnimated")
onready var mushroomSpriteVisible = get_node("SpriteContainer/Sprite3DMushroomVisible")
onready var mushroomSpriteAniPlayer = get_node("SpriteContainer/Sprite3DMushroomAnimated/AnimationPlayer")
onready var bubbleSprite = get_node("BubbleSprite")

var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
# var spriteSheetFeather = preload("res://assets/player_sheet_old_feather.png")
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 10

onready var spriteContainer = get_node("SpriteContainer")
onready var broomSpriteAnimated = get_node("SpriteContainer/Sprite3DBroomAnimated")

onready var enchantedBagSpriteAnimated = get_node("SpriteContainer/Sprite3DBagAnimated")
onready var enchantedBagSpriteVisible = get_node("SpriteContainer/Sprite3DBagVisible")

onready var textContainer = get_node("TextContainer")
onready var textBox = get_node("TextContainer/TextBox")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var should_turn_on_glitch_screen_effects = false
var glitch_death_timer = 0
var glitch_tickle_time_limit = 10
var can_cast_spell_timer = 0
var can_cast_spell_time_limit = 10
var poison_timer = 0
var poison_time_limit = 28
var unpoison_timer = 0
var unpoison_time_limit = 10

func _ready():
  set_process(true)
  set_physics_process(false)
  if pauseMenu: pauseMenu.hide()

  remembered_walk_speed = walk_speed
  remembered_feather_glitch_walk_speed = feather_glitch_walk_speed
  remembered_invisible_glitch_walk_speed = invisible_glitch_walk_speed
  broomSpriteVisible.get_material_override().set_shader_param("opacity", 1.0)
  broomSpriteAnimated.get_material_override().set_shader_param("opacity", 1.0)
  mySprite.get_material_override().set_shader_param("opacity", 1.0)

# make this work with FLIP GRAVITY (level.flipGravity) (and bubble form uses it too)
func processWallLadderWalking(delta):
  .processWallLadderWalking(delta) # super
  # if pressingMoveLeft():
  #   spriteContainer.rotation_degrees.z = 270
  # elif pressingMoveRight():
  #   spriteContainer.rotation_degrees.z = 90
func processNotWallLadderWalking(delta):
  .processNotWallLadderWalking(delta)
  # spriteContainer.rotation_degrees.z = 0
  # if summonedBroom:
  #   summonedBroom.rotation_degrees.z = 0

# @override
func alignMySprite():
  var pixelSize = 0.125
  if spriteContainer:
    spriteContainer.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    spriteContainer.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + spriteYAlignment

func tryPlayFootstepSound():
  if transformation == TransformationState.UNDERGROUND:
    return
  if transformation == TransformationState.UNDERGROUND_RETURNING:
    return
  if transformation == TransformationState.FISHY:
    return
  if transformation == TransformationState.BUBBLE:
    return

  if global.isPauseMenuOpen or global.pauseGame:
    return 
  if not (pressingMoveLeft() or pressingMoveRight()):
    return
  if glitch_form == global.GlitchForm.FLOOR and not truly_on_ground or is_mushroom_infected:
    sporeSound.play()
    return
  if on_ground or glitch_form == global.GlitchForm.LADDER:
    if on_ground and not (glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall()):
      if nesting_doll_state == global.NestingDoll.MATRIARCH:
        footstepSound.pitch_scale = rand_range(0.6, 0.8)
      elif nesting_doll_state == global.NestingDoll.BABY:
        footstepSound.pitch_scale = rand_range(1.2, 1.3)
      else:
        footstepSound.pitch_scale = rand_range(0.9, 1.1)
      footstepSound.play()
    else:
      sporeSound.play()

func applyNextGlitch():
  applyGlitch(global.getNextGlitch(glitch_form))
  
func applyObeliskGlitch(glitch, add_spell_to_grimoire = true):
  if applyGlitch(glitch, false) and add_spell_to_grimoire and \
     global.memory.has("spellbookPage") and not global.memory["spellbookPage"].has(glitch):
    global.memory["spellbookPage"].push_back(glitch)
    # TODO..
    if not global.memory["glitched_grimoire"] and global.memory["spellbookPage"].size() > 2:
      global.memory["spellbookPage"].pop_front()

# used in AnimationPlayer.broomSmackGlitch
func actuallyApplySpellbookGlitch():
  var spellbookSize = global.memory["spellbookPage"].size() if global.memory.has("spellbookPage") else 0
  if spellbookSize == 0:
    return
  while spellCastPauseIndex < 0:
    spellCastPauseIndex += spellbookSize
  spellCastPauseIndex = spellCastPauseIndex % spellbookSize
  var glitch_type = global.memory["spellbookPage"][spellCastPauseIndex]
  applyGlitch(glitch_type)
  applyObeliskGlitch(glitch_type, false)
    
func applySpellbookGlitch():
  if not global.memory.has("spellbookPage") or global.memory["spellbookPage"].size() <= 0:
    return
  actuallyApplySpellbookGlitch()
  # aniPlayer.stop()
  # aniPlayer.clear_queue()
  # aniPlayer.play("broomSmackGlitch")
  # see actuallyApplySpellbookGlitch(), which is applied by this animation ^^
  # pauseInput = true
  # pauseAnimation = true

func restoreGlitchAndMP():
  if global.memory["mp"] <= 0:
    applyGlitch(global.memory["current_glitch"], true)
  global.memory["mp"] = global.memory["max_mp"]
  

func applyGlitch(glitch, notPlaySound = false):
  if returning_to_save_point > 0:
    return false
  glitchTilesAroundMe(0.25, true)
  nullifySound.stop()
  if not notPlaySound:
    if glitch == self.glitch_form:
      rechargeSound.play()
    else:
      transformSound.pitch_scale = rand_range(0.8, 1.2)
      transformSound.play()
  global.memory["current_glitch"] = glitch

  # if glitch_form == global.GlitchForm.INVISIBLE and glitch != global.GlitchForm.INVISIBLE:
  #   getABroom()
  # mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  if glitch == global.GlitchForm.NORMAL: self.normalGlitch()
  if glitch == global.GlitchForm.FLOOR: 
    if self.glitch_form == global.GlitchForm.LADDER and (was_walking_into_wall or isWalkingIntoWall()):
      on_ground = true
    floorGlitch()
  if glitch == global.GlitchForm.FEATHER: featherGlitch()
  if glitch == global.GlitchForm.LADDER: ladderGlitch()
  if glitch == global.GlitchForm.INVISIBLE: invisibleGlitch()
  if glitch == global.GlitchForm.WALK_THROUGH_WALLS: walkThroughWallsGlitch()
  return true

func floorGlitch():
  spellbookGlitchSprite.frame = 1
  level.displaySpellMessageText("air walk")
  glitch_form = global.GlitchForm.FLOOR
  level.floorGlitch()
  changeSpriteColorPalette(global.player_red_palette)
  # should_collide_floor = not (on_ground and not truly_on_ground)
  # mySprite.setBugCatcherCostume()

func miniUpwardGust(reverse_immediately = true):
  var upward_gust = 5
  if linear_velocity.y < 0:
    if reverse_immediately:
      linear_velocity.y = 1
      lv.y = 1
      vv = 1
    else:
      linear_velocity.y /= 2
      lv.y /= 2
      vv /= 2
  linear_velocity.y += upward_gust
  lv.y += upward_gust
  vv += upward_gust

func featherGlitch():
  spellbookGlitchSprite.frame = 0
  var ui = level.uiLayer
  if glitch_form != global.GlitchForm.FEATHER and not on_ground and \
     (not ui.spellMessageTextLabel.visible or ui.spell_message_text_timer > 20) and transformation != TransformationState.FISHY:
    miniUpwardGust()
  level.displaySpellMessageText("feather fall")
  glitch_form = global.GlitchForm.FEATHER
  level.featherGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.green_dungeon_palette)
  # mySprite.setMothCostume()
  # mySprite.material_override.set_shader_param("texture_albedo", spriteSheetFeather)

func ladderGlitch():
  spellbookGlitchSprite.frame = 2
  level.displaySpellMessageText("ladder")
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.yellow_player_palette)
  # mySprite.setLuckyCatCostume()

func invisibleGlitch():
  # loseBroom()
  spellbookGlitchSprite.frame = 3
  level.displaySpellMessageText("ghost")
  glitch_form = global.GlitchForm.INVISIBLE
  level.invisibleGlitch()
  changeSpriteColorPalette(global.black_player_palette)
  # mySprite.setClericCostume()

func walkThroughWallsGlitch():
  level.displaySpellMessageText("undefined")
  glitch_form = global.GlitchForm.WALK_THROUGH_WALLS
  level.walkThroughWallsGlitch()
  changeSpriteColorPalette(global.white_player_palette)
  # mySprite.setNightgown()

func wearCostume(costume):
  global.memory["player_costume"] = costume

# @override
func pressingRun():
  if nesting_doll_state == global.NestingDoll.BABY:
    return true
  elif not canRun():
    return
  elif nesting_doll_state == global.NestingDoll.MOM:
    return true
  # elif Input.is_action_pressed("run_button"):
  #   return true
  return .pressingRun()

# @override
func canRun():
  return false
  # var is_giant = nesting_doll_state == global.NestingDoll.MATRIARCH
  # return not is_giant

# @override
func canSwim():
  return transformation == TransformationState.FISHY
  
func isWalkingIntoWall():
  if summonedBroom != null:
    return was_walking_into_wall
  else:
    return .isWalkingIntoWall() # super

func sayThis(message, _time_to_clear = 3.0):
  textBox.text_final = message
  textBox.interact()
  global.activeInteractor = textBox
  # yield(get_tree().create_timer(time_to_clear), "timeout")
  # textBox.hideTextbox()

var returning_recover_time = 0
var returning_recover_time_limit = 3
var spriteOpacity = 1.0
func _process(delta):
  # ._process(delta) #NOTE: this super method is called automatically 
  # https://github.com/godotengine/godot/issues/6500

  processBroomRenderLogic(delta)
  processBagRenderLogic(delta)
  if global.isEnteringRoom:
    return
  if level.pacman_wrapping:
    target_last_grounded_y = global_transform.origin.y

  if aniPlayer.assigned_animation == "getItem" and not aniPlayer.is_playing():
    getItemFailsafe()

  if Input.is_action_just_pressed("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
    level.uiLayer.pauseMenu.shouldUpdateMenuText = true
  if Input.is_action_just_pressed("restart_key") and not global.isPauseMenuOpen and not global.pauseGame and ritual_state_index < len(global.correct_ritual)-1:
    tryDieToEnemy(delta, true, true, true)
    global.incrementLevelZoneThing("num_deaths", -1)
  
  delta = delta * global.time_dilation_multiplier

  var newSpriteOpacity = spriteOpacity
  if aniPlayer.assigned_animation == "returning":
    newSpriteOpacity = 0.5
  elif transformation == TransformationState.BUBBLE:
    newSpriteOpacity = 0.5
  elif glitch_form == global.GlitchForm.INVISIBLE:
    newSpriteOpacity = 0.9
  # elif glitch_form == global.GlitchForm.INVISIBLE:
  #   newSpriteOpacity = 0.8
  else:
    newSpriteOpacity = 1.0
  if newSpriteOpacity != spriteOpacity:
    spriteOpacity = newSpriteOpacity
    mySprite.get_material_override().set_shader_param("opacity", spriteOpacity)
    broomSpriteVisible.get_material_override().set_shader_param("opacity", spriteOpacity)
  if mySprite.flip_h:
    spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x - 0.25
  else:
    spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x + 0.25
  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL and global.memory["colorblindMode"] and transformation == TransformationState.NORMAL

  bubbleSprite.visible = transformation == TransformationState.BUBBLE
  if transformation == TransformationState.BUBBLE:
    if (horizontal_collision or on_ground or justPressedJump()) and physics_state != PhysicsState.GLITCH_DYING:
      getBubbleCured()

  if global.isPauseMenuOpen:
    return

  # if Input.is_action_pressed("sub_action_button") and on_ground:
  #   mySprite.flip_h = broom_flip_h
  # else:
  #   broom_flip_h = mySprite.flip_h

  if aniPlayer.assigned_animation == "broomSmackGlitch":
    linear_velocity = Vector3(0, 0, 0)
    lv = linear_velocity
    vv = 0
    hv = 0

  if returning_to_save_point == 1:
    linear_velocity = Vector3(0, 0, 0)
    lv = linear_velocity
    vv = 0
    hv = 0
    fall_timer = 0
    global_transform.origin = moveToward2D(global_transform.origin, last_grounded_pos, delta * 22)
    if compare2D(global_transform.origin, last_grounded_pos):
      global_transform.origin = last_grounded_pos
      returning_to_save_point = 2
  if returning_to_save_point == 2:
    if aniPlayer.assigned_animation == "returning":
      aniPlayer.play("land")
    returning_recover_time += (delta*11)
    if returning_recover_time >= returning_recover_time_limit:
      returning_recover_time = 0
      ignorePhysics = false
      pauseAnimation = false
      pauseSelf = false
      physics_state = PhysicsState.NORMAL
      returning_to_save_point = 0
      global.pauseMoveInput = false
      global.pauseGame = false
  if not processGlitchHurtRecovery(delta):
    return

  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.IGNORE_PHYSICS:
    return
  processCastingLogic(delta)
  processBroomLogic(delta)
  processBagLogic(delta)
  processMushroomLogic(delta)
  processFishyLogic(delta)
  processMoleLogic(delta)
  processChickenLogic(delta)
  processCurseLogic(delta)
  processAngelStatueRitual(delta)
    
  # doTimeDilation(real_delta)

  if can_cast_spell_timer < can_cast_spell_time_limit:
    can_cast_spell_timer += (delta*22)

  # if Input.is_action_just_pressed("action_button") and can_cast_spell_timer >= can_cast_spell_time_limit:
  #   applySpellbookGlitch()
  if Input.is_action_just_pressed("debug_glitch_button"):
    applyNextGlitch()
  if Input.is_action_just_pressed("debug_toggle_spellbook"):
    if global.memory["glitched_grimoire"]:
      global.memory["glitched_grimoire"] = false
      global.memory.erase("spellbookPage")
    elif global.memory.has("spellbookPage"):
      global.memory["glitched_grimoire"] = true
      global.memory["spellbookPage"] = [GlitchForm.FLOOR, GlitchForm.FEATHER, GlitchForm.INVISIBLE, GlitchForm.LADDER]
    else:
      global.memory["spellbookPage"] = [glitch_form]
  if Input.is_action_just_pressed("debug_upgrade_broom"):
    if global.memory["broomerang"] == 0:
      global.memory["broomerang"] = 1
      global.memory["broom_double_jump"] = 1
    elif global.memory["broomerang"] < 2:
      global.memory["max_hp"] = 2
      global.memory["hp"] = 2
      global.memory["broomerang"] = 2
      global.memory["multi_broom"] = 1
  if Input.is_action_just_pressed("debug_more_crystals"):
    if global.getThingFromAllLevelZonez("num_mini_crystal_cubes") < 99:
      global.incrementLevelZoneThing("num_mini_crystal_cubes", 99)
    global.memory["clean_crystals"] = 99
    
  tryDieToOffscreenCamera(delta)
      
  if gimme_mini_crystal_cubes > 0:
    gimme_mini_crystal_cubes_timer += (delta*22)
    if gimme_mini_crystal_cubes_timer >= gimme_mini_crystal_cubes_time_limit:
      gimme_mini_crystal_cubes_timer = 0
      gimme_mini_crystal_cubes -= 1
      var newCrystalCube = miniCubeCrystal.duplicate()
      newCrystalCube.visible = true
      add_child(newCrystalCube)

  if lose_mini_crystal_cubes > 0:
    lose_mini_crystal_cubes_timer += (delta*22)
    if lose_mini_crystal_cubes_timer >= lose_mini_crystal_cubes_time_limit:
      lose_mini_crystal_cubes_timer = 0
      lose_mini_crystal_cubes -= 1
      var newCrystalCube = miniCubeCrystal.duplicate()
      newCrystalCube.is_negative = true
      newCrystalCube.visible = true
      add_child(newCrystalCube)

  if glitch_tickle_timer > 0:
    glitch_tickle_timer += (delta * 22)
    if glitch_tickle_timer >= glitch_tickle_time_limit:
      glitch_tickle_timer = 0
      mySprite.get_material_override().set_shader_param("enable_glitch", false)
      mySprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)
  
  processPoisonWaterLogic(delta)
  if pressingJump():
    tryClearFallthroughCollisionSolid()

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()

  # if global.memory.has("anna_mode") and global.memory["anna_mode"]:
  #   mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)
  #   broomSpriteVisible.material_override.set_shader_param("texture_albedo", broomSpriteSheetTiny)
  #   if global.memory.has("blue_mode") and global.memory["blue_mode"]:
  #     mySprite.material_override.set_shader_param("target_palette", global.base_palette)
  if global.memory.has("blue_mode") and global.memory["blue_mode"]:
    mySprite.material_override.set_shader_param("target_palette", global.NES_palette)
  

func unsmack():
  smack_timer = 0
  is_smacked = false
  if not global.hasLevelGeodeBeenSmacked and not is_mushroom_prefected:
    pauseSelf = false
  mySprite.material_override.set_shader_param("time_influence", 3)
  mySprite.material_override.set_shader_param("y_div", 2.3)
  # mySprite.material_override.set_shader_param("normal_offset", 0.0)
  mySprite.material_override.set_shader_param("normal_offset", .02)
  mySprite.material_override.set_shader_param("enable_palette_cycle", false)

var pausingFromSpellCasting = false
var tryPauseFromSpellCasting = false
var spellCastPauseIndex = 0
var spellCastPauseTimer = 0
var spellCastPauseTimeLimit = 0
var num_spell_casts_used = 0
var spellCastCounterResetTimer = 0
var spellCastCounterResetTimeLimit = 30
func processCastingLogic(_delta):
  if not global.memory.has("spellbookPage"):
    return

  if global.memory["spellAssist"]:
    # automatic mode
    var desired_spell = global.GlitchForm.NORMAL
    if touching_glitch_or_spikes:
      desired_spell = global.GlitchForm.INVISIBLE
    elif horizontal_collision and (pressingMoveLeft() or pressingMoveRight()):
      desired_spell = global.GlitchForm.LADDER
    elif justPressedJump():
      desired_spell = global.GlitchForm.FEATHER
    elif was_on_ground and not on_ground and not pressingJump() and (pressingMoveLeft() or pressingMoveRight()) and not pressingDown():
      desired_spell = global.GlitchForm.FLOOR
      on_ground = true
      
    tryToApplySpellAssist(desired_spell)
  else:
    # manual mode
    if (Input.is_action_just_pressed("alt_action_button") and not Input.is_action_pressed("run_button")) or Input.is_action_just_pressed("right_button"):
      if global.memory["spellbookPage"].size() <= 1:
        noSpellSound.play()
      else:
        spellCastPauseIndex += 1
        applySpellbookGlitch()
        level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
    elif (Input.is_action_just_pressed("alt_action_button") and Input.is_action_pressed("run_button")) or Input.is_action_just_pressed("left_button"):
      if global.memory["spellbookPage"].size() <= 1:
        noSpellSound.play()
      else:
        spellCastPauseIndex -= 1
        applySpellbookGlitch()
        level.summonSmokeClouds(self.global_transform.origin, 1, true, true)

    # TODO(REMAP)
    if global.memory.has("spellbookPage") and global.memory["glitched_grimoire"]:
      # TODO(): do these only work if you have > 2 spells?
      var spellbookSize = len(global.memory["spellbookPage"])
      if Input.is_action_just_pressed("spell_1"):
        if spellbookSize >= 1:
          spellCastPauseIndex = 0
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_2"):
        if spellbookSize >= 2:
          spellCastPauseIndex = 1
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_3"):
        if spellbookSize >= 3:
          spellCastPauseIndex = 2
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_4"):
        if spellbookSize >= 4:
          spellCastPauseIndex = 3
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)

func tryToApplySpellAssist(desired_spell):
  if glitch_form != desired_spell and desired_spell != global.GlitchForm.NORMAL and doIHaveSpell(desired_spell):
    var newSpellIndex = findSpellInSpellbook(desired_spell)
    if newSpellIndex >= 0:
      spellCastPauseIndex = newSpellIndex
      applySpellbookGlitch()
      level.summonSmokeClouds(self.global_transform.origin, 3, true, true)

func summonBroomSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(secretSweepActualCollisionShape.global_transform.origin, num_clouds, play_sound, is_glitchy)
  
var returning_to_save_point = 0
func tryDieToOffscreenCamera(delta):
  if getGameCamera().rightmost_x <= -999 or global.isEnteringRoom or global.pauseGame or physics_state == PhysicsState.GLITCH_DYING:
    return

  var curr_coords = level.getLevelManagerCoords() if not level.pacman_wrapping else null

  var repositioned_player = global_transform.origin
  var try_to_recover = false
  var DEATH_MARGIN = -1
  var ADJUSTMENT_MARGIN = -1

  if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN:
    global.roomEdgeVector = Vector3(1, 0, 0)
    repositioned_player.x = getGameCamera().rightmost_x + ADJUSTMENT_MARGIN
  if global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN:
    global.roomEdgeVector = Vector3(-1, 0, 0)
    repositioned_player.x = getGameCamera().leftmost_x - ADJUSTMENT_MARGIN
  DEATH_MARGIN = 1
  ADJUSTMENT_MARGIN = 1
  if global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN:
    global.roomEdgeVector = Vector3(0, 1, 0)
    repositioned_player.y = getGameCamera().topmost_y + ADJUSTMENT_MARGIN
    if transformation == TransformationState.BUBBLE:
      getBubbleCured()
  # only relocate back to safety if off bottom screen
  if global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
    global.roomEdgeVector = Vector3(0, -1, 0)
    # if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    #   repositioned_player.y = getGameCamera().botmost_y - ADJUSTMENT_MARGIN
    #   if not on_ground:
    #     landed()
    # else:
    try_to_recover = true

  if global.roomEdgeVector != null:
    if global.roomEdgeVector.x != 0:
      var yDiff = getGameCamera().topmost_y - getGameCamera().botmost_y
      global.memory["player_y_offset"] = (global_transform.origin.y - getGameCamera().botmost_y) / yDiff
      global.memory["prevYDiff"] = yDiff
      global.memory.erase("player_x_offset")
      global.memory.erase("prevXDiff")
    if global.roomEdgeVector.y != 0:
      var xDiff = getGameCamera().rightmost_x - getGameCamera().leftmost_x
      global.memory["player_x_offset"] = (global_transform.origin.x - getGameCamera().leftmost_x) / xDiff
      global.memory["prevXDiff"] = xDiff
      global.memory.erase("player_y_offset")
      global.memory.erase("prevYDiff")

    var next_room = transition.mapManager.getRoomPathAtCoords(curr_coords + global.roomEdgeVector) if curr_coords != null else null
    if next_room != null and not level.pacman_wrapping:
      transition.edge_fade_to(next_room)
      global.isEnteringRoom = true
      global.memory["player_flip_h"] = mySprite.flip_h
      global.memory["feather_jump_timer"] = feather_jump_timer
      global.memory["linear_velocity"] = linear_velocity
      global.memory["roomPath"] = level.getLevelName()
      global.pauseGame = true
      return
    else:
      global.memory.erase("player_y_offset")
      global.memory.erase("prevYDiff")
      global.memory.erase("player_x_offset")
      global.memory.erase("prevXDiff")
      if level.pacman_wrapping:
        DEATH_MARGIN = -1
        if global.roomEdgeVector == Vector3(1, 0, 0):
          global_transform.origin.x = getGameCamera().leftmost_x - DEATH_MARGIN
        if global.roomEdgeVector == Vector3(-1, 0, 0):
          global_transform.origin.x = getGameCamera().rightmost_x + DEATH_MARGIN
        if global.roomEdgeVector == Vector3(0, -1, 0):
          global_transform.origin.y = getGameCamera().topmost_y + DEATH_MARGIN
        if global.roomEdgeVector == Vector3(0, 1, 0):
          global_transform.origin.y = getGameCamera().botmost_y - DEATH_MARGIN
        global.roomEdgeVector = null
        return
      global.roomEdgeVector = null

    # otherwise you just can't go there...
    if try_to_recover:
      if not has_landed_since_recovering:
        global.memory["hp"] = 0
        tryDieToEnemy(delta, true, true, true)
        has_landed_since_recovering = true
        return
      returning_to_save_point = 1
      returning_recover_time = 0
      returnSound.play()
      pauseSelf = true
      ignorePhysics = true
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("returning")
      has_landed_since_recovering = false
      pauseAnimation = true
      physics_state = PhysicsState.GLITCH_RECOVERY
      if global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN:
        if global.memory.has("grav_direction") and global.memory["grav_direction"] < 0:
          global.memory["grav_direction"] = 1
          level.flipGravity()
    else:
      global_transform.origin = repositioned_player
  
func doTimeDilation(_delta):
  pass
  # var real_delta_multiplier = 8

  # var gtdm = global.time_dilation_multiplier
  # var low = 0.6
  # var high = 1.0
  # if Input.is_action_pressed("ui_select"):
  #   mySprite.material_override.set_shader_param("palette_cycle_speed", 4.0)
  #   gtdm = gtdm + (low - gtdm) * (delta*real_delta_multiplier)
  #   if stepify(gtdm, 0.01) == stepify(low, 0.01):
  #     gtdm = low
  #     mySprite.material_override.set_shader_param("palette_cycle_speed", 2.5)
      
  #   mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  # else:
  #   gtdm = gtdm + (high - gtdm) * (delta*real_delta_multiplier)
  #   mySprite.material_override.set_shader_param("enable_palette_cycle", false)
      
  #   if stepify(gtdm, 0.01) == stepify(high, 0.01):
  #     gtdm = high
  # global.time_dilation_multiplier = gtdm

func canIGetCaught():
  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_RECOVERY:
    return false
  
  return true
  
  
func processGlitchHurtRecovery(delta):
  if physics_state == PhysicsState.GLITCH_HURT:
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)
    glitchTilesAroundMe()

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      material.set_shader_param("shake_color_rate", 0.01 + (glitch_death_timer*.002))
    if glitch_death_timer >= 10:
      global.pauseGame = false
      global.pauseMoveInput = false
      self.feather_jump_timer = remembered_feather_jump_timer
      self.lv.y = remembered_y_vel
      self.linear_velocity.y = remembered_y_vel
      self.vv = remembered_y_vel
      self.on_ground = remembered_on_ground
      self.physics_state = PhysicsState.GLITCH_RECOVERY
      has_sweeped_glitch = false

    return false
  elif physics_state == PhysicsState.GLITCH_DYING:
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)
    glitchTilesAroundMe()

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      material.set_shader_param("shake_color_rate", 0.01 + (glitch_death_timer*.002))
    if glitch_death_timer >= 10:
      global.pauseGame = false
      level.tryToRespawn()
      if global.isEnteringRoom: return
      should_collide_horizontally = true
      should_collide_floor = true 
      should_collide_ceil = true
      self.feather_jump_timer = remembered_feather_jump_timer
      self.lv.y = remembered_y_vel
      self.linear_velocity.y = remembered_y_vel
      self.vv = remembered_y_vel
      self.on_ground = remembered_on_ground
      if grav < 0:
        self.global_transform.origin.y -= 1
      else:
        self.global_transform.origin.y += 1
      target_last_grounded_y = global_transform.origin.y
      global.memory["hp"] = global.memory["max_hp"]
      global.memory["hearts_recovering"] = true
      self.physics_state = PhysicsState.GLITCH_RECOVERY

    return false
  else:
    if glitch_death_timer != 0:
      glitch_death_timer += (delta*22)
      applyGlitchDeathEffects(abs(glitch_death_timer))
      if glitch_death_timer >= 20 and should_turn_on_glitch_screen_effects:
        level.glitchScreenEffect.visible = global.memory["canGlitchScreen"]
        should_turn_on_glitch_screen_effects = false
      if glitch_death_timer >= 40:
        musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
        level.glitchScreenEffect.visible = false
        glitch_death_timer = 0
        mySprite.material_override.set_shader_param("enable_glitch", false)
        mySprite.material_override.set_shader_param("enable_remove_skin_tone", false)
        self.physics_state = PhysicsState.NORMAL

    return true

onready var glitchCollisionShape = get_node("GlitchArea/CollisionShape")
func glitchTilesAroundMe(margin = 0.25, rand_timer = false):
  var lt = getLevelTiles()

  var shape = glitchCollisionShape
  var x = shape.global_transform.origin.x
  var y = shape.global_transform.origin.y
  var tb = y + shape.shape.extents.y/2*shape.scale.y + margin
  var bb = y - shape.shape.extents.y/2*shape.scale.y - margin
  var lb = x - shape.shape.extents.x/2*shape.scale.x - margin
  var rb = x + shape.shape.extents.x/2*shape.scale.x + margin
  
  lt.clearRandomTileTimers()
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      lt.rerandomizeTile(coords, lt.getRandomGlitchType(), rand_timer)

func applyGlitchDeathEffects(x):
  if global.memory["canChangeSongPitch"] and (x < 0 or x > 20):
    musicPlayer.changeSongPitch(abs(sin(x*.05)+.02))
  if x > 10:
    mySprite.material_override.set_shader_param("enable_glitch", self.physics_state == PhysicsState.GLITCH_RECOVERY)
    mySprite.material_override.set_shader_param("enable_remove_skin_tone", self.physics_state == PhysicsState.GLITCH_RECOVERY)

  var material = level.glitchScreenEffect.get_material()
  if material is ShaderMaterial:
    material.set_shader_param("shake_power", -.00005*pow(x-25, 2) + .005)
    material.set_shader_param("shake_color_rate", -.0001*pow(x-25, 2) + .005)

func tryRotateCamera(_delta):
  pass

func isOnSavePoint():
  if not global.memory.has("active_save_point_x"):
    return false
    
  var origin = self.global_transform.origin
  var x = origin.x
  var y = origin.y
  var z = origin.z
  return int(round(x)) == int(round(global.memory["active_save_point_x"])) and \
       int(round(y)) == int(round(global.memory["active_save_point_y"])) and \
       int(round(z)) == int(round(global.memory["active_save_point_z"]))

func nullify():
  glitchTickle(false)
  if global.memory["forget_me_not"]:
    level.displaySpellMessageText("unaffected")
    return

  level.displaySpellMessageText("lose magic")
  var did_erase = false
  global.memory["mp"] = 0
  self.can_cast_spell_timer = 0
  if global.memory.has("spellbookPage"):
    # intentional if weird, we treat the index as the int enum glitch_form
    for glitch_type in range(global.memory["permanent_spells"].size()):
      if not global.memory["permanent_spells"][glitch_type]:
        var found_index = global.memory["spellbookPage"].find(glitch_type)
        global.memory["spellbookPage"].erase(glitch_type)
        if found_index >= 0:
          did_erase = true 
  else:
    if glitch_form != global.GlitchForm.NORMAL:
      nullifySound.play()
      glitchTilesAroundMe(0.25, true)
      self.applyGlitch(global.GlitchForm.NORMAL, true)
    return

  if did_erase or glitch_form != global.GlitchForm.NORMAL:
    spellCastPauseIndex = 0
    nullifySound.play()
    self.applyGlitch(global.GlitchForm.NORMAL, true)    

# need this to have it available in the aniPlayer
func firstAdjustmentForNestingDolls():
  .adjustStuffForNestingDolls()
  
func loseBroom():
  if summonedBroom:
    broomStop()
  if global.memory["broom"]:
    mySprite.flip_h = not mySprite.flip_h
    summonFallenBroom(false, true)
    mySprite.flip_h = not mySprite.flip_h

var fish_broom_timer = 0
var fish_broom_time_limit = 2
var has_fish_broom = true
var bubble_timer = 0
var bubble_time_limit = 2
func processFishyLogic(delta):
  if not global.memory["zora_flippers"]:
    return

  var has_been_in_water = (is_touching_water and was_touching_water) # or (is_touching_sandstream and was_touching_sandstream)
  if transformation != TransformationState.FISHY and has_been_in_water and not truly_on_ground and not was_truly_on_ground and not recentlyJustPressedJump():
    getFishyInfected()
    gravitySound.play()
  elif transformation == TransformationState.FISHY:
    fishySprite.flip_h = mySprite.flip_h
    physics_vars.should_apply_gravity = pressingDown()
    glitchTilesAroundMe(-2)
    if (not is_touching_water and not was_touching_water):
      getFishyCured()
      gravitySound.play()
    if Input.is_action_pressed("sub_action_button") and has_fish_broom:
      bubble_timer += (delta*11)
      if bubble_timer >= bubble_time_limit:
        var bubble = bubbleRes.instance()
        bubble.is_horizontal = true
        bubble.horizontal_direction = 2
        bubble.can_purify = true
        if mySprite.flip_h:
          bubble.horizontal_direction = -2
        bubble.is_dark = true
        level.add_child(bubble)
        # bubble.mySprite.material_override.set_shader_param("enable_no_transparency", true)
        bubble.setAsParent(self)
        bubble.global_transform.origin = global_transform.origin
        bubble.global_transform.origin.x += bubble.horizontal_direction
        bubble.my_original_pos = bubble.global_transform.origin.y
        bubble.randomizeTargetPos()

        blinkSound.pitch_scale = rand_range(0.8, 1.2)
        blinkSound.play()
        bubble_timer = 0
    else:
      bubble_timer = bubble_time_limit
  elif fishySprite.visible and not aniPlayer.assigned_animation == "revertFromFishy":
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("revertFromFishy")
    aniPlayer.queue("land")


  # weird recovery
  var canAnimate = not pauseAnimation or aniPlayer.assigned_animation == "hookCaught"
  if transformation != TransformationState.FISHY and fishySprite.visible and canAnimate and not aniPlayer.assigned_animation == "revertFromFishy":
    getFishyCured()
  elif transformation == TransformationState.FISHY and not fishySprite.visible and canAnimate and not aniPlayer.assigned_animation == "transformToFishy":
    getFishyInfected()

# @override
func justPressedJump():
  return .justPressedJump() or (transformation == TransformationState.FISHY and Input.is_action_just_pressed("ui_up") and not pauseInput and not isTextboxPausingMe())


var bubble_temp_grav = 60
var bubble_temp_true_terminal_vel = 14
func getBubbleInfected():
  if transformation == TransformationState.BUBBLE:
    return
  pauseAnimation = true
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("tumbleRight", -1, 0.5)

  miniUpwardGust(false)
  loseBroom()
  transformation = TransformationState.BUBBLE
  on_ground = false
  gravitySound.play()
  level.flipGravity()
  # physics_vars.should_apply_gravity = true
  # bubble_temp_grav = grav
  # grav *= -1
  # bubble_temp_true_terminal_vel = true_terminal_vel
  # true_terminal_vel *= -1

func getBubbleCured():
  if transformation != TransformationState.BUBBLE:
    return
  transformation = TransformationState.NORMAL
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.queue("land")
  pauseAnimation = false

  getABroom()
  level.flipGravity()
  tickleSound.pitch_scale = 1.0
  tickleSound.play()
  var bubble = bubbleRes.instance()
  level.add_child(bubble)
  # bubble.mySprite.material_override.set_shader_param("enable_no_transparency", true)
  bubble.setAsParent(self)
  bubble.global_transform.origin = global_transform.origin
  bubble.my_original_pos = bubble.global_transform.origin.y
  bubble.bubbleStartPop()
  bubble.mySprite.pixel_size = 0.25
  # physics_vars.should_apply_gravity = true
  # should_collide_floor = true
  # should_collide_ceil = true
  # should_collide_horizontally = true
  # grav = bubble_temp_grav
  # true_terminal_vel = bubble_temp_true_terminal_vel

func restartMusic(): # maybe an animation uses this idk, dont delete it
  level.restartMusic()

func getFishyInfected():
  tryClearFallthroughCollisionSolid()
  if summonedBroom:
    summonFallenBroom(true, false, false)
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  loseBroom()
  if transformation == TransformationState.BUBBLE:
    level.flipGravity()
  transformation = TransformationState.FISHY
  aniPlayer.stop()
  aniPlayer.clear_queue()
  on_ground = false
  # if global.memory["zora_flippers"] == 1:
  #   musicPlayer.stopAll()
  #   aniPlayer.play("transformToFishy_first")
  #   global.memory["zora_flippers"] = 2
  #   dir = Vector3(0, 0, 0)
  #   lv.x = 0
  #   lv.y = 0
  #   linear_velocity.x = 0
  #   linear_velocity.y = 0
  #   hv = 0
  #   vv = 0
  #   pauseInput = true
  # else:
  #   aniPlayer.play("transformToFishy")
  aniPlayer.play("transformToFishy")
  pauseAnimation = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true
  fish_broom_timer = 0
  has_fish_broom = true
  
func getFishyCured():
  if transformation != TransformationState.FISHY:
    return
  can_broomerang_warp = true
  transformation = TransformationState.NORMAL
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("revertFromFishy")
  aniPlayer.queue("land")
  pauseAnimation = true
  if glitch_form == global.GlitchForm.FLOOR and not pressingDown():
    on_ground = true
  # pauseInput = true
  physics_vars.should_apply_gravity = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

func stopTransformationAni():
  pauseAnimation = false
  pauseInput = false

var chicken_timer = 0
var chicken_time_limit = 90
func processChickenLogic(delta):
  if transformation == TransformationState.CHICKEN:
    chickenSprite.flip_h = mySprite.flip_h
    glitchTilesAroundMe(-2)
    chicken_timer += (delta*11)
    if chicken_timer >= chicken_time_limit:
      getChickenCured()
      gravitySound.play()
  elif chickenSprite.visible and not aniPlayer.assigned_animation == "revertFromChicken":
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("revertFromChicken")
    aniPlayer.queue("land")

func getChickenInfected():
  chicken_timer = 0
  if summonedBroom:
    summonFallenBroom(true, false, false)
  # TODO(jaketrower): could probably DRY some of this stuff...
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  loseBroom()
  if transformation == TransformationState.BUBBLE:
    level.flipGravity()
  transformation = TransformationState.CHICKEN
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("transformToChicken")
  pauseAnimation = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true
  
func getChickenCured():
  if transformation != TransformationState.CHICKEN:
    return
  can_broomerang_warp = true
  transformation = TransformationState.NORMAL
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("revertFromChicken")
  aniPlayer.queue("land")
  pauseAnimation = true
  physics_vars.should_apply_gravity = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

var curse_timer = 0
var curse_time_limit = 10
func processCurseLogic(delta):
  if transformation == TransformationState.CURSED:
    glitchTilesAroundMe(-2)
    curse_timer += (delta*11)
    if curse_timer >= curse_time_limit:
      getCurseCured()
      gravitySound.play()

func getCurseInfected():
  curse_timer = 0
  if summonedBroom:
    summonFallenBroom(true, false, false)
  # TODO(jaketrower): could probably DRY some of this stuff...
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  loseBroom()
  if transformation == TransformationState.BUBBLE:
    level.flipGravity()
  transformation = TransformationState.CURSED
  
func getCurseCured():
  if transformation != TransformationState.CURSED:
    return
  transformation = TransformationState.NORMAL
  getABroom()

onready var ritualSound = get_node("Sounds/RitualSound")
var ritual_state_index = 0
func processAngelStatueRitual(_delta):
  if global.isEnteringRoom or global.isPauseMenuOpen:
    return
  if global.pauseGame or pauseInput or global.pauseMoveInput or pauseSelf:
    if ritual_state_index > 1:
      tickleSound.play()
    ritual_state_index = 0
    ritualSound.stop()
    return

  if ritual_state_index == len(global.correct_ritual):
    global.isPauseMenuOpen = true
    global.pauseGame = true
    level.uiLayer.pauseMenu.pauseMenuState = level.uiLayer.pauseMenu.PauseMenuState.SECRET_RITUAL
    level.uiLayer.pauseMenu.shouldUpdateMenuText = true
    level.uiLayer.pauseMenu.secretRitualOptionIndex = 0
    ritual_state_index = 0
    return
  
  if Input.is_action_just_pressed(global.correct_ritual[ritual_state_index]) and (on_ground or ritual_state_index == len(global.correct_ritual) - 1):
    if ritual_state_index > 0:
      ritualSound.stop()
      ritualSound.pitch_scale = 0.5 + (ritual_state_index * 0.1)
      ritualSound.play()
      glitchTickle(false)
    ritual_state_index += 1
    
  elif anyOtherRitualInputsDetected():
    if ritual_state_index > 1:
      tickleSound.play()
    ritual_state_index = 0
    ritualSound.stop()
    
  

func anyOtherRitualInputsDetected():
  var inputs = ["ui_left", "ui_right", "ui_up", "ui_down", "jump_button", "sub_action_button", "alt_action_button", "restart_key", "ui_start", "popup_menu", "left_button", "right_button"]
  for input in inputs:
    if Input.is_action_just_pressed(input):
      return true
  return false

func checkSolidTilesBeneathMe():
  var solid_tiles = getTilesBelow(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        return true
  return false

func checkSolidTilesOnMyRight(nearby = false):
  if nearby: global_transform.origin.x += 1
  var solid_tiles = getTilesRightOf(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        if nearby: global_transform.origin.x -= 1
        return true
  if nearby: global_transform.origin.x -= 1
  return false

func checkSolidTilesOnMyLeft(nearby = false):
  if nearby: global_transform.origin.x -= 1
  var solid_tiles = getTilesLeftOf(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        if nearby: global_transform.origin.x += 1
        return true
  if nearby: global_transform.origin.x += 1
  return false

func checkSolidTilesOnMe():
  var is_true = false
  global_transform.origin.y += 1
  if checkSolidTilesBeneathMe():
    is_true = true
  global_transform.origin.y += 1
  if checkSolidTilesBeneathMe():
    is_true = true
  global_transform.origin.y -= 2
  return is_true


onready var digSound2 = get_node("Sounds/DigSound2")
var dig_timer = 0
var dig_time_limit = 4
var dig_below_timer = 0
var dig_below_time_limit = 5
func processMoleLogic(delta):
  if transformation == TransformationState.UNDERGROUND:
    override_camera_y = global_transform.origin.y
    if not pressingDown():
      transformation = TransformationState.UNDERGROUND_RETURNING
    fastStepSound.pitch_scale = 0.8
    fastStepSound.volume_db = -15
    if not fastStepSound.is_playing():
      fastStepSound.play()
    can_update_last_grounded_pos = false
    glitchTilesAroundMe(-2.5)

    dig_timer += (delta*11)
    if dig_timer > dig_time_limit:
      summonSmokeClouds(1, true, true, 0)
      dig_timer = 0

    var has_solid_beneath = checkSolidTilesBeneathMe()
    if has_solid_beneath:
      global_transform.origin.y -= (2 * delta*11)
      if not checkSolidTilesBeneathMe():
        on_ground = true
        was_on_ground = true
        was_just_on_ground_timer = 0
        truly_on_ground = true
        was_truly_on_ground = true
        if not pressingMoveLeft() and not pressingMoveRight():
          dig_below_timer += (delta*11)
          if dig_below_timer >= dig_below_time_limit:
            dig_below_timer = 0
            global_transform.origin.y -= 2
            getMoleCured()
          else:
            global_transform.origin.y += (2 * delta*11)
        else:
          global_transform.origin.y += (2 * delta*11)
          dig_below_timer = 0
      else:
        dig_below_timer = 0

    if not checkSolidTilesOnMyLeft():
      global_transform.origin.x += 1
    if not checkSolidTilesOnMyRight():
      global_transform.origin.x -= 1

    if not checkSolidTilesOnMe():
      getMoleCured()
      if pressingMoveLeft():
        global_transform.origin.x += 1
      elif pressingMoveRight():
        global_transform.origin.x -= 1
      else:
        getMoleCured()

  elif transformation == TransformationState.UNDERGROUND_RETURNING:
    override_camera_y = global_transform.origin.y
    dig_below_timer = 0
    glitchTilesAroundMe(-2.5)
    fastStepSound.pitch_scale = 2.0
    fastStepSound.volume_db = -8
    if not fastStepSound.is_playing():
      fastStepSound.play()
    if pressingDown():
      transformation = TransformationState.UNDERGROUND
      digSound.play()
    else:
      if checkSolidTilesOnMe():
        global_transform.origin.y += (4 * delta*11)
      else:
        should_magic_jump = true
        self.vv = 10
        self.target_last_grounded_y = self.global_transform.origin.y
        self.global_transform.origin.y += 0.5
        self.on_ground = false
        self.truly_on_ground = false
        self.was_on_ground = false
        self.lv.y = self.vv
        self.linear_velocity.y = self.vv
        self.should_do_fallthrough_area_collision = false
        getMoleCured()
      
  else:
    var solid_tiles = getTilesBelow(getLevelTiles())
    var is_on_solid_ground = solid_tiles[0] != null or solid_tiles[1] != null or solid_tiles[2] != null
    if global.memory["mole_cricket"] and is_on_solid_ground and truly_on_ground and was_truly_on_ground and pressingDown() and not pressingMoveLeft() and not pressingMoveRight():
      dig_timer += (delta*11)
      mySprite.flip_h = not mySprite.flip_h
      glitchTickle()
      if dig_timer > dig_time_limit:
        tryClearFallthroughCollisionSolid()
        transformation = TransformationState.UNDERGROUND
        global_transform.origin.y -= 2
        summonSmokeClouds(3, true, true, 0)
        mySprite.visible = false
        loseBroom()
        digSound.play()
        physics_vars.should_apply_gravity = false
        should_collide_floor = false
        should_collide_ceil = false
        should_collide_horizontally = false
    else:
      dig_timer = 0

func getMoleCured():
  if transformation != TransformationState.UNDERGROUND and transformation != TransformationState.UNDERGROUND_RETURNING:
    return
  override_camera_y = null
  transformation = TransformationState.NORMAL
  global_transform.origin.y -= 2
  summonSmokeClouds(3, true, true, 0)
  digSound2.play()
  global_transform.origin.y += 2
  mySprite.visible = true
  can_update_last_grounded_pos = true
  physics_vars.should_apply_gravity = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true
  dig_timer = 0
  dig_below_timer = 0
  glitchTickle()
  getABroom()


var is_mushroom_prefected = false
func getMushroomInfected(): 
  tryClearFallthroughCollisionSolid()
  if is_mushroom_infected or is_mushroom_prefected:
    # glitchTickle(0)
    # getSmacked()
    return false
  is_mushroom_prefected = true
  loseBroom()

  musicPlayer.changeSongPitch(0.5)
  # mushroom_turn_timer = 0
  # physics_state = PhysicsState.GLITCH_HURT
  glitchTickle(0)
  getSmacked()
  # glitch_death_timer = 0
  global.pauseMoveInput = true
  pauseAnimation = true
  if mySprite.flip_h:
    mushroom_infection_direction = -1
  else:
    mushroom_infection_direction = 1
  yield(TempTimer.idle_frame(self), "timeout")
  
  mushroomSpriteAniPlayer.stop()
  mushroomSpriteAniPlayer.clear_queue()
  mushroomSpriteAniPlayer.play("sprout")

func finalizeMushroomInfection():
  pauseAnimation = false
  pauseSelf = false
  global.pauseMoveInput = false
  is_mushroom_prefected = false
  is_mushroom_infected = true

func getMushroomCured():
  if not is_mushroom_infected:
    return

  musicPlayer.changeSongPitch(1.0)
  returnSound.play()
  # mushroom_turn_timer = 0
  # physics_state = PhysicsState.GLITCH_HURT
  # glitchTickle(0)
  getSmacked()
  glitch_death_timer = 0
  global.pauseMoveInput = false 
  getABroom()
  is_mushroom_infected = false
  mushroomSpriteVisible.visible = false
  mushroomSpriteAniPlayer.stop()
  mushroomSpriteAniPlayer.clear_queue()
  mushroomSpriteAniPlayer.play("RESET")


var remembered_feather_jump_timer = 0
var remembered_y_vel = 0
var remembered_on_ground = false
# @override
# aka func ouchies():
func tryDieToEnemy(delta, should_glitch, should_kill_invis, should_immediately_die = false):
  touching_glitch_or_spikes = true
  tryToApplySpellAssist(global.GlitchForm.INVISIBLE)
  if transitioning or global.isEnteringRoom:
    return
  if isOnSavePoint():
    return
  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_RECOVERY:
    return

  if (glitch_form == global.GlitchForm.INVISIBLE or returning_to_save_point > 0)and not should_kill_invis:
    spawnSparkles(delta, true)
    glitchTickle(true)
    return

  if is_mushroom_infected:
    getABroom()
    for _i in range(5):
      spawnASpore(0, -1)
    var x_offset = 0
    if pressingMoveLeft():
      x_offset = 1
    elif pressingMoveRight():
      x_offset = -1
    global_transform.origin.x += x_offset
    global_transform.origin.y += 1
    var carcass = spawnACarcass()
    carcass.mushroomSprite.visible = true
    global_transform.origin.x -= x_offset
    global_transform.origin.y -= 1
    is_mushroom_infected = false

  if global.activeInteractor:
    global.activeInteractor.hideTextbox()
  global.activeInteractor = null
  var hurtSound_pitch_scale = 1.0
  if nesting_doll_state == global.NestingDoll.BABY:
    hurtSound_pitch_scale = rand_range(1.5, 2.0)
  elif nesting_doll_state == global.NestingDoll.MATRIARCH:
    hurtSound_pitch_scale = rand_range(0.4, 0.8)
  else:
    hurtSound_pitch_scale = rand_range(0.8, 1.5)

  if should_immediately_die:
    hurt3Sound.pitch_scale = hurtSound_pitch_scale
    hurt3Sound.volume_db = -18
    hurt3Sound.play()
  elif randi() % 3 == 0:
    hurt2Sound.pitch_scale = hurtSound_pitch_scale
    hurt2Sound.play()
  else:
    hurtSound.pitch_scale = hurtSound_pitch_scale
    hurtSound.play()
  bumpSound.pitch_scale = hurtSound_pitch_scale
  bumpSound.play()
  global.pauseGame = true
  global.pauseMoveInput = true
  global.memory["on_ground"] = on_ground
  # on_ground = false

  level.glitchScreenEffect.material.set_shader_param("shake_power", 0.01)
  level.glitchScreenEffect.material.set_shader_param("shake_color_rate", 0.01)
  mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  
  if global.memory["canChangeSongPitch"]:
    musicPlayer.changeSongPitch(rand_range(0.8, 1.5))

  global.memory["hp"] -= 1
  # if transformation == TransformationState.BUBBLE:
  #   getBubbleCured()
  #   physics_state = PhysicsState.GLITCH_HURT
  #   global.pauseGame = false
  #   global.pauseMoveInput = false
  #   glitchTickle(true)
  #   getSmacked()
  #   on_ground = false
  #   global.memory["on_ground"] = false
  #   lv.y = 0
  #   global.pauseMoveInput = false 
  #   glitch_death_timer = 10
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    global.memory["hp"] += 1
    physics_state = PhysicsState.GLITCH_HURT
    glitchTickle(true)
    getSmacked()
    glitch_death_timer = 0
    shroomAniPlayer.stop()
    shroomAniPlayer.clear_queue()
    shroomAniPlayer.play("RESET")
    shroomAniPlayer.queue("shrinkFromBig")
    shroomAniPlayer.queue("adjust")
    nesting_doll_state = global.NestingDoll.GRANDMA
    updateNestingDoll(nesting_doll_state)
    global.pauseMoveInput = false
  elif global.memory["hp"] <= 0 or should_immediately_die:
    actuallyProcessDeath(should_glitch)
    getSmacked()
  else:
    physics_state = PhysicsState.GLITCH_HURT
    glitchTickle(true)
    getSmacked()
    glitch_death_timer = 0
    global.pauseMoveInput = false 

    if global.memory["hp"] <= 1:
      summonSmokeClouds(3, true, true, -1)
      enchantedBagSpriteVisible.visible = false
    # self.nullify()
  remembered_feather_jump_timer = self.feather_jump_timer
  remembered_y_vel = lv.y
  remembered_on_ground = on_ground

func actuallyProcessDeath(should_glitch):
  if transformation == TransformationState.FISHY:
    getFishyCured()
  if transformation == TransformationState.UNDERGROUND:
    getMoleCured()
  if transformation == TransformationState.CHICKEN:
    getChickenCured()
  global.incrementLevelZoneDeaths()
  global.memory["hp"] = 0
  self.textBox.hideTextbox()
  global.isRespawning = true
  physics_state = PhysicsState.GLITCH_DYING
  glitch_death_timer = 0
  # TODO(jaketrower): RESPECT MORE
  if global.memory["canGlitchScreen"] and should_glitch:
    level.glitchScreenEffect.visible = true
  if summonedBroom:
    broomStop()
  tryClearFallthroughCollisionSolid()

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var is_smacked = false
var smack_timer = 0
var smack_time_limit = 4
func getSmacked(_broom_origin = Vector3(0, 0, 0), _silently = false):
  mySprite.material_override.set_shader_param("time_influence", time_influence)
  mySprite.material_override.set_shader_param("y_div", y_div)
  mySprite.material_override.set_shader_param("normal_offset", normal_offset)
  smack_timer = 0
  is_smacked = true
  pauseSelf = true

var shroomRes = preload("res://sceneObjects/Enemies/BasicShroomEnemy.tscn")
var summonedShroom = null
func summonSporeShroom():
  # return
  if summonedShroom and summonedShroom.get_ref():
    summonedShroom.get_ref().queue_free()
    
  var newShroom = shroomRes.instance()
  level.add_child(newShroom)
  newShroom.setAsParent(self)
  newShroom.global_transform.origin = self.global_transform.origin
  if mySprite.flip_h:
    newShroom.global_transform.origin.x -= 2
    newShroom.walk_direction.x = -1
  else:
    newShroom.global_transform.origin.x += 2
    newShroom.walk_direction.x = 1
  summonedShroom = weakref(newShroom)

func tumbleFall(direction):
  if physics_state == PhysicsState.GLITCH_DYING:
    return

  aniPlayer.stop()
  aniPlayer.clear_queue()
  var x_val = 10
  playBounce("grow")
  if direction:
    aniPlayer.play("tumbleLeft")
    x_val *= -1
  else:
    aniPlayer.play("tumbleRight")
    x_val *= 1

  physics_state = PhysicsState.BEING_TOSSED
  pauseAnimation = true
  should_collide_floor = true
  can_collide_with_floor = true
  hv = Vector3(x_val, 0, 0)
  dir = Vector3(x_val, 0.0, 0.0)
  linear_velocity.x = x_val
  lv.x = x_val
  var jump_val = 5
  vv = jump_val
  linear_velocity.y = jump_val
  lv.y = jump_val

  yield(TempTimer.idle_frame(self), "timeout")
  fall_timer = fall_time_max - 5

func processBagLogic(_delta):
  pass

var force_a_sweep = false
func processBroomLogic(delta):
  if pauseInput and summonedBroom == null:
    return
  if transformation == TransformationState.FISHY:
    return
  if global.pauseMoveInput or aniPlayer.assigned_animation == "getItem":
    return
  if interactionArea.has_activated_something and not force_a_sweep:
    return


  var can_throw_broom = global.memory["broomerang"]

  var aa = aniPlayer.assigned_animation
  if (aa == "broomSmackGlitch" or aa == "sweepFloor") and not aniPlayer.is_playing():
    if global.memory["multi_broom"]:
      summonedBroom = null
    else:
      broomStop()

  if (global.pauseMoveInput and global.activeInteractor == null) or physics_state == PhysicsState.BEING_TOSSED or transformation == TransformationState.UNDERGROUND or transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.CHICKEN:
    if Input.is_action_just_pressed("sub_action_button"):
      noBroomSound.play()
    return

  var which_broom_attack = 1
  if not global.memory["broom"]:
    if nesting_doll_state == global.NestingDoll.BABY and Input.is_action_just_pressed("sub_action_button") and Input.is_action_pressed("ui_down"):
      summonSporeShroom()
    elif global.memory["has_gotten_broom"] > 0 and Input.is_action_just_pressed("sub_action_button") and not noBroomSound.is_playing() and nesting_doll_state == global.NestingDoll.GRANDMA:
      # if fallenBroomRef.get_ref() and not fallenBroomRef.get_ref().returning:
      #   var distance = global_transform.origin.distance_to(fallenBroomRef.get_ref().global_transform.origin)
      #   if distance >= 2:
      #     fallenBroomRef.get_ref().returning = true
      noBroomSound.play()
    return

  if not summonedBroom and is_in_broom_cooldown:
    broom_cooldown_timer += (delta*22)
    if broom_cooldown_timer >= broom_cooldown_time_limit:
      broom_cooldown_timer = 0
      is_in_broom_cooldown = false
      which_broom_attack = 1

  if (Input.is_action_just_pressed("sub_action_button") or force_a_sweep) and not summonedBroom and not pauseSelf and not aa == "sweepFloor" and not global.hasGottenLevelGeode: # and (global.activeInteractor == null or global.activeInteractor.is_tiny):
    doBroomAttack(which_broom_attack)
    if linear_velocity.y < 0:
      linear_velocity.y = 0
  elif Input.is_action_just_pressed("sub_action_button") and summonedBroom and not pauseSelf and not global.pauseGame:
    if can_throw_broom:
      summonedBroom.queue_free()
      broomStop()
      if not on_ground:
        var amt = 2
        self.vv = amt
        self.linear_velocity.y = amt
        self.lv.y = amt
      summonFallenBroom(true)
    elif on_ground or was_walking_into_wall:
      summonedBroom.queue_free()
      broomStop()
      doBroomAttack(1)
  # elif Input.is_action_pressed("sub_action_button") and not summonedBroom and not pauseSelf and on_ground and is_pressing_horizontal_input:
  #   hitStuff(delta)
  # elif aniPlayer.assigned_animation == "sweepFloor" and isKindOfOnGround():
  #   vv = 0
  #   lv.y = 0
  #   linear_velocity.y = 0
  #   hitStuff(delta)
  #   # global_transform.origin.y = last_grounded_pos.y
  #   if can_throw_broom and Input.is_action_just_pressed("sub_action_button"):
  #     broomStop()
  #     summonFallenBroom(true)
  force_a_sweep = false

var SOFT_SAND_TOP_TILE = 275
func doBroomAttack(which_broom_attack):
  aniPlayer.stop()
  aniPlayer.clear_queue()
  # TODO(jaketrower): has just turned around
  # if Input.is_action_pressed("ui_down") and isKindOfOnGround():
  #   aniPlayer.play("sweepFloor")
  #   which_broom_attack = 0
  #   summonSporeShroom()
  var is_turn_around_attack = false # (is_pressing_horizontal_input and ((mySprite.flip_h and lv.x > -1) or (not mySprite.flip_h and lv.x < 1)))
  if force_a_sweep:
    aniPlayer.play("broomSmack")
  elif is_turn_around_attack: #is_in_broom_cooldown or is_turn_around_attack:
    mySprite.flip_h = pressingMoveLeft() and not pressingMoveRight()
    aniPlayer.play("broomSmack2")
    which_broom_attack = 2
  else:
    aniPlayer.play("broomSmack")
  pauseAnimation = true

  is_in_broom_cooldown = false
  broom_cooldown_timer = 0
  # elif glitch_form == global.GlitchForm.FEATHER:
  #   broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
  # velocity_dampener = 2.0
  if on_ground:
    walk_speed = 0
    feather_glitch_walk_speed = 0
    invisible_glitch_walk_speed = 0
  global.incrementLevelZoneSweeps()
  jump_press_timer = jump_press_broom_time_limit
  if which_broom_attack > 0:
    pauseInput = true
    summonedBroom = summonedBroomRes.instance()
    level.add_child(summonedBroom)
    if which_broom_attack == 2:
      summonedBroom.aniPlayer.stop()
      summonedBroom.aniPlayer.clear_queue()
      summonedBroom.aniPlayer.play("broomSmack2")
      summonedBroom.broom_active_time_limit = 15
      is_in_broom_cooldown = false
    if smacked_npc != null or (global.activeInteractor != null and is_instance_valid(global.activeInteractor)):
      if smacked_npc == null:
        smacked_npc = global.activeInteractor.textboxParent
      summonedBroom.smacked_npc = smacked_npc
    summonedBroom.my_broom_owner = self
    adjustSummonedBroomSpritePosition()
  
  # if global.memory["debug_broom"]:
  #   var x = global_transform.origin.x
  #   var y = global_transform.origin.y
  #   var z = global_transform.origin.z
  #   if mySprite.flip_h:
  #     if checkSolidTilesOnMyLeft(true):
  #       levelTiles.removeTile(Vector3(x - 3, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x - 4, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x - 3, y - 1, z), false)
  #       levelTiles.removeTile(Vector3(x - 4, y - 1, z), false)
  #     else:
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 3, y + 0, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 4, y + 0, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 3, y - 1, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 4, y - 1, z), false)
  #   else:
  #     if checkSolidTilesOnMyRight(true):
  #       levelTiles.removeTile(Vector3(x + 1, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x + 2, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x + 1, y - 1, z), false)
  #       levelTiles.removeTile(Vector3(x + 2, y - 1, z), false)
  #     else:
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 1, y + 0, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 2, y + 0, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 1, y - 1, z), false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 2, y - 1, z), false)

var spore_spawn_timer = 0
var spore_spawn_time_limit = 15
onready var inventorySound = get_node("Sounds/InventorySound")
onready var pauseSound = get_node("Sounds/PauseSound")
onready var unpauseSound = get_node("Sounds/UnpauseSound")
func processMushroomLogic(delta):
  mushroomSpriteVisible.visible = is_mushroom_infected
  # should_collide_horizontally = not is_mushroom_infected # careful! interacts with processMoleLogic
  if not is_mushroom_infected:
    return

  var my_y = global_transform.origin.y
  global_transform.origin.y += 1
  var solid_tiles = getTilesBelow(getLevelTiles())
  if solid_tiles[0] != null or solid_tiles[1] != null or solid_tiles[2] != null:
    # my_y += delta*11
    glitchTickle()
  global_transform.origin.y = my_y
  
  spore_spawn_timer += (delta*22)
  if spore_spawn_timer >= spore_spawn_time_limit:
    spore_spawn_timer = 0
    spawnASpore()
    # sporeSound.pitch_scale = rand_range(2.0, 2.8)
    # sporeSound.play()

  mushroomSpriteVisible.frame = mushroomSpriteAnimated.frame
  mushroomSpriteVisible.translation = mushroomSpriteAnimated.translation
  mushroomSpriteVisible.scale = mushroomSpriteAnimated.scale
  mushroomSpriteVisible.flip_h = false
  if mySprite.flip_h:
    mushroomSpriteVisible.flip_h = true
    mushroomSpriteVisible.translation.x *= -1

var should_flip = false
# @override
func processHorizontalInputs(delta):
  .processHorizontalInputs(delta)
  if is_mushroom_infected:
    should_flip = not should_flip
    var turning_left = mushroom_infection_direction == 1 and Input.is_action_pressed("ui_left")
    var turning_right = mushroom_infection_direction == -1 and Input.is_action_pressed("ui_right")
    if turning_left or turning_right:
      mushroom_turn_timer += (delta*22) if on_ground else mushroom_turn_time_limit
      if should_flip: mySprite.flip_h = not mySprite.flip_h
      if mushroom_turn_timer >= mushroom_turn_time_limit:
        mushroom_turn_timer = 0
        mushroom_infection_direction *= -1
    else:
      mushroom_turn_timer = 0

func adjustSummonedBroomSpritePosition():
  var xAddition = 0
  var yAddition = 0
  if summonedBroom.aniPlayer.assigned_animation == "broomSmack" or summonedBroom.aniPlayer.assigned_animation == "sweepWall":
    xAddition = .875
    yAddition = .625
  elif summonedBroom.aniPlayer.assigned_animation == "broomSmack2":
    xAddition = .4
    yAddition = 0

  broomSpriteVisible.visible = false
  if mySprite.flip_h:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x - xAddition
    summonedBroom.rotation_degrees = Vector3(0, 180, 0)
  else:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x + xAddition
    summonedBroom.rotation_degrees = Vector3(0, 0, 0)

  if self.grav < 0:
    summonedBroom.rotation_degrees.x = 180
    yAddition *= -1
    # yAddition -= 3.146
  else:
    summonedBroom.rotation_degrees.x = 0
  summonedBroom.rotation_degrees.z = spriteContainer.rotation_degrees.z

  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + yAddition
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func shouldAirHaveFriction():
  return summonedBroom == null and .shouldAirHaveFriction()

# var broom_flip_h = false
func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.scale = broomSpriteAnimated.scale
  secretSweepActualCollisionShape.translation = secretSweepCollisionShape.translation
  broomSpriteVisible.flip_h = false
  if not can_broomerang_warp:
    broomSpriteVisible.material_override.set_shader_param("target_palette", global.black_player_palette)
  else:
    broomSpriteVisible.material_override.set_shader_param("target_palette", global.player_red_palette)
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1
    secretSweepActualCollisionShape.translation.x *= -1
  if aniPlayer.assigned_animation != "broomSmackGlitch":
    if false: # global.getLevelZoneThing("crystal_geode"):
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", true)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", true)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", true)
    else:
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", false)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", false)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", false)
    
  if physics_state == PhysicsState.OCCUPIED:
    broomSpriteVisible.visible = false
    if nesting_doll_state == global.NestingDoll.GRANDMA:
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)
  elif summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif global.memory["broom"] and not isHoldingMultiBroom():
    broomSpriteVisible.visible = true
    if nesting_doll_state == global.NestingDoll.GRANDMA:
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  else:
    broomSpriteVisible.visible = false
    if nesting_doll_state == global.NestingDoll.GRANDMA and not isHoldingMultiBroom():
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)


func processBagRenderLogic(_delta):
  enchantedBagSpriteVisible.frame = enchantedBagSpriteAnimated.frame
  enchantedBagSpriteVisible.translation = enchantedBagSpriteAnimated.translation
  enchantedBagSpriteVisible.flip_h = false
  if mySprite.flip_h:
    enchantedBagSpriteVisible.flip_h = true
    enchantedBagSpriteVisible.translation.x *= -1
    
  # if summonedBroom != null:
  #   adjustSummonedBroomSpritePosition()
  if global.memory["hp"] > 1:
    enchantedBagSpriteVisible.visible = true
  else:
    enchantedBagSpriteVisible.visible = false


func processPoisonWaterLogic(delta):
  var is_touching_poison_water = false # is_touching_water and touched_water_area != null and touched_water_area.get_node("..").is_poison

  if is_touching_poison_water:
    if glitch_form == global.GlitchForm.INVISIBLE:
      tryDieToEnemy(delta, true, false)
    else:
      if poison_timer == 0 or unpoison_timer > 0:
        poisonWaterSound.play()
      elif reversePoisonWaterSound.is_playing():
        # TODO(jaketrower): Could be put in a function
        var playback_position = reversePoisonWaterSound.get_playback_position()
        var sound_length = reversePoisonWaterSound.stream.get_length()
        poisonWaterSound.play(sound_length - playback_position)
        reversePoisonWaterSound.stop()
      # If trying to jump out of water a lot... poison harder!
      if unpoison_timer > 0:
        poison_timer += (delta * 220)
        unpoison_timer = 0
      poison_timer += (delta*22)
      if poison_timer > 7:
        glitchTickle(0)
      if poison_timer >= poison_time_limit:
        tryDieToEnemy(delta, true, false)
        poison_timer = 0
        poisonWaterSound.stop()

  if (not is_touching_poison_water or glitch_form == global.GlitchForm.INVISIBLE) and poison_timer > 0:
    if poisonWaterSound.is_playing():
      # TODO(jaketrower): Could be put in a function
      var playback_position = poisonWaterSound.get_playback_position()
      var sound_length = poisonWaterSound.stream.get_length()
      reversePoisonWaterSound.play(sound_length - playback_position)
      poisonWaterSound.stop()
    # decrease more slowly than it increases... toxic
    unpoison_timer += (delta * 22)
    if unpoison_timer >= unpoison_time_limit:
      poison_timer -= (delta * 22)
      if poison_timer <= 0:
        poison_timer = 0
        level.glitchScreenEffect.visible = false
        musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
        reversePoisonWaterSound.stop()

  if poison_timer > 0:
    level.glitchScreenEffect.visible = global.memory["canGlitchScreen"]
    level.glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (poison_timer*.0005))
    musicPlayer.changeSongPitch(abs(sin(poison_timer*.05)+.02))
  if poison_timer < 0:
    poison_timer = 0
    level.glitchScreenEffect.visible = false
    musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
    reversePoisonWaterSound.stop()
    
var has_landed_since_recovering = true
# @override
func landed():
  .landed()
  if not (is_mushroom_infected or is_mushroom_prefected):
    has_landed_since_recovering = true
  has_broom_flown = not global.memory["broom"]
  if has_broom_flown:
    has_landed_since_last_flight = true
  num_spell_casts_used = 0
  target_last_grounded_y = global_transform.origin.y
  broom_cooldown_timer = 0
  is_in_broom_cooldown = false
  if physics_state != PhysicsState.BEING_TOSSED and \
     physics_state != PhysicsState.OCCUPIED and \
     transformation != TransformationState.FISHY and \
     not is_pressing_horizontal_input and not was_pressing_horizontal_input:
    summonSmokeClouds(1, false, false, 1)

  # TODO(jaketrower): Uncomment out for final dungeon level
  if nesting_doll_state == global.NestingDoll.MOM:
    var lt = getLevelTiles()
    var original_y = global_transform.origin.y
    for _i in range(4):
      var tiles = getTilesBelow(lt)
      if tiles[0] != null:
        lt.rerandomizeTile(tiles[0], lt.getRandomGlitchType())
      if tiles[1] != null:
        lt.rerandomizeTile(tiles[1], lt.getRandomGlitchType())
      if tiles[2] != null:
        lt.rerandomizeTile(tiles[2], lt.getRandomGlitchType())
      global_transform.origin.y -= 1
    global_transform.origin.y = original_y

# @override
func playJumpSound():
  .playJumpSound()
  global.incrementLevelZoneJumps()
  # grannyLandSound.pitch_scale = rand_range(0.6, 1.0)
  # grannyLandSound.play()

func faceDown():
  pass # mySprite.faceDown()

var gimme_mini_crystal_cubes = 0
var gimme_mini_crystal_cubes_timer = 0
var gimme_mini_crystal_cubes_time_limit = 5
func giveMeMiniCrystalCubes(how_many):
  gimme_mini_crystal_cubes = how_many
  gimme_mini_crystal_cubes_timer = 0

var lose_mini_crystal_cubes = 0
var lose_mini_crystal_cubes_timer = 0
var lose_mini_crystal_cubes_time_limit = 5
func loseMiniCrystalCubes(how_many):
  lose_mini_crystal_cubes = how_many
  lose_mini_crystal_cubes_timer = 0

var fallenBroomRef = null
func iFellFlat():
  summonFallenBroom(false, true)

func summonFallenBroom(was_thrown, should_die_on_land = false, should_return = true):
  if not global.memory["broom"] or not broomSpriteVisible.visible:
    return null
  broomSpriteVisible.visible = false
  summonSmokeClouds(3, false, false)
  var fallenBroom = fallenBroomRes.instance()
  level.add_child(fallenBroom)
  if smacked_npc != null:
    fallenBroom.smacked_npc = smacked_npc
  fallenBroom.should_die_on_land = should_die_on_land
  fallenBroom.should_return = should_return
  fallenBroom.global_transform.origin = self.global_transform.origin
  fallenBroom.global_transform.origin.x += -1 if mySprite.flip_h else 1
  fallenBroom.walk_direction = Vector2(-1 if mySprite.flip_h else 1, 0)
  if grav > 0:
    fallenBroom.global_transform.origin.y += 2
  if was_thrown:
    global.incrementLevelZoneSweeps()
    fallenBroom.grav = 1
    fallenBroom.projectile = true
    # if global.memory["magic_lantern"]:
    #   fallenBroom.should_collide_ceil = false
    #   fallenBroom.should_collide_floor = false
    #   fallenBroom.should_collide_horizontally = false
    fallenBroom.global_transform.origin.y -= 1
    # if global.memory["broom_flight"] and not has_broom_flown and not on_ground:
    #   fallenBroom.global_transform.origin.y = self.global_transform.origin.y
    #   fallenBroom.taking_the_player_with_me = true
    fallenBroom.true_terminal_vel = 0
    fallenBroom.walk_speed *= 3
    fallenBroom.get_node("BroomSound").play()
    var x_direction = 0
    if Input.is_action_pressed("ui_left"):
      x_direction = -1
    elif Input.is_action_pressed("ui_right"):
      x_direction = 1
    if Input.is_action_pressed("ui_up"):
      fallenBroom.walk_speed *= .7
      fallenBroom.walk_direction = Vector2(x_direction, 1)
      fallenBroom.just_pressed_jump = true
      fallenBroom.pressing_jump = true
      fallenBroom.grav = 0
      fallenBroom.jump_force = 12.0 if x_direction == 0 else 12 * .7
      fallenBroom.thrown_direction.y = 1
    elif Input.is_action_pressed("ui_down"):
      fallenBroom.walk_speed *= .7
      fallenBroom.walk_direction = Vector2(x_direction, -1)
      fallenBroom.grav = 600
      fallenBroom.true_terminal_vel = 12.0 if x_direction == 0 else 12 * .7
      fallenBroom.thrown_direction.y = -1
    elif x_direction != 0:
      fallenBroom.walk_direction.x = x_direction
    fallenBroom.thrown_direction.x = fallenBroom.walk_direction.x
  global.memory["broom"] = false

  if (fallenBroom.walk_direction.x < 0 or mySprite.flip_h) and was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse", -1, 2.0)
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin", -1, 2.0)
  elif (fallenBroom.walk_direction.x < 0 or mySprite.flip_h) and not was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
  elif (fallenBroom.walk_direction.x > 0  or not mySprite.flip_h) and was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin", -1, 2.0)
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse", -1, 2.0)
  else:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
  fallenBroomRef = weakref(fallenBroom)
  return fallenBroomRef

func iJustPressedDown():
  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground:
    .iJustPressedDown() # super
    return

  on_ground = false
  should_do_fallthrough_area_collision = false
  tryClearFallthroughCollisionSolid()

var is_active = true
func setGlobalMemoryOfHasSpoken(_set_vars = false):
  # no-op for now
  pass
func idleTalk():
  # no-op for now
  pass
func appendNextTextCharacter():
  # no-op for now
  pass

# used for positioning secretSweepActualArea
onready var secretSweepArea = get_node("SpriteContainer/SecretSweepArea")
onready var secretSweepCollisionShape = get_node("SpriteContainer/SecretSweepArea/CollisionShape")
# used for actually sweeping up glitch tiles
onready var secretSweepActualArea = get_node("SpriteContainer/SecretSweepAreaActual")
onready var secretSweepActualCollisionShape = get_node("SpriteContainer/SecretSweepAreaActual/CollisionShape")

func swordClank(play_sound = true):
  if summonedBroom:
    broomStop()
  getSmacked()
  if play_sound:
    broomSound.play()

func getItemFailsafe():
  if global.activeInteractor == null:
    physics_state = PhysicsState.NORMAL
    pauseAnimation = false
    pauseSelf = false
    global.pauseMoveInput = false
    global.pauseGame = false
