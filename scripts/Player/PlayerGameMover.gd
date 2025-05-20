extends "../GameMover.gd"

enum TransformationState {
  NORMAL,
  FISHY,
  MUSHROOM,
  MOLE_DIGGING,
  UNDERGROUND_RETURNING,
  UNDERGROUND,
  BUBBLE,
  CHICKEN,
  CURSED,
}
var transformation = TransformationState.NORMAL

var broom_timer = 0
var broom_time_limit = 2
var broom_state = 0
var jump_press_timer = 999
var jump_press_time_limit = 5
var jump_press_broom_time_limit = 30
var camera_target_y_pos = 0
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

var remembered_walk_speed = 7
var remembered_feather_glitch_walk_speed = 6
var remembered_invisible_glitch_walk_speed = 5
var camera_y_offset = 1

func _ready():
  set_physics_process(false)
  set_process(true)
  
  should_do_middle_sensor = true
  should_do_simple_sensor_probe = false
  camera_target_y_pos = global_transform.origin.y

func ladderUpdateTargetLastGroundedY():
  camera_target_y_pos = global_transform.origin.y

onready var shroomAniPlayer = get_node("ShroomAnimationPlayer")
func processPauseAnimation():
  if aniPlayer.assigned_animation == "hookCaught":
    return
  
  if is_mushroom_infected:
    pauseAnimation = (not on_ground or (on_ground and (justPressedJump() or recentlyJustPressedJump())))# and not has_mushroom_double_jumped
    if pauseAnimation and aniPlayer.assigned_animation != "walk" and not "etItem" in aniPlayer.assigned_animation:
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("walk")
  
onready var innerSpriteContainer = get_node("SpriteContainer/InnerSpriteContainer")
onready var interactPromptSprite = get_node("InteractPrompt")
var override_camera_y = null
var should_free_when_falling = false
var holding_down_timer = 0
var holding_down_time_limit = 5
var holding_up_timer = 0
var holding_up_time_limit = 5
var stupid_joystick_memory = [false, false, false, false] # lb, rb, tb ,bb
var just_pressed_joystick = [false, false, false, false] # lb, rb, tb , bb
func _process(delta):
  # weird failsafe
  global_transform.origin.z = 0
  if just_pacman_flipped:
    just_pacman_flipped_timer += (delta*11)
    if just_pacman_flipped_timer >= just_pacman_flipped_time_limit:
      just_pacman_flipped_timer = 0
      just_pacman_flipped = false

  if should_big_bump and not physics_state == PhysicsState.BEING_TOSSED:
    should_big_bump = false
    if grav == 0:
      grav = PLAYER_GRAV
    aniPlayer.stop()
    aniPlayer.clear_queue()
    # aniPlayer.play("uncorruptMe")
    aniPlayer.queue("fall")
    fall_timer = 0
  if physics_state == PhysicsState.BEING_TOSSED and should_free_when_falling:
    physics_state = PhysicsState.NORMAL
    should_free_when_falling = false
    pauseAnimation = false
  delta = delta * global.time_dilation_multiplier
  processPauseAnimation()
  if smokeCloudThrottleTimer < smokeCloudThrottleTimeLimit:
    smokeCloudThrottleTimer += (delta*11)

  if is_touching_water or is_touching_ladder or \
     (grav > 0 and global_transform.origin.y < camera_target_y_pos) or \
     (grav < 0 and global_transform.origin.y > camera_target_y_pos):
    camera_target_y_pos = global_transform.origin.y
  
  if jump_press_timer <= jump_press_broom_time_limit:
    jump_press_timer += 1

  if justPressedJump():
    # mushroom_turn_timer = mushroom_turn_time_limit
    jump_press_timer = 0
    if has_sweeped_glitch and global.memory["broom_double_jump"]: # and aniPlayer.assigned_animation == "broomSweep":
      has_sweeped_glitch = false
      camera_target_y_pos = global_transform.origin.y
      if summonedBroom != null:
        broomStop()
      doubleJump()

  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground and was_pressing_horizontal_input and not was_walking_into_wall:
    spawnSparkles(delta)
  elif glitch_form == global.GlitchForm.FEATHER and (pressingJump() or pressingMoveUp()) and not on_ground and feather_jump_timer > feather_jump_time_limit / 3:
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
  if override_camera_y == null:
    cameraTarget.global_transform.origin.y = camera_target_y_pos + camera_y_offset
    if not global.pauseGame:
      if pressingMoveUp() and on_ground:
        if holding_up_timer < holding_up_time_limit:
          holding_up_timer += (delta*11)
      else:
        if not (holding_up_timer >= holding_up_time_limit and pressingMoveUp()):
          holding_up_timer = 0
        if pressingDown() and on_ground:
          if holding_down_timer < holding_down_time_limit:
            holding_down_timer += (delta*11)
        else:
          if not (holding_down_timer >= holding_down_time_limit and pressingDown()):
            holding_down_timer = 0

      if holding_up_timer >= holding_up_time_limit:
        cameraTarget.global_transform.origin.y += 10
      elif holding_down_timer >= holding_down_time_limit:
        cameraTarget.global_transform.origin.y -= 10
  else:
    cameraTarget.global_transform.origin.y = override_camera_y

  adjustStuffForNestingDolls()
  # if global.memory.has("fishingRod") and on_ground and justPressedDown():
  #   aniPlayer.stop()
  #   aniPlayer.clear_queue()
  #   aniPlayer.queue("fishingSitDown")
  var areAnyTilesBelowMeFragile = false
  var solidTilesBelow = getTilesBelow(getLevelTiles())
  for i in range(solidTilesBelow.size()):
    var coords = solidTilesBelow[i]
    if coords == null: continue
    var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
    if getLevelTiles().isTileFragileSolid(tile_type):
      areAnyTilesBelowMeFragile = true
      break
  if pressingDown() and on_ground and not transformation == TransformationState.UNDERGROUND_RETURNING and (dig_timer > 0 or justPressedDown()) and not areAnyTilesBelowMeFragile:
    processMoleDigTimer(Vector3(0, -2, 0))

  just_pressed_joystick = [
    rawPressingAnalogLeft() and not stupid_joystick_memory[0],
    rawPressingAnalogRight() and not stupid_joystick_memory[1],
    rawPressingAnalogUp() and not stupid_joystick_memory[2],
    rawPressingAnalogDown() and not stupid_joystick_memory[3]
  ]
  stupid_joystick_memory = [
    rawPressingAnalogLeft(),
    rawPressingAnalogRight(),
    rawPressingAnalogUp(),
    rawPressingAnalogDown()
  ]
  

    
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
    rb = 0.72
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
  if grav < 0:
    newSparkle.grav_multiplier = -1
  newSparkle.global_transform.origin = self.global_transform.origin
  newSparkle.global_transform.origin.x -= xdiff - (hv.x / 20)
  if grav > 0:
    if above_the_head:
      newSparkle.global_transform.origin.y += 2.3
    else:
      newSparkle.global_transform.origin.y -= 1.3
  else:
    if above_the_head:
      newSparkle.global_transform.origin.y -= 2.3
    else:
      newSparkle.global_transform.origin.y += 1.3
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

onready var spellbookGlitchSprite = get_node("SpriteContainer/InnerSpriteContainer/SpellbookGlitchSprite")
func normalGlitch():
  glitch_form = global.GlitchForm.NORMAL
  level.normalGlitch()
  changeSpriteColorPalette(global.player_base_palette)
  # mySprite.setNormalClothes()

onready var broomSpriteVisible = get_node("SpriteContainer/Sprite3DBroomVisible") 
onready var bubbleSprite = get_node("SpriteContainer/InnerSpriteContainer/BubbleSprite")
onready var chickenSprite = get_node("SpriteContainer/InnerSpriteContainer/ChickenSprite")
onready var fishySprite = get_node("SpriteContainer/InnerSpriteContainer/FishySprite")
onready var moleSprite = get_node("SpriteContainer/InnerSpriteContainer/MoleSprite")
var the_proper_palette = null
func changeSpriteColorPalette(palette):
  if level.spellbook_forbidden:
    return

  the_proper_palette = palette
  # if malware_infected:
  #   return
  mySprite.material_override.set_shader_param("target_palette", palette)
  fishySprite.material_override.set_shader_param("target_palette", palette)
  chickenSprite.material_override.set_shader_param("target_palette", palette)
  # broomSpriteVisible.material_override.set_shader_param("target_palette", palette)

func enemyPushMe(delta, origin, enemy_glitch_form):
  if glitch_form != global.GlitchForm.INVISIBLE or (glitch_form != global.GlitchForm.INVISIBLE and enemy_glitch_form == global.GlitchForm.INVISIBLE):
    return

  var multiplier = 5
  if self.global_transform.origin.x > origin.x:
    self.global_transform.origin.x += (delta * multiplier)
  else:
    self.global_transform.origin.x -= (delta * multiplier)

func playJumpSound():
  if transformation == TransformationState.CHICKEN:
    flapSound.pitch_scale = rand_range(1.2, 1.4)
    flapSound.play()
    summonSmokeClouds(1, false, false, -1)
    summonSmokeClouds(1, false, false, 1)
    return
  elif nesting_doll_state == global.NestingDoll.MATRIARCH:
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
var should_big_bump = false
# @override
func landed():
  if physics_state == PhysicsState.BEING_TOSSED:
    bigBump()
  .landed()
  # chicken_jumps = 0
  can_broomerang_warp = true
  has_sweeped_glitch = false
  global.num_cherries_eaten = global.num_cherries_gained
  has_mushroom_double_jumped = false
  has_used_magic_lantern = false

func isTextboxPausingMe():
  return global.activeInteractor != null and (global.activeInteractor.showYesNoOptions or (
    not rawPressingMoveUp() and not rawPressingMoveDown() and not rawPressingMoveLeft() and not rawPressingMoveRight() and on_ground and not Input.is_action_pressed("jump_button"))
  )

func rawJustPressedAnalogDown():
  return just_pressed_joystick[3]
func rawPressingAnalogDown():
  return global.userSettings["use_joystick"] > 0 and (
    Input.get_joy_axis(0, JOY_AXIS_1) > global.getDeadzone() or # vertical leftstick
    Input.get_joy_axis(0, JOY_AXIS_3) > global.getDeadzone() # vertical rightstick
  )
func rawPressingMoveDown():
  return Input.is_action_pressed("ui_down") or rawPressingAnalogDown()
# @override
func pressingDown():
  var pressingDownButton = rawPressingMoveDown()
  return pressingDownButton and not pauseInput and not isTextboxPausingMe()

# @override
func pressingMoveDown():
  var pressingDownButton = rawPressingMoveDown()
  return pressingDownButton and (not pauseInput or summonedBroom != null) and not isTextboxPausingMe()

func rawJustPressedAnalogUp():
  return just_pressed_joystick[2]
func rawPressingAnalogUp():
  return global.userSettings["use_joystick"] > 0 and (
    Input.get_joy_axis(0, JOY_AXIS_1) < -global.getDeadzone() or # vertical leftstick
    Input.get_joy_axis(0, JOY_AXIS_3) < -global.getDeadzone() # vertical rightstick
  )
func rawPressingMoveUp():
  return Input.is_action_pressed("ui_up") or rawPressingAnalogUp()
# @override
func pressingMoveUp():
  var pressingUpButton = rawPressingMoveUp()
  return pressingUpButton and (not pauseInput or summonedBroom != null) and not isTextboxPausingMe()

var just_pacman_flipped = false
var just_pacman_flipped_timer = 0
var just_pacman_flipped_time_limit = 0
var was_walk_direction_flipped = false
func shouldFlipWalkingDirection():
  return false
  # if just_pacman_flipped:
  #   return was_walk_direction_flipped
  # return (grav < 0 and not transformation == TransformationState.BUBBLE) or malware_infected

var override_stop_left_input = false
func rawJustPressedAnalogLeft():
  return just_pressed_joystick[0]
func rawPressingAnalogLeft():
  return global.userSettings["use_joystick"] > 0 and (
    Input.get_joy_axis(0, JOY_AXIS_0) < -global.getDeadzone() or # horizontal leftstick
    Input.get_joy_axis(0, JOY_AXIS_2) < -global.getDeadzone() # horizontal rightstick
  )
func rawJustPressedAnalogRight():
  return just_pressed_joystick[1]
func rawPressingMoveLeft():
  return Input.is_action_pressed("ui_left") or rawPressingAnalogLeft()
func rawPressingAnalogRight():
  return global.userSettings["use_joystick"] > 0 and (
    Input.get_joy_axis(0, JOY_AXIS_0) > global.getDeadzone() or # horizontal leftstick
    Input.get_joy_axis(0, JOY_AXIS_2) > global.getDeadzone() # horizontal rightstick
  )
func rawPressingMoveRight():
  return Input.is_action_pressed("ui_right") or rawPressingAnalogRight()
# @override
func pressingMoveLeft():
  if override_stop_left_input or physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  var am_paused = pauseInput or isTextboxPausingMe()

  var pressingLeftButton = rawPressingMoveLeft()
  var pressingRightButton = rawPressingMoveRight()

  if shouldFlipWalkingDirection():
    return pressingRightButton and not am_paused
  if is_mushroom_infected:
    return mushroom_infection_direction == -1 and not am_paused
  var is_pressing_move_left = .pressingMoveLeft() or (pressingLeftButton and not am_paused)
  return is_pressing_move_left

var override_stop_right_input = false
# @override
func pressingMoveRight():
  if override_stop_right_input or physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  var am_paused = pauseInput or isTextboxPausingMe()

  var pressingLeftButton = rawPressingMoveLeft()
  var pressingRightButton = rawPressingMoveRight()

  if shouldFlipWalkingDirection():
    return pressingLeftButton and not am_paused
  if is_mushroom_infected:
    return mushroom_infection_direction == 1 and not am_paused
  var is_pressing_move_right = .pressingMoveRight() or (pressingRightButton and not am_paused)
  return is_pressing_move_right

func justPressedEnterDoor():
  return (
    (global.userSettings["doorDir"] > 0 and (Input.is_action_just_pressed("ui_up") or just_pressed_joystick[2])) or
    (global.userSettings["doorDir"] < 0 and (Input.is_action_just_pressed("ui_down") or just_pressed_joystick[3]))
  )

# mostly used for turn based input, so not as important?
# @override
func justPressedDown():
  var justPressedDownButton = Input.is_action_just_pressed("ui_down") or rawJustPressedAnalogDown()
  return justPressedDownButton and not pauseInput and not isTextboxPausingMe()
# these next two are also turn based movement...
# @override
func justPressedMoveLeft():
  # if malware_infected:
  #   return pressingMoveLeft() and Input.is_action_just_pressed("ui_right")
  return pressingMoveLeft() and (Input.is_action_just_pressed("ui_left") or rawJustPressedAnalogLeft())

# @override
func justPressedMoveRight():
  # if malware_infected:
  #   return pressingMoveRight() and Input.is_action_just_pressed("ui_left")
  return pressingMoveRight() and (Input.is_action_just_pressed("ui_right") or rawJustPressedAnalogRight())

func justPressedMenuUp():
  return rawJustPressedAnalogUp() or Input.is_action_just_pressed("menu_up")
func justPressedMenuDown():
  return rawJustPressedAnalogDown() or Input.is_action_just_pressed("menu_down")
func justPressedMenuLeft():
  return rawJustPressedAnalogLeft() or Input.is_action_just_pressed("menu_left")
func justPressedMenuRight():
  return rawJustPressedAnalogRight() or Input.is_action_just_pressed("menu_right")
  

# @override
func justPressedJump():
  if isItWeird():
    return false
  if transformation == TransformationState.CHICKEN:
    return should_magic_jump or ((pressingMoveRight() or pressingMoveLeft()) and truly_on_ground) or Input.is_action_just_pressed("jump_button")
  # if is_mushroom_infected:
  #   return false
  if Input.is_action_just_pressed("talk_button") and global.activeInteractor != null:
    return should_magic_jump
  return (
    (
      Input.is_action_just_pressed("jump_button") or
      # TODO(jaketrower): this could be generalized for sweep and other stuff more elegantly...
      (
        (
          global.userSettings["controls_config"] != null and 
          global.userSettings["controls_config"][global.JUMP_INDEX] != null and
          global.userSettings["controls_config"][global.JUMP_INDEX].has("button_index")
        ) and (
          (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_LEFT and just_pressed_joystick[0]) or
          (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_RIGHT and just_pressed_joystick[1]) or
          (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_UP and just_pressed_joystick[2]) or
          (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_DOWN and just_pressed_joystick[3]))
        )
    ) and
    (not pauseInput or has_sweeped_glitch) and not isTextboxPausingMe()
  ) or should_magic_jump
  
# @override
func recentlyJustPressedJump():
  if isItWeird():
    return false
  # if is_mushroom_infected:
  #   return false
  return jump_press_timer < jump_press_time_limit

# @override
func tryingToWakeUp():
  return Input.is_action_just_pressed("sub_action_button")

var malware_infected = false
var PLAYER_GRAV = 28
onready var digSound2 = get_node("Sounds/DigSound2")
var dig_timer = 0
var dig_time_limit = 4
var dig_below_timer = 0
var dig_below_time_limit = 5
var can_dig_up = false
var dig_smoke_timer = 0
var dig_smoke_time_limit = 3
var dig_direction = null
# @override
func collideWithWall(local_lv):
  .collideWithWall(local_lv)
  if physics_state == PhysicsState.BEING_TOSSED:
    pauseAnimation = false
    physics_state = PhysicsState.NORMAL
    on_ground = true # needs to be BEFORE tryDieToEnemy to set remembered_on_ground correctly
    bigBump()
    getABroom()
  if grav == 0:
    grav = PLAYER_GRAV
  var tile_buffer = 0.5 if glitch_form == global.GlitchForm.INVISIBLE else 0.1
  if pressingMoveLeft():
    var leftTiles = getTilesLeftOf(getLevelTiles(), tile_buffer, glitch_form == global.GlitchForm.INVISIBLE)
    var touching_fragile_solid = false
    var touching_spikes = false
    for i in range(leftTiles.size()):
      var coords = leftTiles[i]
      if coords == null: continue
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if not touching_fragile_solid and getLevelTiles().isTileFragileSolid(tile_type):
        glitchTickle()
        touching_fragile_solid = true
      if not touching_spikes and getLevelTiles().isTileSpikes(tile_type):
        touching_spikes = true
    # if on_ground and not touching_fragile_solid and not pressingJump():
    #   processMoleDigTimer(Vector3(-2, 0, 0))
    # else:
    #   dig_timer = 0
  if pressingMoveRight():
    var rightTiles = getTilesRightOf(getLevelTiles(), tile_buffer, glitch_form == global.GlitchForm.INVISIBLE)
    var touching_fragile_solid = false
    var touching_spikes = false
    for i in range(rightTiles.size()):
      var coords = rightTiles[i]
      if coords == null: continue
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if not touching_fragile_solid and getLevelTiles().isTileFragileSolid(tile_type):
        glitchTickle()
        touching_fragile_solid = true
      if not touching_spikes and getLevelTiles().isTileSpikes(tile_type):
        touching_spikes = true
    # if on_ground and not touching_fragile_solid and not pressingJump(): # and (glitch_form == global.GlitchForm.FLOOR or (glitch_form == global.GlitchForm.INVISIBLE and touching_spikes)):
    #   processMoleDigTimer(Vector3(2, 0, 0))
    # else:
    #   dig_timer = 0

onready var digSound = get_node("Sounds/DigSound")
func processMoleDigTimer(digDirection):
  if isItWeird() or global.memory["mole_cricket"] == 0 or not global.memory["mole_cricket_enabled"] or global.pauseGame:
    dig_timer = 0
    return

  dig_timer += (secret_delta*11)
  # on_ground = true
  # mySprite.flip_h = not mySprite.flip_h
  dig_direction = digDirection
  glitchTickle()
  glitchTilesAroundMe(-1)
  if dig_timer > dig_time_limit:
    can_dig_up = false
    tryClearFallthroughCollisionSolid(self.global_transform.origin)
    transformation = TransformationState.UNDERGROUND_RETURNING
    mySprite.visible = false
    global.memory["broom"] = false
    moleSprite.visible = false
    summonSmokeClouds(3, true, true, 0)
    global_transform.origin += digDirection / 2
    digSound.play()
    physics_vars.should_apply_gravity = false
    should_collide_floor = false
    should_collide_ceil = false
    should_collide_horizontally = false

var glitch_death_timer = 0
func bigBump():
  if grav == 0:
    grav = PLAYER_GRAV
  bumpSound2.play()
  # var prev_hp = global.memory["hp"]
  # global.memory["hp"] += 1
  # tryDieToEnemy(0, false, true, false)
  # global.memory["hp"] = prev_hp
  # glitchTilesAroundMe()
  glitchTickle()
  getSmacked()
  # if global.userSettings["canGlitchScreen"]:
  #   level.glitchScreenEffect.visible = true
  #   glitch_death_timer = 25
  fall_timer = 0
  pauseAnimation = false
  should_big_bump = false
  aniPlayer.stop()
  aniPlayer.clear_queue()
  # aniPlayer.play("uncorruptMe")
  aniPlayer.queue("fall")

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

# @override
func pressingJump():
  if isItWeird():
    return false
  if transformation == TransformationState.CHICKEN:
    return should_magic_jump or ((pressingMoveRight() or pressingMoveLeft()) and truly_on_ground) or Input.is_action_pressed("jump_button")
  if transformation == TransformationState.UNDERGROUND or transformation == TransformationState.UNDERGROUND_RETURNING:
    return false
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    return false
  if physics_state == PhysicsState.BEING_TOSSED or physics_state == PhysicsState.OCCUPIED:
    return false
  # if is_mushroom_infected:
  #   return false
  var is_pressing_jump = (
        (
          Input.is_action_pressed("jump_button") or \
          # TODO(jaketrower): this could be generalized for sweep and other stuff more elegantly...
          ((
            global.userSettings["controls_config"] != null and 
            global.userSettings["controls_config"][global.JUMP_INDEX] != null and
            global.userSettings["controls_config"][global.JUMP_INDEX].has("button_index")
          ) and 
            ((global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_LEFT and rawPressingAnalogLeft()) or \
            (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_RIGHT and rawPressingAnalogRight()) or \
            (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_UP and rawPressingAnalogUp()) or \
            (global.userSettings["controls_config"][global.JUMP_INDEX].button_index == JOY_DPAD_DOWN and rawPressingAnalogDown()))
          )
        ) and \
        (not pauseInput or summonedBroom != null) and \
        not isTextboxPausingMe()
      ) or should_magic_jump
  # if is_pressing_jump:
  #   should_collide_floor = true
  return is_pressing_jump

# @overrride
func actuallyApplyJump(play_sound = true):
  # if malware_infected:
  #   on_ground = false
  #   was_fallthrough_area_collision_triggered = false
  #   has_just_jumped_timer = 0
  # else:
  .actuallyApplyJump(play_sound)

func magicJump():
  has_used_magic_lantern = true
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
    pauseAnimation = false
  if physics_state == PhysicsState.COLLAPSED or physics_state == PhysicsState.CAN_WAKE_UP or physics_state == PhysicsState.WAKING_UP:
    physics_state = PhysicsState.NORMAL
    pauseAnimation = false
    getABroom()
  should_magic_jump = true
  actuallyApplyJump(false)
  tryClearFallthroughCollisionSolid(self.global_transform.origin)

onready var dollOpenSound = get_node("Sounds/DollOpenSound")
onready var dollCloseSound = get_node("Sounds/DollCloseSound")
func updateNestingDoll(prevNestingDollState, shouldSpawnCarcass = true):
  global.memory["nesting_doll"] = nesting_doll_state
  if nesting_doll_state < prevNestingDollState:
    if shouldSpawnCarcass:
      var emptyDoll = spawnACarcass()
      if nesting_doll_state == global.NestingDoll.BABY:
        emptyDoll.mySprite.material_override.set_shader_param("texture_albedo", spriteSheetSmall)
        emptyDoll.fallthroughSolidCollisionShape.translation.y = 0.6
      # elif nesting_doll_state == global.NestingDoll.MOM:
      #   emptyDoll.broomSprite.visible = global.memory["broom"]
      # if randi() % 4 == 1:
      #   emptyDoll.mySprite.flip_h = not emptyDoll.mySprite.flip_h
      nesting_doll_array.push_back(emptyDoll)
    if nesting_doll_state == global.NestingDoll.BABY:
      dollOpenSound.pitch_scale = 1.2
    elif nesting_doll_state == global.NestingDoll.MOM:
      dollOpenSound.pitch_scale = 0.95
      # global.memory["had_broom"] = global.memory["broom"]
      # global.memory["broom"] = false
    dollOpenSound.play()
  elif nesting_doll_state > prevNestingDollState and nesting_doll_array.size() > 0:
    var emptyDoll = nesting_doll_array.pop_back()
    emptyDoll.queue_free()
    if nesting_doll_state == global.NestingDoll.MOM:
      dollCloseSound.pitch_scale = 1.1
    elif nesting_doll_state == global.NestingDoll.GRANDMA:
      dollCloseSound.pitch_scale = 0.9
      # global.memory["broom"] = global.memory["had_broom"] or global.memory["broom"]
    dollCloseSound.play()

  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)
  elif nesting_doll_state == global.NestingDoll.GRANDMA:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
    smallCollisionShape.shape.radius = 0.543
    smallCollisionShape.shape.radius = 2.032
  elif nesting_doll_state == global.NestingDoll.MOM:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetSmall)
    smallCollisionShape.shape.radius = 0.543
    smallCollisionShape.shape.radius = 2.032
  elif nesting_doll_state == global.NestingDoll.BABY:
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)
    smallCollisionShape.shape.radius = 0.25
    smallCollisionShape.shape.radius = 0.75

  if nesting_doll_state == global.NestingDoll.BABY:
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
  return getWalkSpeedHelper(delta) * (1.0 if not isItWeird() else 0.5)

func isItWeird():
  return "PrimordialOozeRoom" in level.getShortLevelName() or "IntroVideo" in level.getShortLevelName()

func isItKindaWeird():
  return "EndCredits" in level.getShortLevelName()

func getWalkSpeedHelper(delta):
  if transformation == TransformationState.CHICKEN:
    return 6
  if transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND:
    return 0
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
    # if is_mushroom_infected:
    #   if mushroom_infection_direction < 0:
    #     if Input.is_action_pressed("ui_left"):
    #       return 4
    #     else: return 2
    #   else:
    #     if Input.is_action_pressed("ui_right"):
    #       return 4
    #     else: return 2
    return .getWalkSpeed(delta) # super()

func doIHaveSpell(which_spell):
  if glitch_form == which_spell:
    return true
  if global.memory.has("spellbookPage"):
    for spell in global.memory["spellbookPage"]:
      if spell == which_spell:
        return true
  return false

func findSpellInSpellbook(which_spell):
  if glitch_form == which_spell:
    return -1
  if global.memory.has("spellbookPage"):
    for i in len(global.memory["spellbookPage"]):
      var spell = global.memory["spellbookPage"][i]
      if spell == which_spell:
        return i
  return -1

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

  camera_target_y_pos = global_transform.origin.y

var smacked_npc = null
var is_in_broom_cooldown = false
var has_broom_flown = false
var has_landed_since_last_flight = false
func getABroom(unpauseAnimation = true):
  var fallenBroomArray = self.get_tree().get_nodes_in_group("fallen_broom_group")
  for fallenBroom in fallenBroomArray:
    if fallenBroom.visible and not fallenBroom.should_die_on_land and not fallenBroom.is_dying and fallenBroom.should_return:
      return

  #transformation == TransformationState.FISHY or \
  if glitch_form == global.GlitchForm.INVISIBLE or \
     transformation == TransformationState.UNDERGROUND_RETURNING or \
     transformation == TransformationState.UNDERGROUND or \
     transformation == TransformationState.MOLE_DIGGING or \
     (transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE) or \
     transformation == TransformationState.CHICKEN or \
     is_mushroom_infected: # or malware_infected:
    return
  pauseAnimation = not unpauseAnimation
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

func broomStop():
  if summonedBroom != null:
    summonedBroom.queue_free()
  summonedBroom = null
  if global.has_really_started_game:
    pauseInput = false
    global.pauseMoveInput = false
  pauseAnimation = false
  walk_speed = remembered_walk_speed
  feather_glitch_walk_speed = remembered_feather_glitch_walk_speed
  invisible_glitch_walk_speed = remembered_invisible_glitch_walk_speed
  if transformation != TransformationState.FISHY:
    if has_sweeped_glitch and global.memory["broom_double_jump"]:
      was_just_on_ground_timer = was_just_on_ground_time_limit
    if linear_velocity.y < 0:
      linear_velocity.y = 0
    if jump_press_timer < jump_press_broom_time_limit or should_magic_jump:
      jump_press_timer = 0
      if (has_sweeped_glitch and global.memory["broom_double_jump"]) or should_magic_jump:
        linear_velocity.y = -0.01
    aniPlayer.stop()
    aniPlayer.clear_queue()
    if on_ground:
      aniPlayer.queue("stand")
    else:
      aniPlayer.queue("fall")
  smacked_npc = null
  if not isHoldingMultiBroom():
    broomSpriteVisible.visible = true

var secretMultiBroom = null
func isHoldingMultiBroom():
  return secretMultiBroom != null and \
         global.memory["multi_broom"] and \
         Input.is_action_pressed("sub_action_button") and \
         not (
          physics_state == PhysicsState.GLITCH_DYING or \
          physics_state == PhysicsState.GLITCH_HURT or \
          physics_state == PhysicsState.IGNORE_PHYSICS
         )

onready var infectSound = get_node("Sounds/InfectSound")
onready var infectReverseSound = get_node("Sounds/InfectReverseSound")
onready var wormSound = get_node("Sounds/WormSound")
onready var gravitySound = get_node("Sounds/GravitySound")
onready var gravitySound2 = get_node("Sounds/GravitySound2")
onready var flapSound = get_node("Sounds/FlapSound")
onready var fastStepSound = get_node("Sounds/FastStepSound")
var has_mushroom_double_jumped = false
var mush_carcasses = []
var max_num_mush_carcasses = 3
var chicken_jumps = 0
var MAX_CHICKEN_JUMPS = 7
func processJumpInputs(delta):
  if transformation == TransformationState.CHICKEN:
    was_just_on_ground_timer = -8
    if vv <= 0 and justPressedJump() and not on_ground:
      chicken_jumps += 1
      if chicken_jumps >= MAX_CHICKEN_JUMPS:
        getChickenCured()
    .processJumpInputs(delta)
    return

  if not is_touching_ladder and not is_touching_water and not isKindaSortaOfOnGround() and not on_ground:
    var triedToDoubleJump = justPressedJump() and not should_magic_jump and not global.pauseMoveInput
    # if global.memory["magic_lantern"] and not has_used_magic_lantern and triedToDoubleJump:
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
    if glitch_form == global.GlitchForm.NORMAL and global.memory["can_nest"] and global.memory["nesting_doll"] > 1 and triedToDoubleJump and not has_mushroom_double_jumped: 
      doubleJump()
      nesting_doll_state -= 1
      updateNestingDoll(nesting_doll_state + 1)
      glitchTickle()
        
  .processJumpInputs(delta)

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

var my_carcasses = []
func mushroomClone(_trigger_another = true):
  if smallInteractionArea.is_touching_carcass:
    global_transform.origin.y += 1
  global_transform.origin.y += 1
  if not on_ground:
    global_transform.origin.y += 0.5
  doubleJump()
  var carcass = spawnACarcass()
  carcass.smallInteractionArea.is_touching_carcass = true
  carcass.broomSprite.visible = false
  carcass.mushroomSprite.visible = false
  # carcass.is_crumbling = true
  my_carcasses.push_back(carcass)
  if len(my_carcasses) > 6:
    var crumbled_carcass = my_carcasses.pop_front()
    crumbled_carcass.queue_free()
  infectSound.play()
  glitchTickle()
  # if trigger_another:
  #   yield(get_tree().create_timer(0.1), "timeout")
  #   mushroomClone(false)


# @override
func addJumpSmokeCloud(flip_flip_h = false):
  if transformation == TransformationState.FISHY:
    return
  if transformation == TransformationState.MOLE_DIGGING:
    return
  if transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND:
    return
  .addJumpSmokeCloud(flip_flip_h)

onready var sporeSound = get_node("Sounds/SporeSound")
func playStickOnWallSound():
  sporeSound.pitch_scale = 2.0
  sporeSound.play()

onready var tickleSound = get_node("Sounds/TickleSound")
onready var malwareSound = get_node("Sounds/MalwareSound")
var glitch_tickle_timer = 0
func glitchTickle(play_sound = true):
  glitch_tickle_timer = 1
  mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  mySprite.material_override.set_shader_param("shake_power", 0.01)
  mySprite.material_override.set_shader_param("shake_color_rate", 0.01)
  mySprite.material_override.set_shader_param("time_influence", 30)
  mySprite.material_override.set_shader_param("y_div", 2.0)
  mySprite.material_override.set_shader_param("normal_offset", 0.15)
  if play_sound:
    if malware_infected:
      malwareSound.play()
    else:
      tickleSound.pitch_scale = 0.5
      tickleSound.play()

var sporeRes = preload("res://sceneObjects/Environment/CatSpore.tscn")
func spawnASpore(where_origin, inverse):
  var spore = sporeRes.instance()
  level.add_child(spore)
  spore.global_transform.origin = where_origin
  spore.global_transform.origin.z = where_origin.z + 2.0

  if inverse:
    spore.global_transform.origin.x += rand_range(-3, 3)
    spore.global_transform.origin.y += rand_range(-3, 3)
    var r = 1
    spore.target_pos = Vector2(global_transform.origin.x + rand_range(-r, r), global_transform.origin.y + rand_range(-r, r))
    spore.delta_multiplier = 2.0
    spore.mySprite.get_ref().reverseIt()
  else:
    spore.global_transform.origin.x += rand_range(-1, 1)
    spore.global_transform.origin.y += rand_range(-1, 1)
    var r = 2
    spore.target_pos = Vector2(spore.global_transform.origin.x + rand_range(-r, r), spore.global_transform.origin.y + rand_range(-r, r))
    spore.delta_multiplier = 4.0

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
    

var touching_glitch_or_spikes = false
# @override
func handleSpikeCollisions(delta):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  
  var TILE_WIDTH = levelTiles.cell_size.x
  var TILE_HEIGHT = levelTiles.cell_size.y

  touching_glitch_or_spikes = false
  var amt = 0.0 #0.5 if should_big_bump else 0.0
  for i in range(int(round(y+bb-amt)), int(round(y+tb+amt))):
    for j in range(int(round(x+lb-amt)), int(round(x+rb+amt))):
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
        # if should_big_bump:
        #   getLevelTiles().infectSpikes(coords)
        #   has_sweeped_glitch = true
        # else:
        tryDieToEnemy(delta, true, false)
        return

# @override
func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
  var is_tile_solid = .isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords)
  var is_tile_spikes = getLevelTiles().isTileSpikes(tile_type)
  if glitch_form == global.GlitchForm.INVISIBLE:
    return is_tile_solid or is_tile_spikes
  return is_tile_solid

# @override
func isTouchingSpikes(collisionShape):
  if glitch_form == global.GlitchForm.INVISIBLE:
    return false
  return .isTouchingSpikes(collisionShape)
