extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var broomSound = get_node("Sounds/BroomSound")
onready var noBroomSound = get_node("Sounds/NoBroomSound")
onready var blinkSound = get_node("Sounds/BlinkSound")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var returnSound = get_node("Sounds/ReturnSound")
onready var grannyLandSound = get_node("Sounds/GrannyLandSound")
onready var poisonWaterSound = get_node("Sounds/PoisonWaterSound")
onready var reversePoisonWaterSound = get_node("Sounds/PoisonWaterReverseSound")
onready var footstepSound = get_node("Sounds/FootstepSound")
onready var digSound = get_node("Sounds/DigSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")
onready var mpNumSprite = get_node("MPNumSprite")
onready var mpNumSprite2 = get_node("MPNumSprite/MPNumSprite2")
onready var mushroomSprite = get_node("MushroomSprite")
onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite")

var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
# var spriteSheetFeather = preload("res://assets/player_sheet_old_feather.png")
var summonedBroom = null
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 10

onready var spriteContainer = get_node("SpriteContainer")
onready var broomSpriteAnimated = get_node("SpriteContainer/Sprite3DBroomAnimated")

onready var enchantedBagSpriteAnimated = get_node("SpriteContainer/Sprite3DBagAnimated")
onready var enchantedBagSpriteVisible = get_node("SpriteContainer/Sprite3DBagVisible")

onready var textContainer = get_node("TextContainer")
onready var textBox = get_node("TextContainer/TextBox")

onready var interactPromptSprite = get_node("InteractPrompt")

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

var remembered_walk_speed = 7
var remembered_feather_glitch_walk_speed = 6
var remembered_invisible_glitch_walk_speed = 5
func _ready():
  set_process(true)
  set_physics_process(true)
  if pauseMenu: pauseMenu.hide()

  remembered_walk_speed = walk_speed
  remembered_feather_glitch_walk_speed = feather_glitch_walk_speed
  remembered_invisible_glitch_walk_speed = invisible_glitch_walk_speed
  broomSpriteAnimated.get_material_override().set_shader_param("opacity", 1.0)

# @override
func alignMySprite():
  var pixelSize = 0.125
  if spriteContainer:
    spriteContainer.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    spriteContainer.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + spriteYAlignment

func tryPlayFootstepSound():
  if not (pressingMoveLeft() or pressingMoveRight()):
    return
  if glitch_form == global.GlitchForm.FLOOR and not truly_on_ground:
    sporeSound.play()
    return
  footstepSound.play()

func applyNextGlitch():
  applyGlitch(global.getNextGlitch(glitch_form))
  
func applyObeliskGlitch(glitch, add_spell_to_grimoire = true):
  applyGlitch(glitch, false)
  if add_spell_to_grimoire and global.memory.has("spellbookPage"):
    if not global.memory["spellbookPage"].has(glitch):
      global.memory["spellbookPage"].push_back(glitch)

# used in AnimationPlayer.broomSmackGlitch
func actuallyApplySpellbookGlitch():
  if not global.memory.has("spellbookPage") or global.memory["spellbookPage"].size() <= 0:
    return
  var new_spellbook = []
  var old_spellbook = global.memory["spellbookPage"]
  var glitch_type = old_spellbook[spellCastPauseIndex]
  var i = spellCastPauseIndex + 1
  while new_spellbook.size() < old_spellbook.size():
    if i >= old_spellbook.size():
      i = 0
    new_spellbook.append(old_spellbook[i])
    i += 1
  applyGlitch(glitch_type)
  applyObeliskGlitch(glitch_type, false)
  global.memory["spellbookPage"] = new_spellbook
    
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
    return
  nullifySound.stop()
  if not notPlaySound:
    if glitch == self.glitch_form:
      rechargeSound.play()
    else:
      transformSound.pitch_scale = rand_range(0.8, 1.2)
      transformSound.play()
  global.memory["current_glitch"] = glitch

  mySprite.material_override.set_shader_param("opacity", 1.0)
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

func floorGlitch():
  level.displaySpellMessageText("air walk")
  glitch_form = global.GlitchForm.FLOOR
  level.floorGlitch()
  changeSpriteColorPalette(global.red_palette)
  # mySprite.setBugCatcherCostume()

func featherGlitch():
  level.displaySpellMessageText("feather fall")
  glitch_form = global.GlitchForm.FEATHER
  level.featherGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.green_dungeon_palette)
  # mySprite.setMothCostume()
  # mySprite.material_override.set_shader_param("texture_albedo", spriteSheetFeather)

func ladderGlitch():
  level.displaySpellMessageText("ladder")
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.yellow_player_palette)
  # mySprite.setLuckyCatCostume()

func invisibleGlitch():
  level.displaySpellMessageText("ghost")
  glitch_form = global.GlitchForm.INVISIBLE
  level.invisibleGlitch()
  changeSpriteColorPalette(global.black_palette)
  # mySprite.get_material_override().set_shader_param("opacity", 0.9)
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
  # if (broom_flip_h and Input.is_action_pressed("ui_right")) or \
  #    (not broom_flip_h and Input.is_action_pressed("ui_left")):
  #   return false

  return Input.is_action_pressed("sub_action_button") and summonedBroom == null# or \
         #(is_mushroom_infected and mushroom_turn_timer > 0) or pressingDown()
  
func isWalkingIntoWall():
  if summonedBroom != null:
    return was_walking_into_wall
  else:
    return .isWalkingIntoWall() # super

func sayThis(message):
  textBox.text_final = message
  textBox.tinify()
  textBox.interact()

var returning_recover_time = 0
var returning_recover_time_limit = 3
func _process(delta):
  # ._process(delta) #NOTE: this super method is called automatically 
  # https://github.com/godotengine/godot/issues/6500
  pauseInput = summonedBroom != null or global.pauseMoveInput

  if Input.is_action_just_pressed("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
  
  delta = delta * global.time_dilation_multiplier

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
  if not processGlitchHurtRecovery(delta):
    return

  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.IGNORE_PHYSICS:
    return
  processBroomRenderLogic(delta)
  processBagRenderLogic(delta)
  processCastingLogic(delta)
  processBroomLogic(delta)
  processBagLogic(delta)
  processMushroomLogic(delta)
    
  # doTimeDilation(real_delta)

  if can_cast_spell_timer < can_cast_spell_time_limit:
    can_cast_spell_timer += (delta*22)

  # if Input.is_action_just_pressed("action_button") and can_cast_spell_timer >= can_cast_spell_time_limit:
  #   applySpellbookGlitch()
  if Input.is_action_just_pressed("debug_glitch_button"):
    applyNextGlitch()
    
  tryDieToOffscreenCamera(delta)
      
  if gimme_mini_crystal_cubes > 0:
    gimme_mini_crystal_cubes_timer += (delta*22)
    if gimme_mini_crystal_cubes_timer >= gimme_mini_crystal_cubes_time_limit:
      gimme_mini_crystal_cubes_timer = 0
      gimme_mini_crystal_cubes -= 1
      var newCrystalCube = miniCubeCrystal.duplicate()
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

  if global.memory.has("anna_mode") and global.memory["anna_mode"]:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)
    broomSpriteVisible.material_override.set_shader_param("texture_albedo", broomSpriteSheetTiny)
    if global.memory.has("blue_mode") and global.memory["blue_mode"]:
      mySprite.material_override.set_shader_param("target_palette", global.base_palette)
  elif global.memory.has("blue_mode") and global.memory["blue_mode"]:
    mySprite.material_override.set_shader_param("target_palette", global.NES_palette)
  

func unsmack():
  smack_timer = 0
  is_smacked = false
  if not global.hasLevelGeodeBeenSmacked:
    pauseSelf = false
  mySprite.material_override.set_shader_param("time_influence", 3)
  mySprite.material_override.set_shader_param("y_div", 2.3)
  mySprite.material_override.set_shader_param("normal_offset", .02)

var pausingFromSpellCasting = false
var tryPauseFromSpellCasting = false
var spellCastPauseIndex = 0
var spellCastPauseTimer = 0
var spellCastPauseTimeLimit = 0
var num_spell_casts_used = 0
var spellCastCounterResetTimer = 0
var spellCastCounterResetTimeLimit = 30
func processCastingLogic(_delta):
  if Input.is_action_just_pressed("alt_action_button") and global.memory.has("spellbookPage"):
    if global.memory["spellbookPage"].size() <= 1:
      noSpellSound.play()
    else:
      applySpellbookGlitch()
      level.summonSmokeClouds(self.global_transform.origin, 3, true, true)

func summonBroomSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(secretSweepActualCollisionShape.global_transform.origin, num_clouds, play_sound, is_glitchy)
  
var returning_to_save_point = 0
func tryDieToOffscreenCamera(_delta):
  var DEATH_MARGIN = 2
  if getGameCamera().rightmost_x > -999:
    # global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
    if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
    global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
    global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
      #print(str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + " || " + str(self.getCamera().rightmost_x) + ", " + str(self.getCamera().leftmost_x) + ", " + str(self.getCamera().topmost_y) + ", " + str(self.getCamera().botmost_y))
      # global.memory["hp"] = 0
      # tryDieToEnemy(delta, true, true, true)
      returning_to_save_point = 1
      returning_recover_time = 0
      returnSound.play()
      pauseSelf = true
      ignorePhysics = true
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("returning")
      pauseAnimation = true
      physics_state = PhysicsState.GLITCH_RECOVERY
  
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
  
  
func processGlitchHurtRecovery(delta):
  if physics_state == PhysicsState.GLITCH_HURT or \
     (physics_state == PhysicsState.GLITCH_DYING and has_sweeped_glitch and global.hasGottenLevelGeode):
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      material.set_shader_param("shake_color_rate", 0.01 + (glitch_death_timer*.002))
    if glitch_death_timer >= 10:
      global.pauseGame = false
      global.pauseMoveInput = false
      self.physics_state = PhysicsState.GLITCH_RECOVERY
      has_sweeped_glitch = false

    return false
  elif physics_state == PhysicsState.GLITCH_DYING:
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      material.set_shader_param("shake_color_rate", 0.01 + (glitch_death_timer*.002))
    if glitch_death_timer >= 10:
      global.pauseGame = false
      level.tryToRespawn()
      self.linear_velocity.y = 0
      self.vv = 0
      self.lv.y = 0
      self.on_ground = false
      self.global_transform.origin.y += 1
      target_last_grounded_y = global_transform.origin.y
      global.memory["hearts_recovering"] = true
      self.physics_state = PhysicsState.GLITCH_RECOVERY

    return false
  else:
    if glitch_death_timer != 0:
      glitch_death_timer += (delta*22)
      applyGlitchDeathEffects(abs(glitch_death_timer))
      if glitch_death_timer >= 20 and should_turn_on_glitch_screen_effects:
        level.glitchScreenEffect.visible = true
        should_turn_on_glitch_screen_effects = false
      if glitch_death_timer >= 40:
        musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
        level.glitchScreenEffect.visible = false
        glitch_death_timer = 0
        mySprite.material_override.set_shader_param("enable_glitch", false)
        mySprite.material_override.set_shader_param("enable_remove_skin_tone", false)
        self.physics_state = PhysicsState.NORMAL

    return true

func applyGlitchDeathEffects(x):
  if global.canChangeSongPitch and (x < 0 or x > 20):
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
  level.displaySpellMessageText("no magic")
  if self.glitch_form != global.GlitchForm.NORMAL or global.memory["mp"] > 0:
    nullifySound.play()
    global.memory["mp"] = 0
    mySprite.get_material_override().set_shader_param("opacity", 1.0)
    self.applyGlitch(global.GlitchForm.NORMAL, true)
    self.can_cast_spell_timer = 0
    if global.memory.has("spellbookPage"):
      global.memory["spellbookPage"] = []
  glitchTickle(true)

func getMushroomInfected():
  if is_mushroom_infected:
    return false

  musicPlayer.changeSongPitch(0.5)
  infectSound.play()
  # mushroom_turn_timer = 0
  glitchTickle(0)
  is_mushroom_infected = true
  # if mySprite.flip_h:
  #   mushroom_infection_direction = -1
  # else:
  #   mushroom_infection_direction = 1


# @override
# aka func ouchies():
func tryDieToEnemy(delta, should_glitch, should_kill_invis, should_immediately_die = false):
  if transitioning:
    return
  if isOnSavePoint():
    return
  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_RECOVERY:
    return
  if global.hasLevelGeodeBeenSmacked and (not global.hasGottenLevelGeode or level.player.pauseSelf):
    return

  if glitch_form == global.GlitchForm.INVISIBLE and not should_kill_invis:
    spawnSparkles(delta, true)
    glitchTickle(true)
    return

  if is_mushroom_infected:
    getABroom()
    for _i in range(5):
      spawnASpore(0, -1)
    is_mushroom_infected = false

  if global.activeInteractor:
    global.activeInteractor.hideTextbox()
  global.activeInteractor = null
  if randi() % 3 == 0:
    hurt2Sound.pitch_scale = rand_range(0.8, 1.5) 
    hurt2Sound.play()
  else:
    hurtSound.pitch_scale = rand_range(0.8, 1.5)
    hurtSound.play()
  bumpSound.play()
  global.pauseGame = true
  global.pauseMoveInput = true

  level.glitchScreenEffect.material.set_shader_param("shake_power", 0.01)
  level.glitchScreenEffect.material.set_shader_param("shake_color_rate", 0.01)
  mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  
  if global.canChangeSongPitch:
    musicPlayer.changeSongPitch(rand_range(0.8, 1.5))

  global.memory["hp"] -= 1
  if global.memory["hp"] <= 0 or should_immediately_die:
    global.incrementLevelZoneDeaths()
    global.memory["hp"] = 0
    self.textBox.hideTextbox()
    global.isRespawning = true
    physics_state = PhysicsState.GLITCH_DYING
    glitch_death_timer = 0
    if global.canGlitchScreen and should_glitch: # TODO(jaketrower): RESPECT MORE
      level.glitchScreenEffect.visible = true
    if summonedBroom:
      broomStop()
    tryClearFallthroughCollisionSolid()
  else:
    physics_state = PhysicsState.GLITCH_HURT
    glitchTickle(true)
    glitch_death_timer = 0

    if global.memory["hp"] <= 1:
      summonSmokeClouds(5, true, true, -1)
      enchantedBagSpriteVisible.visible = false
    # self.nullify()

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var is_smacked = false
var smack_timer = 0
var smack_time_limit = 7
func getSmacked():
  mySprite.material_override.set_shader_param("time_influence", time_influence)
  mySprite.material_override.set_shader_param("y_div", y_div)
  mySprite.material_override.set_shader_param("normal_offset", normal_offset)
  smack_timer = 0
  is_smacked = true
  pauseSelf = true


func processBagLogic(_delta):
  pass

func processBroomLogic(delta):
  var aa = aniPlayer.assigned_animation
  if (aa == "broomSmackGlitch" or aa == "sweepFloor") and not aniPlayer.is_playing():
    broomStop()

  var which_broom_attack = 1
  if not global.memory["broom"]:
    if global.memory["has_gotten_broom"] > 0 and Input.is_action_just_pressed("sub_action_button") and not noBroomSound.is_playing() and nesting_doll_state == global.NestingDoll.GRANDMA:
      noBroomSound.play()
    return

  if global.pauseMoveInput and global.activeInteractor == null:
    return

  if not summonedBroom and is_in_broom_cooldown:
    broom_cooldown_timer += (delta*22)
    if broom_cooldown_timer >= broom_cooldown_time_limit:
      broom_cooldown_timer = 0
      is_in_broom_cooldown = false
      which_broom_attack = 1

  if Input.is_action_just_pressed("sub_action_button") and not summonedBroom and not pauseSelf and not aa == "sweepFloor": # and (global.activeInteractor == null or global.activeInteractor.is_tiny):
    aniPlayer.stop()
    aniPlayer.clear_queue()
    # TODO(jaketrower): has just turned around
    if Input.is_action_pressed("ui_down"):
      aniPlayer.play("sweepFloor")
      which_broom_attack = 0
    elif is_in_broom_cooldown or (is_pressing_horizontal_input and ((mySprite.flip_h and lv.x > -1) or (not mySprite.flip_h and lv.x < 1))):
      aniPlayer.play("broomSmack2")
      which_broom_attack = 2
    else:
      aniPlayer.play("broomSmack")
    pauseAnimation = true

    is_in_broom_cooldown = true
    broom_cooldown_timer = 0
    # elif glitch_form == global.GlitchForm.FEATHER:
    #   broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
    # velocity_dampener = 2.0
    if on_ground:
      walk_speed = 0
      feather_glitch_walk_speed = 0
      invisible_glitch_walk_speed = 0
    if linear_velocity.y < 0:
      linear_velocity.y = 0
    global.incrementLevelZoneSweeps()
    jump_press_timer = jump_press_broom_time_limit
    if which_broom_attack > 0:
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
  elif Input.is_action_just_pressed("sub_action_button") and summonedBroom and not pauseSelf and not global.pauseGame:
    summonedBroom.queue_free()
    broomStop()
    if not on_ground:
      var amt = 2
      self.vv = amt
      self.linear_velocity.y = amt
      self.lv.y = amt
    summonFallenBroom(true)
  elif Input.is_action_pressed("sub_action_button") and not summonedBroom and not pauseSelf and on_ground and is_pressing_horizontal_input:
    hitStuff(delta)
  elif aniPlayer.assigned_animation == "sweepFloor" and isKindOfOnGround():
    vv = 0
    lv.y = 0
    linear_velocity.y = 0
    hitStuff(delta)
    # global_transform.origin.y = last_grounded_pos.y
    if Input.is_action_just_pressed("sub_action_button"):
      broomStop()
      summonFallenBroom(true)

var spore_spawn_timer = 0
var spore_spawn_time_limit = 15
onready var sporeSound = get_node("Sounds/SporeSound")
onready var pauseSound = get_node("Sounds/PauseSound")
onready var unpauseSound = get_node("Sounds/UnpauseSound")
func processMushroomLogic(_delta):
  mushroomSprite.visible = is_mushroom_infected
  if is_mushroom_infected:
    if global.memory["broom"]:
      mySprite.flip_h = not mySprite.flip_h
      summonFallenBroom(false, true)
      mySprite.flip_h = not mySprite.flip_h
    adjustMushroomSpritePosition()
    # if horizontal_collision:
    #   mushroom_infection_direction = -mushroom_infection_direction
    #   mushroom_turn_timer = 0

    # var turning_left = mushroom_infection_direction == 1 and Input.is_action_pressed("ui_left")
    # var turning_right = mushroom_infection_direction == -1 and Input.is_action_pressed("ui_right")
    # if turning_left or turning_right:
    #   mushroom_turn_timer += (delta*22) if on_ground else mushroom_turn_time_limit
    #   if mushroom_turn_timer >= mushroom_turn_time_limit:
    #     mushroom_turn_timer = 0
    #     mushroom_infection_direction *= -1
    # else:
    #   mushroom_turn_timer = 0
    
    # spore_spawn_timer += (delta*22)
    # if spore_spawn_timer >= spore_spawn_time_limit:
    #   spore_spawn_timer = 0
    #   spawnASpore()
    #   sporeSound.play()


func adjustMushroomSpritePosition():
  mushroomSprite.global_transform.origin.x = self.global_transform.origin.x
  var amt = 0.25
  if mySprite.flip_h:
    mushroomSprite.global_transform.origin.x -= amt
  else:
    mushroomSprite.global_transform.origin.x += amt

func adjustSummonedBroomSpritePosition():
  var xAddition = 0
  var yAddition = 0
  if summonedBroom.aniPlayer.assigned_animation == "broomSmack":
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

  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + yAddition
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func shouldAirHaveFriction():
  return summonedBroom == null

# var broom_flip_h = false
func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.scale = broomSpriteAnimated.scale
  secretSweepActualCollisionShape.translation = secretSweepCollisionShape.translation
  broomSpriteVisible.flip_h = false
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1
    secretSweepActualCollisionShape.translation.x *= -1
  if aniPlayer.assigned_animation != "broomSmackGlitch":
    if global.hasGottenLevelGeode:
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", true)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", true)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", true)
    else:
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", false)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", false)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", false)
    
  if summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif global.memory["broom"]:
    broomSpriteVisible.visible = true
  else:
    broomSpriteVisible.visible = false
    if nesting_doll_state == global.NestingDoll.GRANDMA:
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
  var is_touching_poison_water = is_touching_water and touched_water_area != null and touched_water_area.get_node("..").is_poison

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
    level.glitchScreenEffect.visible = true
    level.glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (poison_timer*.0005))
    musicPlayer.changeSongPitch(abs(sin(poison_timer*.05)+.02))
  if poison_timer < 0:
    poison_timer = 0
    level.glitchScreenEffect.visible = false
    musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
    reversePoisonWaterSound.stop()
    
# @override
func landed():
  .landed()
  num_spell_casts_used = 0
  target_last_grounded_y = global_transform.origin.y
  broom_cooldown_timer = 0
  is_in_broom_cooldown = false
  summonSmokeClouds(1, false, false, 1)

  # TODO(jaketrower): Uncomment out for final dungeon level
  if global.hasGottenLevelGeode:
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
    
func broomStop():  
  summonedBroom = null
  pauseAnimation = false
  pauseInput = false
  broomSpriteVisible.visible = true
  walk_speed = remembered_walk_speed
  feather_glitch_walk_speed = remembered_feather_glitch_walk_speed
  invisible_glitch_walk_speed = remembered_invisible_glitch_walk_speed
  velocity_dampener = 1.0
  if has_sweeped_glitch:
    was_just_on_ground_timer = -8
  if linear_velocity.y < 0:
    linear_velocity.y = 0
  if jump_press_timer < jump_press_broom_time_limit or should_magic_jump:
    jump_press_timer = 0
    if has_sweeped_glitch or should_magic_jump:
      linear_velocity.y = -0.01
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.queue("fall")
  if on_ground:
    aniPlayer.queue("stand")
  smacked_npc = null

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

func iFellFlat():
  var fallenBroom = summonFallenBroom(false)
  if fallenBroom != null:
    fallenBroom.canPause = true

func summonFallenBroom(was_thrown, should_die_on_land = false):
  broomSpriteVisible.visible = false
  summonSmokeClouds(5, false, false)

  if global.memory["broom"]:
    var fallenBroom = fallenBroomRes.instance()
    level.add_child(fallenBroom)
    if smacked_npc != null:
      fallenBroom.smacked_npc = smacked_npc
    fallenBroom.should_die_on_land = should_die_on_land
    fallenBroom.global_transform.origin = self.global_transform.origin
    fallenBroom.global_transform.origin.x += -1 if mySprite.flip_h else 1
    fallenBroom.walk_direction.x = -1 if mySprite.flip_h else 1
    if grav > 0:
      fallenBroom.global_transform.origin.y += 2
    if was_thrown:
      global.incrementLevelZoneSweeps()
      fallenBroom.grav = 1
      fallenBroom.projectile = true
      fallenBroom.global_transform.origin.y -= 1
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
      elif Input.is_action_pressed("ui_down"):
        fallenBroom.walk_speed *= .7
        fallenBroom.walk_direction = Vector2(x_direction, -1)
        fallenBroom.grav = 600
        fallenBroom.true_terminal_vel = 12.0 if x_direction == 0 else 12 * .7
      elif x_direction != 0:
        fallenBroom.walk_direction.x = x_direction
    global.memory["broom"] = false
    # print(fallenBroom.walk_direction)

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
    return fallenBroom
  return null

func iJustPressedDown():
  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground:
    .iJustPressedDown() # super
    return

  var trying_to_interact_with_door = false
  if Input.is_action_just_pressed("ui_down"):
    var areas = interactionArea.get_overlapping_areas()
    for area in areas:
      if area.is_in_group("door"):
        trying_to_interact_with_door = true
        break
  if trying_to_interact_with_door:
    return

  on_ground = false
  should_do_fallthrough_area_collision = false
  tryClearFallthroughCollisionSolid()

func tryClearFallthroughCollisionSolid():
  if interactionArea.prev_fallthrough_collision_area != null and \
     interactionArea.prev_fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionClear"):
    interactionArea.prev_fallthrough_collision_area.get_node("..").fallthroughCollisionClear(self)

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
func hitStuff(_delta):
  if not visible: return
  
  var my_broom_owner = self
  var areas = secretSweepActualArea.get_overlapping_areas()
  for area in areas:
    if area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive():
      if not area.get_node("..").am_i_dying:
        area.get_node("..").ouchies(global_transform.origin)
        my_broom_owner.has_sweeped_glitch = true
        summonSmokeClouds(5, true, true)
        my_broom_owner.getSmacked()
    elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
      if global.hasGottenLevelGeode:
        if area.get_node("..").ouchies(global_transform.origin):
          my_broom_owner.has_sweeped_glitch = true
          my_broom_owner.getSmacked()
      else:
        # TODO(should "remember" i hit it until i'm no longer touching it...?)
        if area.get_node("..").notOuchies(global_transform.origin):
          area.get_node("..").smack_recovery_time_limit = 30
          my_broom_owner.getSmacked()
      # # TODO kill glitches or "free" them like glitch slug...
    elif area.is_in_group("bug") and area.get_node("..").has_method("getSmacked"):
      area.get_node("..").getSmacked(global_transform.origin)
      my_broom_owner.getSmacked()


  # erase glitch tiles...
  if not global.memory.has("broom"):
    return
  var x = secretSweepActualCollisionShape.global_transform.origin.x
  var y = secretSweepActualCollisionShape.global_transform.origin.y
  var tb = y + secretSweepActualCollisionShape.shape.height/2
  var bb = y - secretSweepActualCollisionShape.shape.height/2
  var lb = x - secretSweepActualCollisionShape.shape.radius
  var rb = x + secretSweepActualCollisionShape.shape.radius
  
  var _has_played_sound = false
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileSpikes(tile_type):
        my_broom_owner.has_sweeped_glitch = true
        getLevelTiles().infectSpikes(coords)
      elif getLevelTiles().isTileSoftSand(tile_type):
        my_broom_owner.has_sweeped_glitch = true
        getLevelTiles().sweepUpSand(coords)
        digSound.play()
        getSmacked()
        broomStop()


func swordClank(play_sound = true):
  if summonedBroom:
    broomStop()
  getSmacked()
  if play_sound:
    broomSound.play()
