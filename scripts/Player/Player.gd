extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var broomSound = get_node("Sounds/BroomSound")
onready var blinkSound = get_node("Sounds/BlinkSound")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var grannyLandSound = get_node("Sounds/GrannyLandSound")
onready var poisonWaterSound = get_node("Sounds/PoisonWaterSound")
onready var reversePoisonWaterSound = get_node("Sounds/PoisonWaterReverseSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")
onready var mpNumSprite = get_node("MPNumSprite")
onready var mpNumSprite2 = get_node("MPNumSprite/MPNumSprite2")

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
# var spriteSheetFeather = preload("res://assets/player_sheet_old_feather.png")
var summonedBroom = null
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 20
var is_in_broom_cooldown = false

onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")

onready var enchantedBagSpriteAnimated = get_node("Sprite3DBagAnimated")
onready var enchantedBagSpriteVisible = get_node("Sprite3DBagVisible")

onready var interactPrompt = get_node("InteractPrompt")
onready var importantInteractPrompt = get_node("ImportantInteractPrompt")

onready var textContainer = get_node("TextContainer")
onready var textBox = get_node("TextContainer/TextBox")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var should_turn_on_glitch_screen_effects = false
var glitch_death_timer = 0
var glitch_tickle_timer = 0
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
  set_process_input(true)
  set_process(true)
  set_physics_process(true)
  if pauseMenu: pauseMenu.hide()

  remembered_walk_speed = walk_speed
  remembered_feather_glitch_walk_speed = feather_glitch_walk_speed
  remembered_invisible_glitch_walk_speed = invisible_glitch_walk_speed
  broomSpriteAnimated.get_material_override().set_shader_param("opacity", 1.0)

func applyNextGlitch():
  applyGlitch(global.getNextGlitch(glitch_form))
  
func applyObeliskGlitch(glitch, only_visual = false):
  if global.memory.has("spellbookPage") and not level.spellbook_forbidden:
    if not only_visual:
      var spellbook_size = global.memory["spellbookPage"].size()
      var is_it_already_my_first_spellbook_page = spellbook_size > 0 and global.memory["spellbookPage"][spellbook_size-1] == glitch
      if global.memory["spellbookPage"].size() >= 2 and not is_it_already_my_first_spellbook_page:
        print(global.memory["spellbookPage"])
        global.memory["spellbookPage"].pop_front()
      elif global.memory.has("tutorial_spellbookPage") and global.memory["tutorial_spellbookPage"]:
        level.uiLayer.get_node("EquipmentStatusRect").visible = true
        level.uiLayer.get_node("EquipmentStatusRect").rect_scale = Vector2(1.5, 1.5)
        level.uiLayer.get_node("EquipmentStatusRect").rect_position = Vector2(300, 250)

      if not is_it_already_my_first_spellbook_page:
        global.memory["spellbookPage"].push_back(glitch)
  applyGlitch(glitch, only_visual)
    
func applySpellbookGlitch():
  if not global.memory.has("spellbookPage"):
    return

  if global.memory["mp"] <= 0:
    return
  
  if global.memory["spellbookPage"].size() > 0:
    var glitch_type = global.memory["spellbookPage"].pop_front()
    applyGlitch(glitch_type)
    applyObeliskGlitch(glitch_type)
    var equipSlotSprite = level.uiLayer.get_node("EquipmentRect/ColorRect/ColorRect/ColorRect2/ColorRect3/EquipmentSlotSprite")
    equipSlotSprite.frame = 6
  else:
    noSpellSound.play()

func restoreGlitchAndMP():
  if global.memory["mp"] <= 0:
    applyGlitch(global.memory["current_glitch"], true)
  global.memory["mp"] = global.memory["max_mp"]
  

func applyGlitch(glitch, notPlaySound = false):
  nullifySound.stop()
  if not notPlaySound:
    if glitch == self.glitch_form:
      rechargeSound.play()
    else:
      transformSound.play()
  global.memory["current_glitch"] = glitch

  mySprite.material_override.set_shader_param("opacity", 1.0)
  mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
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
  glitch_form = global.GlitchForm.FLOOR
  level.floorGlitch()
  changeSpriteColorPalette(getLevelTiles().red_palette)
  # mySprite.setBugCatcherCostume()

func featherGlitch():
  glitch_form = global.GlitchForm.FEATHER
  level.featherGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.green_dungeon_palette)
  # mySprite.setMothCostume()
  # mySprite.material_override.set_shader_param("texture_albedo", spriteSheetFeather)

func ladderGlitch():
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.yellow_player_palette)
  # mySprite.setLuckyCatCostume()

func invisibleGlitch():
  glitch_form = global.GlitchForm.INVISIBLE
  level.invisibleGlitch()
  changeSpriteColorPalette(getLevelTiles().black_palette)
  mySprite.get_material_override().set_shader_param("opacity", 0.75)
  # mySprite.setClericCostume()

func walkThroughWallsGlitch():
  glitch_form = global.GlitchForm.WALK_THROUGH_WALLS
  level.walkThroughWallsGlitch()
  changeSpriteColorPalette(getLevelTiles().white_palette)
  # mySprite.setNightgown()

func wearCostume(costume):
  global.memory["player_costume"] = costume

# @override
func pressingRun():
  return global.memory["broom"] and Input.is_action_pressed("sub_action_button") and summonedBroom == null
  
func _process(delta):
  # ._process(delta) #NOTE: this super method is called automatically 
  # https://github.com/godotengine/godot/issues/6500
  pauseInput = summonedBroom
  
  # TODO(jaketrower): !!! Remove (change to HOLD) before release
  if Input.is_action_just_pressed("ui_cancel"):
    level.get_tree().quit()

  if Input.is_action_just_pressed("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
  
  delta = delta * global.time_dilation_multiplier
  if not processGlitchHurtRecovery(delta):
    return

  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT:
    return
  processBroomRenderLogic(delta)
  processBagRenderLogic(delta)
  if global.pauseGame or global.pauseMoveInput:
    return
  processBroomLogic(delta)
  processBagLogic(delta)
  # processBubbleLogic(delta)
    
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
  processMPBlinkLogic(delta)
  if pressingJump():
    tryClearFallthroughCollisionSolid()

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()

func unsmack():
  is_smacked = false
  pauseSelf = false
  mySprite.material_override.set_shader_param("time_influence", 3)
  mySprite.material_override.set_shader_param("y_div", 2.3)
  mySprite.material_override.set_shader_param("normal_offset", .02)

func processMPBlinkLogic(delta):
  if glitch_form == global.GlitchForm.NORMAL:
    if global.memory["mp"] == 0:
      mpNumSprite.frame = 880
      mpNumSprite2.frame = 880
      blink_timer += (delta*22)
      if (not is_blinked and blink_timer >= blink_time_limit) or (is_blinked and blink_timer >= unblink_time_limit):
        blink_timer = 0
        if not is_blinked and blink_time_limit == 3:
          nullifySound.stop()
        is_blinked = not is_blinked
        mpNumSprite.visible = not is_blinked
        blink_time_limit = 3
    if global.memory["mp"] > 1 or not nullifySound.is_playing():
      mpNumSprite.visible = false
    return

  var overwrite_blink = (global.memory["mp"] == global.memory["max_mp"]) or global.memory["mp"] > 5

  if global.memory["max_mp"] == 0:
    mpNumSprite.visible = false
  elif (global.memory["mp"] <= 5 and global.memory["max_mp"] > 6) or (global.memory["mp"] <= 3 and global.memory["max_mp"] >= 5) or (global.memory["mp"] <= 2):
    mpNumSprite.visible = true
  else:
    mpNumSprite.visible = false

  if global.memory["mp"] <= 5 or overwrite_blink:
    mpNumSprite.frame = 885
    blink_time_limit = 20
    if global.memory["mp"] == 4:
      blink_time_limit = 15
      mpNumSprite.frame = 884
    if global.memory["mp"] == 3:
      blink_time_limit = 10
      mpNumSprite.frame = 883
    if global.memory["mp"] == 2:
      blink_time_limit = 5
      mpNumSprite.frame = 882
    if global.memory["mp"] == 1:
      blink_time_limit = 2
      mpNumSprite.frame = 881
    mpNumSprite2.frame = mpNumSprite.frame
    blink_timer += (delta*22)
    if overwrite_blink or (not is_blinked and blink_timer >= blink_time_limit) or (is_blinked and blink_timer >= unblink_time_limit):
      blink_timer = 0
      is_blinked = not is_blinked

      if overwrite_blink:
        blink_timer = 0
        is_blinked = false

      if is_blinked:
        mySprite.material_override.set_shader_param("target_palette", global.grey_player_palette)
        if mpNumSprite.visible and not (global.pauseMoveInput or global.pauseGame or global.activeInteractor != null) and (is_pressing_horizontal_input or pressingJump() or (glitch_form == global.GlitchForm.INVISIBLE and glitch_tickle_timer > 0)):
          blinkSound.play()
      elif glitch_form == global.GlitchForm.FLOOR:
        mySprite.material_override.set_shader_param("target_palette", getLevelTiles().red_palette)
      elif glitch_form == global.GlitchForm.FEATHER:
        mySprite.material_override.set_shader_param("target_palette", global.green_dungeon_palette)
      elif glitch_form == global.GlitchForm.LADDER:
        mySprite.material_override.set_shader_param("target_palette", global.yellow_player_palette)
      elif glitch_form == global.GlitchForm.INVISIBLE:
        mySprite.material_override.set_shader_param("target_palette", getLevelTiles().black_palette)
      elif glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
        mySprite.material_override.set_shader_param("target_palette", getLevelTiles().white_palette)

  if showMpTimer < showMpTimeLimit:
    showMpTimer += (delta*22)
    var opacity = 2*(1 - (showMpTimer/showMpTimeLimit))
    mpNumSprite2.material_override.set_shader_param("opacity", opacity)
  if showMpTimer >= showMpTimeLimit:
    mpNumSprite.visible = false
  
func tryDieToOffscreenCamera(delta):
  var DEATH_MARGIN = 5
  if getGameCamera().rightmost_x > -999:
    # global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
    if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
    global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
    global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
      #print(str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + " || " + str(self.getCamera().rightmost_x) + ", " + str(self.getCamera().leftmost_x) + ", " + str(self.getCamera().topmost_y) + ", " + str(self.getCamera().botmost_y))
      global.memory["hp"] = 0
      tryDieToEnemy(delta, true, true, true)
  
func doTimeDilation(delta):
  var real_delta_multiplier = 8

  var gtdm = global.time_dilation_multiplier
  var low = 0.6
  var high = 1.0
  if Input.is_action_pressed("ui_select"):
    mySprite.material_override.set_shader_param("palette_cycle_speed", 4.0)
    gtdm = gtdm + (low - gtdm) * (delta*real_delta_multiplier)
    if stepify(gtdm, 0.01) == stepify(low, 0.01):
      gtdm = low
      mySprite.material_override.set_shader_param("palette_cycle_speed", 2.5)
      
    mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  else:
    gtdm = gtdm + (high - gtdm) * (delta*real_delta_multiplier)
    mySprite.material_override.set_shader_param("enable_palette_cycle", false)
      
    if stepify(gtdm, 0.01) == stepify(high, 0.01):
      gtdm = high
  global.time_dilation_multiplier = gtdm
  
  
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
        musicPlayer.changeSongPitch(1.0)
        level.glitchScreenEffect.visible = false
        glitch_death_timer = 0
        var my_material = mySprite.get_material_override()
        if my_material is ShaderMaterial:
          my_material.set_shader_param("enable_glitch", false)
          my_material.set_shader_param("enable_remove_skin_tone", false)
        self.physics_state = PhysicsState.NORMAL

    return true

func applyGlitchDeathEffects(x):
  if global.canChangeSongPitch and (x < 0 or x > 20):
    musicPlayer.changeSongPitch(abs(sin(x*.05)+.02))
  if x > 10:
    var my_material = mySprite.get_material_override()
    if my_material is ShaderMaterial:
      my_material.set_shader_param("enable_glitch", self.physics_state == PhysicsState.GLITCH_RECOVERY)
      my_material.set_shader_param("enable_remove_skin_tone", self.physics_state == PhysicsState.GLITCH_RECOVERY)

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

func glitchTickle(play_sound = true):
  glitch_tickle_timer = 1
  var my_material = mySprite.get_material_override()
  if my_material is ShaderMaterial:
    my_material.set_shader_param("enable_glitch", true)
    my_material.set_shader_param("enable_remove_skin_tone", true)
    my_material.set_shader_param("shake_power", 0.01)
    my_material.set_shader_param("shake_color_rate", 0.01)
    if play_sound:
      noSpellSound.play()

func nullify():
  if self.glitch_form != global.GlitchForm.NORMAL or global.memory["mp"] > 0:
    nullifySound.play()
    global.memory["mp"] = 0
    mySprite.get_material_override().set_shader_param("opacity", 1.0)
    self.applyGlitch(global.GlitchForm.NORMAL, true)
    self.can_cast_spell_timer = 0
    if global.memory.has("spellbookPage"):
        global.memory["spellbookPage"] = []

# @override
# aka func ouchies():
func tryDieToEnemy(delta, should_glitch, should_kill_invis, should_immediately_die = false):
  if transitioning:
    return
  if isOnSavePoint():
    return
  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_RECOVERY:
    return

  if glitch_form == global.GlitchForm.INVISIBLE and not should_kill_invis:
    spawnSparkles(delta, true)
    glitchTickle(true)
    return

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

  var material = level.glitchScreenEffect.get_material()
  if material is ShaderMaterial:
    material.set_shader_param("shake_power", 0.01)
    material.set_shader_param("shake_color_rate", 0.01)
  var my_material = mySprite.get_material_override()
  if my_material is ShaderMaterial:
    my_material.set_shader_param("enable_glitch", true)
    my_material.set_shader_param("enable_remove_skin_tone", true)
  
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

    
func showInteractPrompt(is_important = false):
  if global.activeInteractor == null:
    if is_important:
      importantInteractPrompt.visible = true
    else:
      interactPrompt.visible = true

func hideInteractPrompt():
  interactPrompt.visible = false
  importantInteractPrompt.visible = false

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

func processBroomLogic(_delta):
  if not (global.memory.has("broom") and global.memory["broom"]):
    return

  # if not summonedBroom and is_in_broom_cooldown:
  #   broom_cooldown_timer += (delta*22)
  #   if broom_cooldown_timer >= broom_cooldown_time_limit:
  #     broom_cooldown_timer = 0
  is_in_broom_cooldown = false

  if Input.is_action_just_pressed("sub_action_button") and not is_in_broom_cooldown and not summonedBroom: # and (global.activeInteractor == null or global.activeInteractor.is_tiny):
    applySpellbookGlitch()
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("broomSmack")

    is_in_broom_cooldown = true
    broom_cooldown_timer = 0
    if on_ground:
      broom_cooldown_timer = broom_cooldown_time_limit / 2
    # elif glitch_form == global.GlitchForm.FEATHER:
    #   broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
    # velocity_dampener = 2.0
    pauseAnimation = true
    if on_ground:
      walk_speed = 0
      feather_glitch_walk_speed = 0
      invisible_glitch_walk_speed = 0
    if linear_velocity.y < 0:
      linear_velocity.y = 0
    summonedBroom = summonedBroomRes.instance()
    level.add_child(summonedBroom)
    summonedBroom.my_broom_owner = self
    adjustSummonedBroomSpritePosition()
    jump_press_timer = jump_press_broom_time_limit
  elif Input.is_action_just_pressed("sub_action_button") and summonedBroom:
    summonedBroom.broom_active_timer = 100
    summonFallenBroom(true)

func adjustSummonedBroomSpritePosition():
  broomSpriteVisible.visible = false
  if mySprite.flip_h:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x - .875
    summonedBroom.rotation_degrees = Vector3(0, 180, 0)
  else:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x + .875
    summonedBroom.rotation_degrees = Vector3(0, 0, 0)
  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + .625
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func shouldAirHaveFriction():
  return summonedBroom == null

func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.flip_h = false
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1
  if global.hasGottenLevelGeode:
    broomSpriteVisible.material_override.set_shader_param("enable_glitch", true)
    broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", true)
    mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  else:
    broomSpriteVisible.material_override.set_shader_param("enable_glitch", false)
    broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", false)
    mySprite.material_override.set_shader_param("enable_palette_cycle", false)
    
  if summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif global.memory.has("broom") and global.memory["broom"]:
    broomSpriteVisible.visible = true
  else:
    broomSpriteVisible.visible = false
    if not is_tiny:
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
        musicPlayer.changeSongPitch(1.0)
        reversePoisonWaterSound.stop()

  if poison_timer > 0:
    level.glitchScreenEffect.visible = true
    level.glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (poison_timer*.0005))
    musicPlayer.changeSongPitch(abs(sin(poison_timer*.05)+.02))
  if poison_timer < 0:
    poison_timer = 0
    level.glitchScreenEffect.visible = false
    musicPlayer.changeSongPitch(1.0)
    reversePoisonWaterSound.stop()
    
# @override
func landed():
  .landed()
  target_last_grounded_y = global_transform.origin.y
  broom_cooldown_timer = 0
  is_in_broom_cooldown = false
  summonSmokeClouds(1, false, false, 1)

  # TODO(jaketrower): Uncomment out for final dungeon level
  # var lt = getLevelTiles()
  # var original_y = global_transform.origin.y
  # for _i in range(4):
  #   var tiles = getTilesBelow(lt)
  #   if tiles[0] != null:
  #     lt.rerandomizeTile(tiles[0], lt.getRandomGlitchType())
  #   if tiles[1] != null:
  #     lt.rerandomizeTile(tiles[1], lt.getRandomGlitchType())
  #   if tiles[2] != null:
  #     lt.rerandomizeTile(tiles[2], lt.getRandomGlitchType())
  #   global_transform.origin.y -= 1
  # global_transform.origin.y = original_y
    
func broomStop():
  summonedBroom = null
  broomSpriteVisible.visible = true
  pauseAnimation = false
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
  summonFallenBroom(false)

func summonFallenBroom(was_thrown):
  broomSpriteVisible.visible = false
  summonSmokeClouds(5, false, false)

  if global.memory.has("broom") and global.memory["broom"]:
    var fallenBroom = fallenBroomRes.instance()
    level.add_child(fallenBroom)
    fallenBroom.global_transform.origin = self.global_transform.origin
    fallenBroom.global_transform.origin.x += -1 if mySprite.flip_h else 1
    fallenBroom.walk_direction = -1 if mySprite.flip_h else 1
    fallenBroom.global_transform.origin.y += 2
    if was_thrown:
      fallenBroom.grav = 1
      fallenBroom.projectile = true
      fallenBroom.global_transform.origin.y -= 1
      fallenBroom.true_terminal_vel = 0
      fallenBroom.walk_speed *= 3
      fallenBroom.get_node("BroomSound").play()
    global.memory["broom"] = false

    if mySprite.flip_h and was_thrown:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse", -1, 2.0)
    elif mySprite.flip_h and not was_thrown:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
    elif not mySprite.flip_h and was_thrown:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin", -1, 2.0)
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")

func getABroom():
  global.memory["broom"] = true
  mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)

func iJustPressedDown():
  on_ground = false
  should_do_fallthrough_area_collision = false
  tryClearFallthroughCollisionSolid()

func tryClearFallthroughCollisionSolid():
  if interactionArea.prev_fallthrough_collision_area != null and \
     interactionArea.prev_fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionClear"):
    interactionArea.prev_fallthrough_collision_area.get_node("..").fallthroughCollisionClear(self)

var bubbleSpawnTimer = 0
var bubbleSpawnTimeLimit = 5

func processBubbleLogic(delta):
  if Input.is_action_pressed("sub_action_button"):
    bubbleSpawnTimer += (delta * 22)
    if bubbleSpawnTimer >= bubbleSpawnTimeLimit:
      bubbleSpawnTimer = 0
      summonBubble()
  else:
    bubbleSpawnTimer = 0

func summonBubble():
  var x_diff_start = 2
  var x_diff_target = 5
  if mySprite.flip_h:
    x_diff_start *= -1
    x_diff_target *= -1

  var bubble = bubbleRes.instance()
  level.add_child(bubble)
  bubble.global_transform.origin = self.global_transform.origin
  bubble.global_transform.origin.x += x_diff_start
  bubble.original_pos_x = bubble.global_transform.origin.x
  bubble.target_pos_x = self.global_transform.origin.x + rand_range(-1, 1) + x_diff_target
  bubble.y_speed_start = rand_range(-2, -3)
  bubble.setAsParent(self)

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false, horizontal = 0):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        if horizontal != 0:
          newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x
          var which_horizontal_dir = mySprite.flip_h
          if horizontal < 0:
            which_horizontal_dir = not which_horizontal_dir
          if which_horizontal_dir:
            newSmokeCloud.global_transform.origin.x -= 1
            newSmokeCloud.target_x = newSmokeCloud.global_transform.origin.x - rand_range(1, 3)
          else:
            newSmokeCloud.global_transform.origin.x += 1
            newSmokeCloud.target_x = newSmokeCloud.global_transform.origin.x + rand_range(1, 3)
          newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y
          newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        else:
          newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
          newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(1, 2)
          newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())

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
