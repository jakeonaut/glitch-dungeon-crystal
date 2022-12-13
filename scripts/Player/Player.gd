extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var broomSound = get_node("Sounds/BroomSound")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var poisonWaterSound = get_node("Sounds/PoisonWaterSound")
onready var reversePoisonWaterSound = get_node("Sounds/PoisonWaterReverseSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
var summonedBroom = null
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 20
var is_in_broom_cooldown = false

onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")

onready var interactPrompt = get_node("InteractPrompt")
onready var importantInteractPrompt = get_node("ImportantInteractPrompt")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var glitch_death_timer = 0
var glitch_tickle_timer = 0
var glitch_tickle_time_limit = 10
var can_cast_spell_timer = 0
var can_cast_spell_time_limit = 10
var poison_timer = 0
var poison_time_limit = 28
var unpoison_timer = 0
var unpoison_time_limit = 10

func _ready():
  grav = 60
  set_process_input(true)
  set_process(true)
  set_physics_process(true)
  if pauseMenu: pauseMenu.hide()

func applyNextGlitch():
  applyGlitch(global.getNextGlitch(glitch_form))
  
func applyObeliskGlitch(glitch, only_visual = false, can_show_tutorial = false):
  if global.memory.has("spellbookPage") and not level.spellbook_forbidden:
    if not only_visual and not global.memory["spellbookPage"].has(glitch):
      if global.memory["spellbookPage"].size() >= 2:
        global.memory["spellbookPage"].pop_front()
      elif global.memory.has("tutorial_spellbookPage") and global.memory["tutorial_spellbookPage"] and can_show_tutorial:
        level.uiLayer.get_node("EquipmentStatusRect").visible = true
        level.uiLayer.get_node("EquipmentStatusRect").rect_scale = Vector2(1.5, 1.5)
        level.uiLayer.get_node("EquipmentStatusRect").rect_position = Vector2(300, 250)

      global.memory["spellbookPage"].push_back(glitch)
  applyGlitch(glitch, only_visual)
    
func applySpellbookGlitch():
  if not global.memory.has("spellbookPage"):
    return
  
  if global.memory["spellbookPage"].size() > 0:
    var glitch_type = global.memory["spellbookPage"].pop_front()
    applyGlitch(glitch_type)
    applyObeliskGlitch(glitch_type)
    var equipSlotSprite = level.get_node("UILayer/EquipmentRect/ColorRect/ColorRect/ColorRect2/ColorRect3/EquipmentSlotSprite")
    equipSlotSprite.frame = 6
  else:
    noSpellSound.play()


func applyGlitch(glitch, notPlaySound = false):
  if not notPlaySound:
    transformSound.play()
  global.memory["current_glitch"] = glitch

  mySprite.get_material_override().set_shader_param("opacity", 1.0)
  if glitch == global.GlitchForm.NORMAL: normalGlitch()
  if glitch == global.GlitchForm.FLOOR: floorGlitch()
  if glitch == global.GlitchForm.FEATHER: featherGlitch()
  if glitch == global.GlitchForm.LADDER: ladderGlitch()
  if glitch == global.GlitchForm.INVISIBLE: invisibleGlitch()
  if glitch == global.GlitchForm.WALK_THROUGH_WALLS: walkThroughWallsGlitch()

func changeSpriteColorPalette(palette):
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("target_palette", palette)
    mySprite.material_override = material

func normalGlitch():
  glitch_form = global.GlitchForm.NORMAL
  level.normalGlitch()
  changeSpriteColorPalette(getLevelTiles().grey_palette)
  # mySprite.setNormalClothes()

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

func ladderGlitch():
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(getLevelTiles().yellow_palette)
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
  
func _process(delta):
  # ._process(delta) #NOTE: this super method is called automatically 
  # https://github.com/godotengine/godot/issues/6500

  if Input.is_action_just_pressed("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
  
  delta = delta * global.time_dilation_multiplier
  if not processGlitchHurtRecovery(delta):
    return

  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT:
    return
  processBroomLogic(delta)
  if global.pauseGame or global.pauseMoveInput:
    return
    
  # doTimeDilation(real_delta)

  if can_cast_spell_timer < can_cast_spell_time_limit:
    can_cast_spell_timer += (delta*22)
    
  # if Input.is_action_just_pressed("ui_accept") and not global.pauseMoveInput:
  #     if not global.pauseGame:
  #         if pauseMenu: pauseMenu.show()
  #         global.pauseGame = true
  #     else:
  #         if pauseMenu: pauseMenu.hide()
  #         global.pauseGame = false

  if Input.is_action_just_pressed("action_button") and can_cast_spell_timer >= can_cast_spell_time_limit:
    applySpellbookGlitch()
  if Input.is_action_just_pressed("debug_glitch_button"):
    applyNextGlitch()
    
  tryDieToOffscreenCamera()
      
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
  
func tryDieToOffscreenCamera():
  var DEATH_MARGIN = 5
  if getGameCamera().rightmost_x > -999:
    # global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
    if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
    global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
    global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
      #print(str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + " || " + str(self.getCamera().rightmost_x) + ", " + str(self.getCamera().leftmost_x) + ", " + str(self.getCamera().topmost_y) + ", " + str(self.getCamera().botmost_y))
      global.memory["hearts"] = 0
      tryDieToEnemy(true, true)
  
func doTimeDilation(delta):
  var real_delta_multiplier = 8

  var gtdm = global.time_dilation_multiplier
  var low = 0.6
  var high = 1.0
  if Input.is_action_pressed("ui_select"):
    mySprite.material_override.set_shader_param("palette_cycle_speed", 4.0)
    gtdm = gtdm + (low - gtdm) * (delta*real_delta_multiplier)
    if stepify(gtdm, 0.01) == low:
      gtdm = low
      mySprite.material_override.set_shader_param("palette_cycle_speed", 2.5)
      
    mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  else:
    gtdm = gtdm + (high - gtdm) * (delta*real_delta_multiplier)
    mySprite.material_override.set_shader_param("enable_palette_cycle", false)
      
    if stepify(gtdm, 0.01) == high:
      gtdm = high
  global.time_dilation_multiplier = gtdm
  
  
func processGlitchHurtRecovery(delta):
  if physics_state == PhysicsState.GLITCH_HURT:
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
      get_tree().get_root().get_node("Game/Viewport/level").tryToRespawn()
      target_last_grounded_y = global_transform.origin.y
      global.memory["hearts_recovering"] = true
      self.physics_state = PhysicsState.GLITCH_RECOVERY

    return false
  else:
    if glitch_death_timer != 0:
      glitch_death_timer += (delta*22)
      applyGlitchDeathEffects(abs(glitch_death_timer))
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

# @override
func tryDieToEnemy(should_glitch, should_kill_invis):
  if summonedBroom:
    broomStop()

  if not transitioning and (should_kill_invis or (glitch_form != global.GlitchForm.INVISIBLE and \
     physics_state != PhysicsState.GLITCH_DYING and not isOnSavePoint() and \
     physics_state != PhysicsState.GLITCH_HURT and physics_state != PhysicsState.GLITCH_RECOVERY and \
     aniPlayer.assigned_animation != "broomSweep")):
    if randi() % 3 == 0:
      hurt2Sound.pitch_scale = rand_range(0.8, 1.5) 
      hurt2Sound.play()
    else:
      hurtSound.pitch_scale = rand_range(0.8, 1.5)
      hurtSound.play()
    bumpSound.play()
    global.pauseGame = true
    global.pauseMoveInput = true

    if global.canGlitchScreen and should_glitch: # TODO(jaketrower): RESPECT MORE
      level.glitchScreenEffect.visible = true
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

    global.memory["hearts"] -= 1
    if global.memory["hearts"] <= 0:
      global.memory["hearts"] = 0
      global.isRespawning = true
      physics_state = PhysicsState.GLITCH_DYING
      glitch_death_timer = 0
    else:
      physics_state = PhysicsState.GLITCH_HURT
      glitch_death_timer = 0

    
func showInteractPrompt(is_important = false):
  if global.activeInteractor == null:
    if is_important:
      importantInteractPrompt.visible = true
    else:
      interactPrompt.visible = true

func hideInteractPrompt():
  interactPrompt.visible = false
  importantInteractPrompt.visible = false

func processBroomLogic(delta):
  if not (global.memory.has("broom") and global.memory["broom"]):
    broomSpriteVisible.visible = false
    return

  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.flip_h = false
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1

  if not summonedBroom and is_in_broom_cooldown:
    broom_cooldown_timer += (delta*22)
    if broom_cooldown_timer >= broom_cooldown_time_limit:
      broom_cooldown_timer = 0
      is_in_broom_cooldown = false

  if Input.is_action_just_pressed("sub_action_button") and not is_in_broom_cooldown and not summonedBroom:
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("broomSmack")
    if on_ground:
      aniPlayer.queue("stand")
    else:
      aniPlayer.queue("fall")

    is_in_broom_cooldown = true
    broom_cooldown_timer = 0
    if on_ground:
      broom_cooldown_timer = broom_cooldown_time_limit / 2
    # elif glitch_form == global.GlitchForm.FEATHER:
    #   broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
    # velocity_dampener = 2.0
    pauseInput = true
    pauseAnimation = true # TODO(jaketrower): implement this instead
    aniPlayer = null
    if linear_velocity.y < 0:
      linear_velocity.y = 0
    summonedBroom = summonedBroomRes.instance()
    level.add_child(summonedBroom)
    summonedBroom.my_broom_owner = self
    
  if summonedBroom:
    if mySprite.flip_h:
      summonedBroom.global_transform.origin.x = self.global_transform.origin.x - .875
      summonedBroom.rotation_degrees = Vector3(0, 180, 0)
    else:
      summonedBroom.global_transform.origin.x = self.global_transform.origin.x + .875
      summonedBroom.rotation_degrees = Vector3(0, 0, 0)
    summonedBroom.global_transform.origin.y = self.global_transform.origin.y + .625
    summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5
  else:
    broomSpriteVisible.visible = true

func processPoisonWaterLogic(delta):
  var is_touching_poison_water = is_touching_water and touched_water_area != null and touched_water_area.get_node("..").is_poison

  if is_touching_poison_water:
    if glitch_form == global.GlitchForm.INVISIBLE:
      glitchTickle(0)
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
        tryDieToEnemy(true, false)
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
  
  var localAniPlayer = get_node("AnimationPlayer")
  if "broomSmack" in localAniPlayer.current_animation and localAniPlayer.get_queue()[0] == "fall":
    localAniPlayer.clear_queue()
    localAniPlayer.queue("stand")

func broomSmackFast():
  var aniPlayer = get_node("AnimationPlayer")
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("broomSmackFast")
  if on_ground:
    aniPlayer.queue("stand")
  else:
    aniPlayer.queue("fall")
    
func broomStop():
  summonedBroom = null
  broomSpriteVisible.visible = true
  pauseInput = false
  pauseAnimation = false
  aniPlayer = get_node("AnimationPlayer")
  velocity_dampener = 1.0
  if has_sweeped_glitch:
    was_just_on_ground_timer = -8
  if linear_velocity.y < 0:
    linear_velocity.y = 0
  if jump_press_timer < jump_press_broom_time_limit or should_magic_jump:
    jump_press_timer = 0
    if has_sweeped_glitch or should_magic_jump:
      linear_velocity.y = -0.01

func faceDown():
  pass # mySprite.faceDown()

var gimme_mini_crystal_cubes = 0
var gimme_mini_crystal_cubes_timer = 0
var gimme_mini_crystal_cubes_time_limit = 5
func giveMeMiniCrystalCubes(how_many):
  gimme_mini_crystal_cubes = how_many
  gimme_mini_crystal_cubes_timer = 0

func iFellFlat():
  broomSpriteVisible.visible = false

  summonSmokeClouds(5, false, false)

  if global.memory.has("broom") and global.memory["broom"]:
    var fallenBroom = fallenBroomRes.instance()
    level.add_child(fallenBroom)
    fallenBroom.global_transform.origin = self.global_transform.origin
    fallenBroom.global_transform.origin.x += 1
    fallenBroom.global_transform.origin.y += 2
    global.memory["broom"] = false

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
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
