extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")

var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 20
var is_in_broom_cooldown = false

onready var interactPrompt = get_node("InteractPrompt")
onready var importantInteractPrompt = get_node("ImportantInteractPrompt")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var glitch_death_timer = 0
var can_cast_spell_timer = 0
var can_cast_spell_time_limit = 10

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
  changeSpriteColorPalette(getLevelTiles().green_palette)
  # mySprite.setMothCostume()

func ladderGlitch():
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  changeSpriteColorPalette(getLevelTiles().yellow_palette)
  # mySprite.setLuckyCatCostume()

func invisibleGlitch():
  glitch_form = global.GlitchForm.INVISIBLE
  level.invisibleGlitch()
  changeSpriteColorPalette(getLevelTiles().black_palette)
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
  
  delta = delta * global.time_dilation_multiplier
  if not processGlitchHurtRecovery(delta):
    return

  if global.pauseGame or global.pauseMoveInput or physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT:
    return
    
  # doTimeDilation(real_delta)
  if global.memory.has("broom"):
    processBroomLogic(delta)

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

  #tryRotateCamera(delta)
  
func tryDieToOffscreenCamera():
  var DEATH_MARGIN = 5
  if getGameCamera().rightmost_x > -999:
    if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
    global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
    global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
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
        self.physics_state = PhysicsState.NORMAL

    return true

func applyGlitchDeathEffects(x):
  if global.canChangeSongPitch and (x < 0 or x > 20):
    musicPlayer.changeSongPitch(abs(sin(x*.05)+.02))
  if x > 10:
    var my_material = mySprite.get_material_override()
    if my_material is ShaderMaterial:
      my_material.set_shader_param("enable_glitch", self.physics_state == PhysicsState.GLITCH_RECOVERY)

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

# @override
func tryDieToEnemy(should_glitch, should_kill_invis):
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

    if global.canGlitchScreen and should_glitch:
      level.glitchScreenEffect.visible = true
    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      material.set_shader_param("shake_power", 0.01)
      material.set_shader_param("shake_color_rate", 0.01)
    var my_material = mySprite.get_material_override()
    if my_material is ShaderMaterial:
      my_material.set_shader_param("enable_glitch", true)
    
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
  if not pauseSelf and is_in_broom_cooldown:
    broom_cooldown_timer += (delta*22)
    if broom_cooldown_timer >= broom_cooldown_time_limit:
      broom_cooldown_timer = 0
      is_in_broom_cooldown = false

  if Input.is_action_just_pressed("sub_action_button") and not pauseSelf and not is_in_broom_cooldown:
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("broomSweep")
    if on_ground:
      aniPlayer.queue("stand")
    else:
      aniPlayer.queue("fall")

    is_in_broom_cooldown = true
    broom_cooldown_timer = 0
    if on_ground:
      broom_cooldown_timer = broom_cooldown_time_limit / 2
    elif glitch_form == global.GlitchForm.FEATHER:
      broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
    pauseSelf = true
    if linear_velocity.y < 0:
      linear_velocity.y = 0
    var broom = summonedBroomRes.instance()
    level.add_child(broom)
    if mySprite.flip_h:
      broom.get_node("Sprite3D").flip_h = true
      broom.global_transform.origin.x = self.global_transform.origin.x - 1.558
    else:
      broom.get_node("Sprite3D").flip_h = false
      broom.global_transform.origin.x = self.global_transform.origin.x + 1.557
    broom.global_transform.origin.y = self.global_transform.origin.y
    broom.my_broom_owner = self
    
# @override
func landed():
  .landed()
  target_last_grounded_y = global_transform.origin.y
  broom_cooldown_timer = 0
  is_in_broom_cooldown = false
    
func broomStop():
  pauseSelf = false
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
