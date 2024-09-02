extends "../GameMover.gd"

enum TransformationState {
  NORMAL,
  FISHY,
  MUSHROOM,
  UNDERGROUND,
  UNDERGROUND_RETURNING,
  BUBBLE,
}
var transformation = TransformationState.NORMAL

var broom_timer = 0
var broom_time_limit = 2
var broom_state = 0
var jump_press_timer = 999
var jump_press_time_limit = 5
var jump_press_broom_time_limit = 30
var target_last_grounded_y = 0
var pauseInput = false

var has_played_fall_sound = false

var has_sweeped_glitch = false
var has_sweeped_cloud = false

var cherryCarcassRes = preload("res://sceneObjects/CherryCarcass.tscn")
var spriteSheet = preload("res://assets/player_sheet_old.png")
var spriteSheetNoBroom = preload("res://assets/player_sheet_old_nobroom.png")
var spriteSheetTiny = preload("res://assets/player_sheet_old_baby.png")
var broomSpriteSheet = preload("res://assets/player_sheet_broom.png")
var broomSpriteSheetTiny = preload("res://assets/player_sheet_broom_tiny.png")
var spriteSheetSmall = preload("res://assets/player_sheet_tiny.png")
var nesting_doll_state = global.NestingDoll.GRANDMA
var nesting_doll_array = []


onready var nullifySound = get_node("Sounds/NullifySound")
onready var rechargeSound = get_node("Sounds/RechargeSound")
onready var cameraTarget = get_node("CameraTarget")
onready var smallCollisionShape = get_node("SmallInteractionArea/CollisionShape") if has_node("SmallInteractionArea/CollisionShape") else null
var camera_target_origin_x_target = 0

var sparkleRes = preload("res://sceneObjects/Sparkle.tscn")
var sparkle_timer = 7
var sparkle_time_limit = 8
var blink_timer = 0
var blink_time_limit = 20
var is_blinked = false
var unblink_time_limit = 5

var showMpTimer = 0
var showMpTimeLimit = 60
var is_mushroom_infected = false
var is_dust_infected = false
var mushroom_infection_direction = 1
var mushroom_turn_timer = 0
var mushroom_turn_time_limit = 6
var has_used_magic_lantern = false

func _ready():
  set_physics_process(false)
  set_process(true)
  
  should_do_middle_sensor = true
  should_do_simple_sensor_probe = false
  target_last_grounded_y = global_transform.origin.y

func ladderUpdateTargetLastGroundedY():
  target_last_grounded_y = global_transform.origin.y

onready var shroomAniPlayer = get_node("ShroomAnimationPlayer")
func processPauseAnimation():
  if aniPlayer.assigned_animation == "hookCaught":
    return
  
  # if is_mushroom_infected:
  #   pauseAnimation = (not on_ground or (on_ground and (justPressedJump() or recentlyJustPressedJump()))) and not has_mushroom_double_jumped
  #   if pauseAnimation and aniPlayer.assigned_animation != "walk" and not "etItem" in aniPlayer.assigned_animation:
  #     aniPlayer.stop()
  #     aniPlayer.clear_queue()
  #     aniPlayer.play("walk")
  
onready var innerSpriteContainer = get_node("SpriteContainer/InnerSpriteContainer")
onready var interactPromptSprite = get_node("InteractPrompt")
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  processPauseAnimation()
  if smokeCloudThrottleTimer < smokeCloudThrottleTimeLimit:
    smokeCloudThrottleTimer += (delta*11)

  if is_touching_water or is_touching_ladder or \
     (grav > 0 and global_transform.origin.y < target_last_grounded_y) or \
     (grav < 0 and global_transform.origin.y > target_last_grounded_y):
    target_last_grounded_y = global_transform.origin.y
  
  if jump_press_timer <= jump_press_broom_time_limit:
    jump_press_timer += 1

  if justPressedJump():
    # mushroom_turn_timer = mushroom_turn_time_limit
    jump_press_timer = 0
    if has_sweeped_glitch and aniPlayer.assigned_animation == "broomSweep":
      has_sweeped_glitch = false
      target_last_grounded_y = global_transform.origin.y
      magicJump()

  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground and was_pressing_horizontal_input and not was_walking_into_wall:
    spawnSparkles(delta)
  elif glitch_form == global.GlitchForm.FEATHER and pressingJump() and not on_ground and feather_jump_timer > feather_jump_time_limit / 3:
    spawnSparkles(delta)
  elif glitch_form == global.GlitchForm.LADDER and was_walking_into_wall:
    spawnSparkles(delta)
  elif glitch_form == global.GlitchForm.INVISIBLE:
    pass
  else:
    sparkle_timer = sparkle_time_limit - 2
    
  # this is a little weird but fixes the fallthrough area situation:
  if linear_velocity.y < 0:
    if nesting_doll_state == global.NestingDoll.BABY:
      interactionArea.transform.origin.y = -0.5
    else:
      interactionArea.transform.origin.y = -2
  else:
    interactionArea.transform.origin.y = 0
    
  if linear_velocity.x > 0.5:
    camera_target_origin_x_target = 2
  elif linear_velocity.x < -0.5:
    camera_target_origin_x_target = -2

  cameraTarget.transform.origin.x = cameraTarget.transform.origin.x + (camera_target_origin_x_target - cameraTarget.transform.origin.x) * (delta*5)
  if stepify(cameraTarget.transform.origin.x, 0.1) == stepify(camera_target_origin_x_target, 0.1):
    cameraTarget.transform.origin.x = camera_target_origin_x_target
  cameraTarget.global_transform.origin.y = target_last_grounded_y

  adjustStuffForNestingDolls()
  # if global.memory.has("fishingRod") and on_ground and justPressedDown():
  #   aniPlayer.stop()
  #   aniPlayer.clear_queue()
  #   aniPlayer.queue("fishingSitDown")
    
onready var tileCollisionShape = get_node("TileArea/CollisionShape")
onready var interactionShape = get_node("InteractionArea/CollisionShape")
func adjustStuffForNestingDolls():
  # if nesting_doll_state < 2 and Input.is_action_just_pressed("sub_action_button"):
  #   regainNestingDoll()
  #   has_mushroom_double_jumped = true

  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    jump_force = 14
    tb = 2
    bb = -2
    lb = -1.3
    rb = 1.3
    should_only_do_middle_sensor = false
    cheating_horizontal_offset = 0
    smallCollisionShape.shape.height = 4
    smallCollisionShape.shape.radius = 1.5
    interactionShape.shape.extents = Vector3(1.4, 2.4, 3)
    spriteYAlignment = 0.5
    innerSpriteContainer.scale = Vector3(2.0, 2.0, 1.0)
  elif nesting_doll_state == global.NestingDoll.BABY:
    jump_force = 9
    tb = 0.5
    bb = -0.5
    lb = -0.5
    rb = .5
    should_only_do_middle_sensor = true
    cheating_horizontal_offset = bb / 2.0
    smallCollisionShape.shape.height = 1.0
    smallCollisionShape.shape.radius = .5
    interactionShape.shape.extents = Vector3(0.35, 0.6, 3)
    spriteYAlignment = 0.65
    innerSpriteContainer.scale = Vector3(1.0, 1.0, 1.0)
  else:
    jump_force = 9
    tb = 1
    bb = -1
    lb = -0.72
    rb = .72
    should_only_do_middle_sensor = false
    cheating_horizontal_offset = 0
    smallCollisionShape.shape.height = 2.032
    smallCollisionShape.shape.radius = .543
    interactionShape.shape.extents = Vector3(0.7, 1.2, 3)
    spriteYAlignment = 0.25
    innerSpriteContainer.scale = Vector3(1.0, 1.0, 1.0)

  if grav < 0:
    spriteYAlignment = 0 - spriteYAlignment
  
  tileCollisionShape.shape.extents.x = rb
  tileCollisionShape.shape.extents.y = tb
    

func spawnOneSparkle(xdiff, above_the_head = false):
  var newSparkle = sparkleRes.instance()
  level.add_child(newSparkle)
  newSparkle.global_transform.origin = self.global_transform.origin
  newSparkle.global_transform.origin.x -= xdiff - (hv.x / 20)
  if above_the_head:
    newSparkle.global_transform.origin.y += 2.3
  else:
    newSparkle.global_transform.origin.y -= 1.3
  newSparkle.global_transform.origin.z -= 5.0
  newSparkle.get_material_override().set_shader_param(
    "target_palette", 
    mySprite.material_override.get_shader_param("target_palette")
  )

func spawnSparkles(delta, above_the_head = false):
  if pauseSelf or pauseAnimation or global.pauseGame or global.pauseMoveInput: return

  sparkle_timer += (delta*22)
  if sparkle_timer >= sparkle_time_limit:
    
    spawnOneSparkle(.5, above_the_head)
    spawnOneSparkle(-.5, above_the_head)
    sparkle_timer = 0
  # if global.memory["mp"] > 0:
  #   sparkle_timer += (delta*22)
  #   if sparkle_timer >= sparkle_time_limit:
  #     global.memory["mp"] -= 1
  #     showMpTimer = 0
      
  #     spawnOneSparkle(.5, above_the_head)
  #     spawnOneSparkle(-.5, above_the_head)
  #     sparkle_timer = 0
  #     if global.memory["mp"] == 0:
  #       # mySprite.get_material_override().set_shader_param("opacity", 1.0)
  #       self.normalGlitch()
  #       nullifySound.play()
  #       blink_timer = 0
  #       blink_time_limit = 20
  #       is_blinked = false

onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite")
func normalGlitch():
  glitch_form = global.GlitchForm.NORMAL
  level.normalGlitch()
  changeSpriteColorPalette(global.player_base_palette)
  # mySprite.setNormalClothes()

onready var broomSpriteVisible = get_node("SpriteContainer/Sprite3DBroomVisible") 
func changeSpriteColorPalette(palette):
  if level.spellbook_forbidden:
    return

  mySprite.material_override.set_shader_param("target_palette", palette)
  # broomSpriteVisible.material_override.set_shader_param("target_palette", palette)

func bodyPushMe(_delta, _origin):
  pass # no more
  # if not on_ground or is_pressing_horizontal_input:
  #   return

  # var multiplier = 5
  # if self.global_transform.origin.x > origin.x:
  #   self.global_transform.origin.x += (delta * multiplier)
  # else:
  #   self.global_transform.origin.x -= (delta * multiplier)

func playJumpSound():
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    jumpSound.pitch_scale = rand_range(0.5, 0.6)
  elif nesting_doll_state == global.NestingDoll.BABY:
    jumpSound.pitch_scale = rand_range(1.2, 1.4)
  else:
    jumpSound.pitch_scale = rand_range(0.8, 1.2)
  .playJumpSound()

onready var bumpSound2 = get_node("Sounds/BumpSound2")
func playLandSound():
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    bumpSound2.play()
  else:
    .playLandSound()

var can_broomerang_warp = true
# @override
func landed():
  .landed()
  can_broomerang_warp = true
  has_sweeped_glitch = false
  global.num_cherries_eaten = global.num_cherries_gained
  has_mushroom_double_jumped = false
  has_used_magic_lantern = false

func isTextboxPausingMe():
   return global.activeInteractor != null # and not global.activeInteractor.is_tiny

# @override
func justPressedDown():
  return Input.is_action_just_pressed("ui_down") and not pauseInput and not isTextboxPausingMe()

# @override
func pressingDown():
  return Input.is_action_pressed("ui_down") and not pauseInput and not isTextboxPausingMe()

# @override
func justPressedJump():
  return (Input.is_action_just_pressed("jump_button") and not pauseInput and not isTextboxPausingMe()) or should_magic_jump
  
# @override
func recentlyJustPressedJump():
  return jump_press_timer < jump_press_time_limit

# @override
func tryingToWakeUp():
  return Input.is_action_just_pressed("sub_action_button")

# @override
func pressingJump():
  if transformation == TransformationState.UNDERGROUND:
    return false
  if physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  var is_pressing_jump = (Input.is_action_pressed("jump_button") and (not pauseInput or summonedBroom != null) and not isTextboxPausingMe()) or should_magic_jump
  # if is_pressing_jump:
  #   should_collide_floor = true
  return is_pressing_jump

# @override
func pressingMoveUp():
  return Input.is_action_pressed("ui_up") and (not pauseInput or summonedBroom != null) and not isTextboxPausingMe()
  
# @override
func pressingMoveDown():
  return Input.is_action_pressed("ui_down") and (not pauseInput or summonedBroom != null) and not isTextboxPausingMe()
  
var override_stop_left_input = false
# @override
func pressingMoveLeft():
  if override_stop_left_input or physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  var am_paused = pauseInput or isTextboxPausingMe()
  if is_mushroom_infected:
    should_collide_floor = true
    return mushroom_infection_direction == -1 and not am_paused
  var is_pressing_move_left = .pressingMoveLeft() or (Input.is_action_pressed("ui_left") and not am_paused)
  # if is_pressing_move_left:
  #   should_collide_floor = true
  return is_pressing_move_left

var override_stop_right_input = false
# @override
func pressingMoveRight():
  if override_stop_right_input or physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  var am_paused =  pauseInput or isTextboxPausingMe()
  if is_mushroom_infected:
    # should_collide_floor = true
    return mushroom_infection_direction == 1 and not am_paused
  var is_pressing_move_right = .pressingMoveRight() or (Input.is_action_pressed("ui_right") and not am_paused)
  # if is_pressing_move_right:
  #   should_collide_floor = true
  return is_pressing_move_right

# @override
func justPressedMoveLeft():
  return pressingMoveLeft() and Input.is_action_just_pressed("ui_left")

# @override
func justPressedMoveRight():
  return pressingMoveRight() and Input.is_action_just_pressed("ui_right")

func magicJump():
  has_used_magic_lantern = true
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
    pauseAnimation = false
  should_magic_jump = true
  actuallyApplyJump(false)
  tryClearFallthroughCollisionSolid()

onready var dollOpenSound = get_node("Sounds/DollOpenSound")
onready var dollCloseSound = get_node("Sounds/DollCloseSound")
func updateNestingDoll(prevNestingDollState):
  global.memory["nesting_doll"] = nesting_doll_state
  if nesting_doll_state < prevNestingDollState:
    var emptyDoll = spawnACarcass()
    if nesting_doll_state == global.NestingDoll.BABY:
      emptyDoll.mySprite.material_override.set_shader_param("texture_albedo", spriteSheetSmall)
      emptyDoll.fallthroughSolidCollisionShape.translation.y = 0.6
    elif nesting_doll_state == global.NestingDoll.MOM:
      emptyDoll.broomSprite.visible = global.memory["broom"]
    # if randi() % 4 == 1:
    #   emptyDoll.mySprite.flip_h = not emptyDoll.mySprite.flip_h
    nesting_doll_array.push_back(emptyDoll)
    if nesting_doll_state == global.NestingDoll.BABY:
      dollOpenSound.pitch_scale = 1.2
    elif nesting_doll_state == global.NestingDoll.MOM:
      dollOpenSound.pitch_scale = 0.95
      global.memory["had_broom"] = global.memory["broom"]
      global.memory["broom"] = false
    dollOpenSound.play()
  elif nesting_doll_state > prevNestingDollState and nesting_doll_array.size() > 0:
    var emptyDoll = nesting_doll_array.pop_back()
    emptyDoll.queue_free()
    if nesting_doll_state == global.NestingDoll.MOM:
      dollCloseSound.pitch_scale = 1.1
    elif nesting_doll_state == global.NestingDoll.GRANDMA:
      dollCloseSound.pitch_scale = 0.9
      global.memory["broom"] = global.memory["had_broom"] or global.memory["broom"]
    dollCloseSound.play()

  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)
  elif nesting_doll_state == global.NestingDoll.GRANDMA:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  elif nesting_doll_state == global.NestingDoll.MOM:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetSmall)
  elif nesting_doll_state == global.NestingDoll.BABY:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)

  if nesting_doll_state == global.NestingDoll.MOM:
    broomSpriteVisible.material_override.set_shader_param("texture_albedo", broomSpriteSheetTiny)
  else:
    broomSpriteVisible.material_override.set_shader_param("texture_albedo", broomSpriteSheet)

func spawnACarcass():
  var carcass = cherryCarcassRes.instance()
  level.add_child(carcass)
  carcass.global_transform.origin = self.global_transform.origin
  carcass.mySprite.flip_h = mySprite.flip_h
  carcass.mySprite.material_override.set_shader_param(
    "target_palette", mySprite.material_override.get_shader_param("target_palette"))
  return carcass
    

func regainNestingDoll():
  if nesting_doll_state < 2:
    nesting_doll_state += 1
    updateNestingDoll(nesting_doll_state - 1)
    glitchTickle()
  # has_mushroom_double_jumped = true

var summonedBroom = null
# @override
func getWalkSpeed(delta):
  if transformation == TransformationState.UNDERGROUND:
    return 7
  # var is_really_pressing_horizontal_input = (pressingRun() and on_ground) or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
  if aniPlayer.assigned_animation == "sweepFloor":
    return 2
  elif nesting_doll_state == global.NestingDoll.BABY:
    return 9
  elif nesting_doll_state == global.NestingDoll.MATRIARCH:
    return 6 if pressingRun() else 5
  elif transformation == TransformationState.FISHY or nesting_doll_state == global.NestingDoll.MOM:
    return 7
  else:
    if is_mushroom_infected:
      if mushroom_infection_direction < 0:
        if Input.is_action_pressed("ui_left"):
          return 4
        else: return 2
      else:
        if Input.is_action_pressed("ui_right"):
          return 4
        else: return 2
    return .getWalkSpeed(delta) # super()

func doubleJump():
  was_just_on_ground_timer = was_just_on_ground_time_limit
  jumped_from_true_ground = truly_on_ground
  jump_squat_jump_input_timer = 1
  feather_jump_timer = 0
  weak_feather_dbl_jump = false
  magicJump()

  aniPlayer.clear_queue()
  aniPlayer.play("jumpSquat", -1, 1.0 if isFeatherLike() else 1.0)
  aniPlayer.queue("jumpStart")
  aniPlayer.queue("jump")

  target_last_grounded_y = global_transform.origin.y

var smacked_npc = null
var is_in_broom_cooldown = false
var has_broom_flown = false
var has_landed_since_last_flight = false
func getABroom(unpauseAnimation = true):
  pauseAnimation = not unpauseAnimation
  if transformation == TransformationState.FISHY or \
     transformation == TransformationState.UNDERGROUND or transformation == TransformationState.UNDERGROUND_RETURNING or \
     transformation == TransformationState.BUBBLE:
    return
  global.memory["broom"] = true
  global.memory["has_gotten_broom"] = 2
  if nesting_doll_state == global.NestingDoll.GRANDMA:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  smacked_npc = null
  is_in_broom_cooldown = false
  has_broom_flown = not has_landed_since_last_flight
  var ps = physics_state
  if ps == PhysicsState.COLLAPSED or ps == PhysicsState.CAN_WAKE_UP or ps == PhysicsState.WAKING_UP:
    physics_state = PhysicsState.NORMAL

onready var infectSound = get_node("Sounds/InfectSound")
onready var wormSound = get_node("Sounds/WormSound")
onready var gravitySound = get_node("Sounds/GravitySound")
onready var fastStepSound = get_node("Sounds/FastStepSound")
var has_mushroom_double_jumped = false
var mush_carcasses = []
var max_num_mush_carcasses = 3
func processJumpInputs(delta):
  if not is_touching_ladder and not is_touching_water and not isKindaSortaOfOnGround() and not on_ground:
    var triedToDoubleJump = justPressedJump() and not should_magic_jump and not global.pauseMoveInput
    # if global.memory["magic_lantern"] and not has_used_magic_lantern and triedToDoubleJump:
    #   global.memory["grav_direction"] = -global.memory["grav_direction"]
    #   gravitySound.play()
    #   level.flipGravity()
    #   has_used_magic_lantern = true
    #   was_just_on_ground_timer = was_just_on_ground_time_limit
    #   glitchTickle()
    # elif is_mushroom_infected and not has_mushroom_double_jumped and triedToDoubleJump:
    #   has_mushroom_double_jumped = true
    #   feather_jump_timer = 0
    #   wormSound.play()
    #   # var turning_left = mushroom_infection_direction == 1 and Input.is_action_pressed("ui_left")
    #   # var turning_right = mushroom_infection_direction == -1 and Input.is_action_pressed("ui_right")
    #   # if turning_left or turning_right:
    #   #   mushroom_infection_direction = -mushroom_infection_direction
    #   for _i in range(5):
    #     spawnASpore(0, -1)
    #   # is_mushroom_infected = false
    #   summonSmokeClouds(2, true, true)
    #   aniPlayer.clear_queue()
    #   aniPlayer.play("jumpSquat", -1, 1.0 if isFeatherLike() else 1.0)
    #   aniPlayer.queue("jumpStart")
    #   aniPlayer.queue("jump")
    if glitch_form == global.GlitchForm.NORMAL and global.memory["can_nest"] and global.memory["nesting_doll"] > 1 and triedToDoubleJump and not has_mushroom_double_jumped and not is_mushroom_infected: 
      doubleJump()
      nesting_doll_state -= 1
      updateNestingDoll(nesting_doll_state + 1)
      glitchTickle()
        
  .processJumpInputs(delta)

func mushroomClone(trigger_another = true):
  global_transform.origin.y += 1
  if not on_ground:
    global_transform.origin.y += 0.5
  doubleJump()
  var carcass = spawnACarcass()
  carcass.broomSprite.visible = false
  carcass.mushroomSprite.visible = false
  infectSound.play()
  glitchTickle()
  if trigger_another:
    yield(get_tree().create_timer(0.1), "timeout")
    mushroomClone(false)


# @override
func addJumpSmokeCloud(flip_flip_h = false):
  if transformation == TransformationState.FISHY:
    return
  if transformation == TransformationState.UNDERGROUND:
    return
  if transformation == TransformationState.UNDERGROUND_RETURNING:
    return
  .addJumpSmokeCloud(flip_flip_h)

onready var sporeSound = get_node("Sounds/SporeSound")
func playStickOnWallSound():
  sporeSound.play()

onready var tickleSound = get_node("Sounds/TickleSound")
var glitch_tickle_timer = 0
func glitchTickle(play_sound = true):
  glitch_tickle_timer = 1
  mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  mySprite.material_override.set_shader_param("shake_power", 0.01)
  mySprite.material_override.set_shader_param("shake_color_rate", 0.01)
  if play_sound:
    tickleSound.pitch_scale = 0.5
    tickleSound.play()

var sporeRes = preload("res://sceneObjects/Environment/PlayerSpore.tscn")
func spawnASpore(x_dir = 0, y_dir = 1):
  # summonSmokeClouds(1, 0, 0, 0)
  var spore = sporeRes.instance()
  if y_dir == 1:
    spore.initially_fly_up = true
  level.add_child(spore)
  spore.global_transform.origin = self.global_transform.origin
  spore.original_pos = self.global_transform.origin
  if y_dir == 1:
    spore.bubble_speed = -rand_range(1.925, 2.8)
  elif y_dir == -1:
    spore.bubble_speed = rand_range(1.925, 2.8)
  spore.target_pos.x = self.global_transform.origin.x + rand_range(-1, 1)
  if x_dir == 1:
    if mySprite.flip_h:
      spore.global_transform.origin.x -= 1
      spore.target_pos.x = self.global_transform.origin.x + rand_range(-2, -1)
    else:
      spore.global_transform.origin.x += 1
      spore.target_pos.x = self.global_transform.origin.x + rand_range(1, 2)
  spore.delta_multiplier = 4.0
  spore.global_transform.origin.x += rand_range(-.5, .5)
  spore.global_transform.origin.y += 1.5
  spore.global_transform.origin.y += rand_range(0, .225)
  spore.is_active = false

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var smokeCloudThrottleTimer = 0
var smokeCloudThrottleTimeLimit = 4
func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false, horizontal = 0, only_on_ground = false, throttle = false):
    if throttle and smokeCloudThrottleTimer < smokeCloudThrottleTimeLimit:
      return
    smokeCloudThrottleTimer = 0
    if only_on_ground and not truly_on_ground:
      return
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
            newSmokeCloud.tryPlaySound()
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())
    

# @override
func handleSpikeCollisions(delta):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  
  var TILE_WIDTH = levelTiles.cell_size.x
  var TILE_HEIGHT = levelTiles.cell_size.y

  for i in range(int(round(y+bb)), int(round(y+tb))):
    for j in range(int(round(x+lb)), int(round(x+rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
      var tile_x = tile_pos.x - TILE_WIDTH/2
      var tile_y = tile_pos.y - TILE_HEIGHT/2
      if (
        (getLevelTiles().isTileSpikes(tile_type) and not getLevelTiles().isNeighborOfInfectedSpikes(coords))
          or getLevelTiles().isTileGlitchSpikes(tile_type) 
        ) and isRectColliding(
        tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
        x + lb, y + tb, x + rb, y + bb
      ):
        tryDieToEnemy(delta, true, false)
        return

# @override
func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
  var is_tile_solid = .isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords)
  var is_tile_spikes = getLevelTiles().isTileSpikes(tile_type)
  if nesting_doll_state == global.NestingDoll.MOM:
    return is_tile_solid or is_tile_spikes
  return is_tile_solid

# @override
func isTouchingSpikes(collisionShape):
  if nesting_doll_state == global.NestingDoll.MOM:
    return false
  return .isTouchingSpikes(collisionShape)
