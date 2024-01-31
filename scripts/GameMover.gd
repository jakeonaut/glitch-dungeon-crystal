extends Spatial

# TODO(jaketrower): This "class" is monolithic when it should be Modular... but how in gdscript?

onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null
onready var fallSound = get_node("Sounds/FallSound") if has_node("Sounds/FallSound") else null
onready var jumpSound = get_node("Sounds/JumpSound") if has_node("Sounds/JumpSound") else null
onready var doubleJumpSound = get_node("Sounds/DoubleJumpSound") if has_node("Sounds/DoubleJumpSound") else null
onready var wetJumpSound = get_node("Sounds/WetJumpSound") if has_node("Sounds/WetJumpSound") else null
onready var runSound = get_node("Sounds/RunSound") if has_node("Sounds/RunSound") else null

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var collidedTiles = []

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles
  
var gameCamera = null
func getGameCamera():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

onready var smallInteractionArea = get_node("SmallInteractionArea") if has_node("SmallInteractionArea") else null
onready var interactionArea = get_node("InteractionArea") if has_node("InteractionArea") else null
onready var aniPlayer = get_node("AnimationPlayer") if has_node("AnimationPlayer") else null
onready var bounceAniPlayer = get_node("BounceAnimationPlayer") if has_node("BounceAnimationPlayer") else null
var animation_speed_multiplier = 1.0
onready var mySprite = get_node("SpriteContainer/InnerSpriteContainer/Sprite3D") if has_node("SpriteContainer/InnerSpriteContainer/Sprite3D") else get_node("Sprite3D")

export var true_terminal_vel = 32
var true_terminal_feather_vel = 2 
var water_terminal_vel = 4
var water_fall_terminal = 8
var hit_water_terminal_vel = 1
var terminal_vel = true_terminal_vel
var is_touching_water = false
var is_touching_waterfall = false
var touched_water_area = null
var was_touching_water = false
var was_touching_water_at_start_of_jump = false
var is_touching_ladder = false
var is_climbing_ladder = false
var on_ground = true
var was_on_ground = true
var truly_on_ground = false
var half_on_ground = false
var should_teeter_turn_around = false
var jumped_from_true_ground = false
# used for Donkey Kong style coyote time jumps
var was_just_on_ground_timer = 0
var was_just_on_ground_time_limit = 12
var just_landed = false
var spawn_origin
var last_grounded_pos = Vector3(0, 0, 0)
var falling_y_offset = 16
var fall_timer = 0
var fall_time_max = 50
var should_collide_horizontally = true
var should_collide_floor = true 
var should_collide_ceil = true
var should_do_middle_sensor = false
var should_only_do_middle_sensor = false
var should_do_simple_sensor_probe = true
var should_do_fallthrough_area_collision = false
var fallthrough_area_collision_y = 0
var should_always_do_jump_smoke_cloud = false
var lb = -0.72
var rb = .72
var tb = 1
var bb = -1
var grav_direction = Vector3(0, -1, 0)


var jumpSmokeCloudRes = preload("res://sceneObjects/JumpSmokeCloud.tscn")

enum PhysicsState {
  NORMAL,
  OCCUPIED,
  BEING_TOSSED,
  COLLAPSED,
  CAN_WAKE_UP,
  WAKING_UP,
  GLITCH_DYING,
  GLITCH_HURT,
  GLITCH_RECOVERY,
  IGNORE_PHYSICS,
}
var physics_state = PhysicsState.NORMAL
var ignorePhysics = false

var linear_velocity = Vector3()
var lv = linear_velocity
var velocity_dampener = 1.0
var pauseAnimation = false

export var grav = 60
var applyHalfGrav = false
var applyHalfGravTimer = 0
var applyHalfGravTimeLimit = 10
var g = Vector3(0, -grav, 0) if grav != 0 else Vector3(0, -1, 0)

# TODO(jaketrower): Maybe should remove dir, and only rely on linear_velocity ?
var dir = Vector3(0, 0, 0)
var prev_dir = dir
var up = -g.normalized() # (up is against gravity)
var vv = up.dot(lv) # vertical velocity
var last_vv = vv
var hv = lv - up * vv # horizontal velocity

export var walk_speed = 8
export var run_speed = 10
# export var fast_run_speed = 12
  
var glitch_form = global.GlitchForm.NORMAL
var prev_glitch_form = global.GlitchForm.NORMAL
var feather_jump_timer = 0
var feather_jump_time_limit = 8
var feather_jump_partial_time_limit = 12
var weak_feather_dbl_jump = false

func isFeatherLike():
  return glitch_form == global.GlitchForm.FEATHER

# Physics variables
export var feather_glitch_walk_speed = 9
export var floor_glitch_walk_speed = 3
export var invisible_glitch_walk_speed = 6
export var swimming_walk_speed = 6
var should_magic_jump = false
export var jump_force = 16
export var invisible_jump_force = 14
var has_just_jumped_timer = 0
var has_just_jumped_time_limit = 200# 3
# TODO(jaketrower): This is dumb and should be like a boolean or state, oh well
var jump_squat_jump_input_timer = 0
# TODO(jaketrower): dedupe with is_pressing_horizontal_input
var is_walking = false
var is_pressing_horizontal_input = false
var was_pressing_horizontal_input = false
var num_horizontal_input_presses = 0
var horizontal_input_reset_timer = 0
var horizontal_input_reset_time_limit = 3
var facing = Vector3(0, 0, 1) #default to facing "down" toward the player behind the screen
var transitioning = false
var is_falling = false
var was_walking_into_wall = false
var pauseSelf = false

var horizontal_collision = false
var vertical_collision = false

var DNUMHORZ = 65.0
var DNUMSKID_BASE = 54.0

var staticLevelZoneVar = null
func getMyStaticLevelZoneVar(refresh_if_null = false):
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if staticLevelZoneVar == null or refresh_if_null:
    staticLevelZoneVar = global.getStaticLevelZoneLevelVar(level, self.name)
  return staticLevelZoneVar

func _ready():
  set_process(true)
  set_physics_process(true)
  if true_terminal_vel == null: true_terminal_vel = 32

  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  spawn_origin = global_transform.origin
  last_grounded_pos = Vector3(spawn_origin.x, spawn_origin.y, spawn_origin.z)

func _process(_delta):
  if mySprite.has_method("glitchyTrySetFrame"):
    mySprite.is_really_glitchy = is_really_glitchy 
  # TODO(jaketrower): It would be much better to get an aniPlayer class / hook that could be used.
  # rather than have to do this conditional check every time
  if aniPlayer:
    aniPlayer.playback_speed = global.time_dilation_multiplier * animation_speed_multiplier

func _physics_process(delta):
  if global.pauseGame or pauseSelf: return
  if jump_force == null: jump_force = 16

  if smallInteractionArea:
    is_touching_water = smallInteractionArea.is_touching_water
    is_touching_waterfall = smallInteractionArea.is_touching_waterfall
    touched_water_area = smallInteractionArea.touched_water_area
    is_touching_ladder = smallInteractionArea.is_touching_ladder
  # if not is_touching_water:
    has_water_double_jumped = false

  DNUMHORZ = 65.0 * global.time_dilation_multiplier
  DNUMSKID_BASE = 54.0 / global.time_dilation_multiplier
  processPhysics(delta * global.time_dilation_multiplier)

  if not on_ground and translation.y < (last_grounded_pos.y - falling_y_offset) and not transitioning:
    is_falling = true

  alignMySprite()

var spriteYAlignment = 0.25
func alignMySprite():
  var pixelSize = 0.125
  if mySprite:
    mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + spriteYAlignment
     
func isActive():
  return visible

# aka func ouchies() for player
func tryDieToEnemy(_delta, _should_glitch, _should_kill_invis, _should_immediately_die = false):
  pass    
  
func getHitByBroom():
  pass

func processPhysics(delta):
  if grav == null: grav = 0 # ???

  if physics_state == PhysicsState.IGNORE_PHYSICS or ignorePhysics:
    return

  lv = linear_velocity

  applyGravity(delta)
  g = Vector3(0, -grav, 0) if grav != 0 else Vector3(0, -1, 0)
  
  up = -g.normalized() # (up is against gravity)
  vv = up.dot(lv) # vertical velocity
  hv = lv - up * vv # horizontal velocity
  
  applyTerminalVelocity(delta)
  
  if physics_state == PhysicsState.NORMAL or physics_state == PhysicsState.GLITCH_RECOVERY:
    processInputs(delta)
  elif physics_state == PhysicsState.COLLAPSED:
    hv = Vector3()
    dir = Vector3(0.0, 0.0, 0.0)
    if pauseAnimation or aniPlayer == null or not aniPlayer.is_playing():
      physics_state = PhysicsState.CAN_WAKE_UP
  elif physics_state == PhysicsState.CAN_WAKE_UP:
    var pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight()
    var pressing_jump = justPressedJump() or recentlyJustPressedJump()
    if not global.pauseMoveInput and (pressing_horizontal_input or pressing_jump or pressingDown() or not on_ground):
      if not pauseAnimation and aniPlayer:
        aniPlayer.play("wakeup")
      if bounceAniPlayer:
        playBounce("wakeup")
      physics_state = PhysicsState.WAKING_UP
  elif physics_state == PhysicsState.WAKING_UP:
    if aniPlayer == null or not aniPlayer.is_playing():
      physics_state = PhysicsState.NORMAL
    
  lv = hv + (up * vv)
  
  linear_velocity = handleCollisionsAndMove(lv, delta)
  last_vv = vv

  postProcessInputs(delta)
  prev_dir = dir
  
  just_landed = false
  if not was_on_ground and on_ground: # I just landed!!
    processLand()
  # TODO(jaketrower): all this animation code IS going to break everything one day :)
  var aa = ""
  if not pauseAnimation and aniPlayer != null:
    aa = aniPlayer.assigned_animation
  if not pauseAnimation and aniPlayer != null and not global.pauseGame and not aa == "getItem":
    if not is_climbing_ladder:
      if on_ground:
        if (aa == "land" or aa == "walkStart") and not aniPlayer.is_playing():
          aniPlayer.play("stand")
        elif aa == "jump" or aa == "jumpBump" or aa == "fall" or aa == "fallBump":
          playLandAnimation()
      elif linear_velocity.y > 0 and not "jump" in aa and not "Jump" in aa and not "fall" in aa and not (glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall()):
        aniPlayer.stop()
        aniPlayer.clear_queue()
        # if is_touching_water:
        #   aniPlayer.queue("swimJump")
        # else:
        aniPlayer.queue("fall" if isFeatherLike() else "jump")

  if was_on_ground and not on_ground: # I just fell off platform!
    was_just_on_ground_timer = 0
    if prev_glitch_form == global.GlitchForm.FLOOR and glitch_form != global.GlitchForm.FLOOR:
      was_just_on_ground_timer = -4
    if "jump" in aa:
      was_just_on_ground_timer = was_just_on_ground_time_limit
  was_touching_water = is_touching_water

  if was_just_on_ground_timer <= was_just_on_ground_time_limit:
    was_just_on_ground_timer += (delta*22)
    if glitch_form == global.GlitchForm.FEATHER:
      was_just_on_ground_timer += (delta*44)
  was_pressing_horizontal_input = is_pressing_horizontal_input
  if not is_pressing_horizontal_input and num_horizontal_input_presses > 0:
    horizontal_input_reset_timer += (delta*11)
    if horizontal_input_reset_timer >= horizontal_input_reset_time_limit:
      num_horizontal_input_presses = 0
  else:
    horizontal_input_reset_timer = 0
  prev_glitch_form = glitch_form

func playLandAnimation():
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("land", -1, 0.5 if isFeatherLike() else 1.5)

func tryClearFallthroughCollisionSolid():
  if self != level.player:
    return
  if interactionArea and interactionArea.prev_fallthrough_collision_area != null and \
      interactionArea.prev_fallthrough_collision_area.get_node("..").has_method("fallthroughCollisionClear"):
    interactionArea.prev_fallthrough_collision_area.get_node("..").fallthroughCollisionClear(self)

func processLand():
  landed()
  if (getGameCamera().rightmost_x == -999 or not (
    # global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
    global_transform.origin.x > getGameCamera().rightmost_x - 2 or \
    global_transform.origin.x < getGameCamera().leftmost_x + 2 or \
    global_transform.origin.y < getGameCamera().botmost_y + 2)) and not global.isAMoleDigging \
    and not grav < 0:
      last_grounded_pos = Vector3(global_transform.origin)
  just_landed = true
    
var should_apply_gravity = true
func applyGravity(delta):
  if applyHalfGrav:
    applyHalfGravTimer += (delta*22)
    if applyHalfGravTimer >= applyHalfGravTimeLimit:
      applyHalfGravTimer = 0
      applyHalfGrav = 0

  if not should_apply_gravity:
    return
  if is_touching_water or applyHalfGrav:
    g = Vector3(0, -grav/3, 0)
    if is_touching_waterfall:
      g = Vector3(0, -grav/2, 0)
    if fallSound:
      fallSound.stop()
  elif isFeatherLike():
    if pressingDown():
      g = Vector3(0, -grav*2, 0)
    else:
      g = Vector3(0, -grav/1.5, 0)
  else:
    if pressingDown():
      g = Vector3(0, -grav*2, 0)
    else:
      g = Vector3(0, -grav, 0)

  if not is_climbing_ladder and (not on_ground or glitch_form != global.GlitchForm.FLOOR):
    lv += g * delta
    if on_ground or physics_state == PhysicsState.OCCUPIED:
      fall_timer = 0
    elif physics_state == PhysicsState.BEING_TOSSED or (glitch_form != global.GlitchForm.FEATHER and vv < -1 and not is_touching_water):
      fall_timer += (delta*22)
    elif (glitch_form == global.GlitchForm.FEATHER or vv > 0) and physics_state != PhysicsState.BEING_TOSSED:
      fall_timer = 0
    if lv.y < 0:
      if not on_ground and not pauseAnimation and aniPlayer != null:
        var a = aniPlayer.current_animation
        if (a != "jumpSquat" and a != "jumpStart" and \
          a != "fall" and a != "fallStart" and \
          a != "fallFar" and a != "swimJumpStart" and \
          a != "swimFall" and a != "fallBump"):
          aniPlayer.clear_queue()
          aniPlayer.stop()
          if is_touching_water:
            aniPlayer.queue("swimFall")
          else:
            if aniPlayer.has_animation("fallStart"): aniPlayer.queue("fallStart")
            if aniPlayer.has_animation("fall"): aniPlayer.queue("fall")
      if fall_timer > 40 and not pauseAnimation and aniPlayer != null and \
         aniPlayer.current_animation != "fallFar" and aniPlayer.has_animation("fallFar"):
        aniPlayer.clear_queue()
        aniPlayer.stop()
        aniPlayer.play("fallFar")
        if not transitioning and fallSound: fallSound.play()
      

func applyTerminalVelocity(_delta):
  if is_touching_water:
    if not was_touching_water:
      terminal_vel = hit_water_terminal_vel
    elif is_touching_waterfall:
      terminal_vel = true_terminal_vel * 1.2
    elif pressingJump():
      terminal_vel = water_terminal_vel/2
    elif pressingDown():
      terminal_vel = water_fall_terminal
    else:
      terminal_vel = water_terminal_vel
  elif glitch_form == global.GlitchForm.FEATHER:
    if pressingJump() or pressingMoveUp():
      terminal_vel = true_terminal_feather_vel
    elif pressingDown():
      terminal_vel = true_terminal_vel * .75
    else:
      terminal_vel = true_terminal_vel / 2
  elif glitch_form == global.GlitchForm.LADDER:
    terminal_vel = true_terminal_vel
  else:
    terminal_vel = true_terminal_vel

  if vv < -terminal_vel: #  or (glitch_form == global.GlitchForm.LADDER and vv <= 0 and (aniPlayer == null or aniPlayer.assigned_animation != "sinkInSand")):
    vv = -terminal_vel
  if grav < 0 and vv > terminal_vel:
    vv = terminal_vel

  if (glitch_form == global.GlitchForm.FLOOR or not should_collide_floor) and on_ground:
    vv = 0
    
func getTilesBelow(currLevelTiles):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  var coords_a = currLevelTiles.world_to_map(Vector3(x + lb, y + bb - 0.1, z))
  var tile_pos_a = currLevelTiles.map_to_world(coords_a.x, coords_a.y, coords_a.z)
  var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

  var coords_b = currLevelTiles.world_to_map(Vector3(x + rb, y + bb - 0.1, z))
  var tile_pos_b = currLevelTiles.map_to_world(coords_b.x, coords_b.y, coords_b.z)
  var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

  var coords_mid = currLevelTiles.world_to_map(Vector3(x, y + bb - 0.1, z))
  var tile_pos_mid = currLevelTiles.map_to_world(coords_mid.x, coords_mid.y, coords_mid.z)
  var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

  var solidTilesBelow = [null, null, null]
  if isTileSolid(tile_type_a, true, 1, tile_pos_a):
    solidTilesBelow[0] = coords_a
  if isTileSolid(tile_type_mid, true, 1, tile_pos_mid):
    solidTilesBelow[1] = coords_mid
  if isTileSolid(tile_type_b, true, 1, tile_pos_b):
    solidTilesBelow[2] = coords_b

  return solidTilesBelow

func getTilesLeftOf(currLevelTiles):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  # this can be genralized...
  var coords_a = currLevelTiles.world_to_map(Vector3(x + lb - 0.1, y + tb, z))
  var tile_pos_a = currLevelTiles.map_to_world(coords_a.x, coords_a.y, coords_a.z)
  var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

  var coords_b = currLevelTiles.world_to_map(Vector3(x + lb - 0.1, y + bb, z))
  var tile_pos_b = currLevelTiles.map_to_world(coords_b.x, coords_b.y, coords_b.z)
  var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

  var coords_mid = currLevelTiles.world_to_map(Vector3(x + lb - 0.1, y, z))
  var tile_pos_mid = currLevelTiles.map_to_world(coords_mid.x, coords_mid.y, coords_mid.z)
  var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

  var solidTilesLeftOf = [null, null, null]
  if isTileSolid(tile_type_a, true, 1, tile_pos_a):
    solidTilesLeftOf[0] = coords_a
  if isTileSolid(tile_type_mid, true, 1, tile_pos_mid):
    solidTilesLeftOf[1] = coords_mid
  if isTileSolid(tile_type_b, true, 1, tile_pos_b):
    solidTilesLeftOf[2] = coords_b

  return solidTilesLeftOf

func iJustPressedDown():
  on_ground = false
  should_do_fallthrough_area_collision = false

func processInputs(delta):
  processLadderInputs(delta)
  processJumpInputs(delta)
  processHorizontalInputs(delta)
  if justPressedDown():
    iJustPressedDown()

  # fail safe...
  if vv > jump_force*2:
    vv = jump_force*2
  if was_walking_into_wall and not isWalkingIntoWall() and glitch_form == global.GlitchForm.LADDER:
    vv = 1
  was_walking_into_wall = isWalkingIntoWall()
  if was_walking_into_wall and glitch_form == global.GlitchForm.LADDER and not global.pauseMoveInput:
    if aniPlayer.assigned_animation == "sinkInSand":
      vv = 1
    elif pauseAnimation:
      vv = 0
    else:
      vv = getWalkSpeed(delta)
    if not pauseAnimation and aniPlayer != null and aniPlayer.assigned_animation == "stand":
      aniPlayer.stop()
      # aniPlayer.queue("walkBump")
      aniPlayer.queue("walk")
    should_do_fallthrough_area_collision = false
    ladderUpdateTargetLastGroundedY()

func ladderUpdateTargetLastGroundedY():
  pass

func justPressedDown():
  return false
  
func pressingDown():
  return false

var running_timer = 0
var running_time_limit = 15
func canRun():
  return false

func canSwim():
  return true

func pressingRun():
  if not canRun():
    return false
  return num_horizontal_input_presses >= 2 or running_timer > running_time_limit

func startRun():
  if not canRun():
    return
  var origin = Vector3(self.global_transform.origin.x, self.global_transform.origin.y - 1, 0)
  if runSound:
    runSound.play()
  level.summonSmokeClouds(origin, 3, false, false)

func justPressedJump():
  return false
  
func recentlyJustPressedJump():
  return false


func pressingJump():
  return false

func pressingMoveUp():
  return false

func pressingMoveDown():
  return false

func pressingMoveLeft():
  return false

func pressingMoveRight():
  return false

func processLadderInputs(_delta):
  if global.pauseMoveInput: return

  if is_touching_ladder:
    if not is_climbing_ladder and (pressingMoveUp() or pressingMoveDown()):
      is_climbing_ladder = true
      dir = Vector3(0, 0, 0)
      on_ground = true
      if not pauseAnimation and aniPlayer != null:
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.play("climb")
  else:
    if is_climbing_ladder:
      is_climbing_ladder = false
      if not is_touching_water:
        on_ground = true
        vv = 0

  if is_climbing_ladder:
    var climb_speed = walk_speed

    if pressingMoveUp():
      vv = climb_speed * .75
    elif pressingMoveDown():
      vv = -climb_speed * .75
    else:
      vv = 0

    if pressingMoveRight():
      hv = Vector3(climb_speed * .5, 0, 0)
    elif pressingMoveLeft():
      hv = Vector3(-climb_speed * .5, 0, 0)
    else:
      hv = Vector3(0, 0, 0)

    if not pauseAnimation and aniPlayer != null:
      if pressingMoveUp() or pressingMoveDown() or pressingMoveRight() or pressingMoveLeft():
        if not aniPlayer.current_animation == "climb":
          aniPlayer.stop()
          aniPlayer.clear_queue()
          aniPlayer.play("climb")
      else:
        if not aniPlayer.assigned_animation == "climbStop":
          aniPlayer.stop()
          aniPlayer.clear_queue()
          aniPlayer.play("climbStop")
    

func processJumpInputs(delta):
  if is_climbing_ladder or global.pauseMoveInput: return

  # jump
  if justPressedJump() or recentlyJustPressedJump(): 
    # # Jump from the water
    if canSwim() and is_touching_water and not has_water_double_jumped and not isKindOfOnGround() and \
    (aniPlayer == null or pauseAnimation or (aniPlayer.assigned_animation != "jumpSquat" and aniPlayer.assigned_animation != "jumpStart")):
      was_touching_water_at_start_of_jump = true
      vv = jump_force * .75
      has_water_double_jumped = true

      if is_touching_water and wetJumpSound != null and justPressedJump():
        wetJumpSound.pitch_scale = rand_range(0.8, 1.3)
        wetJumpSound.play()
      on_ground = false
      should_do_fallthrough_area_collision = false
      has_just_jumped_timer = -has_just_jumped_time_limit

      if not pauseAnimation and aniPlayer != null:
        aniPlayer.clear_queue()
        aniPlayer.play("swimJumpStart")
        aniPlayer.queue("swimJump")
    # Jump from the ground
    if isKindOfOnGround():
      has_water_double_jumped = false
      was_touching_water_at_start_of_jump = is_touching_water
      was_just_on_ground_timer = was_just_on_ground_time_limit
      jumped_from_true_ground = truly_on_ground
      jump_squat_jump_input_timer = 0
      feather_jump_timer = 0
      weak_feather_dbl_jump = false
      if on_ground:
        addJumpSmokeCloud()
      if aniPlayer == null or pauseAnimation:
        jump_squat_jump_input_timer = 1
        actuallyApplyJump()

      if not pauseAnimation and aniPlayer != null and (not "jump" in aniPlayer.assigned_animation or not "fall" in aniPlayer.assigned_animation):
        aniPlayer.clear_queue()
        aniPlayer.play("jumpSquat", -1, 2.0 if isFeatherLike() else 1.0)
        aniPlayer.queue("jumpStart")
        aniPlayer.queue("fall" if isFeatherLike() else "jump")
      if bounceAniPlayer:
        playBounce("jumpSquat", ["jumpStart"])

  if not pauseAnimation and aniPlayer != null:
    if aniPlayer.assigned_animation == "jumpSquat":
      vv = 0
      if pressingJump():
        jump_squat_jump_input_timer += (delta*22)
    if aniPlayer.assigned_animation != "jumpSquat" and jump_squat_jump_input_timer > 0:
      actuallyApplyJump()
      jump_squat_jump_input_timer = 0
      

  if not glitch_form == global.GlitchForm.LADDER:
    if isFeatherLike() and feather_jump_timer < feather_jump_time_limit and pressingJump() and (aniPlayer == null or pauseAnimation or aniPlayer.assigned_animation != "jumpSquat"): 
      feather_jump_timer += (delta*22)
      if weak_feather_dbl_jump:
        feather_jump_timer += (delta*22)
      actuallyApplyJump(false)
    elif feather_jump_timer < 4 and pressingJump() and (aniPlayer == null or pauseAnimation or aniPlayer.assigned_animation != "jumpSquat"):
      feather_jump_timer += (delta*22)
      if feather_jump_timer > 3: 
        actuallyApplyJump(false)
    elif pressingJump() and feather_jump_timer < feather_jump_partial_time_limit: 
      feather_jump_timer += (delta*22)
    
  # if was_touching_water_at_start_of_jump and pressingJump() and not is_touching_water:
  #   feather_jump_timer = 0
  #   should_magic_jump = true
  #   actuallyApplyJump(false)
  #   was_touching_water_at_start_of_jump = false
    
  if not pressingJump():
    weak_feather_dbl_jump = true
    feather_jump_timer = 200
      
  if vv > 0 or on_ground:
    should_magic_jump = false

var is_really_glitchy = false
func addJumpSmokeCloud(flip_flip_h = false):
  if is_touching_water: return

  var newSmokeCloud = jumpSmokeCloudRes.instance()
  level.add_child(newSmokeCloud)
  newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x
  newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y - 0.24
  newSmokeCloud.global_transform.origin.z = mySprite.global_transform.origin.z + 0.24
  if flip_flip_h:
    newSmokeCloud.flip_h = not mySprite.flip_h
  else:
    newSmokeCloud.flip_h = mySprite.flip_h
  newSmokeCloud.get_material_override().set_shader_param("target_palette", level.current_sprite_palette)
  newSmokeCloud.is_really_glitchy = is_really_glitchy

func actuallyApplyJump(play_sound = true):
  tryClearFallthroughCollisionSolid()
  if isFeatherLike():
    vv = jump_force / 1.3 # jump_force / 1.9
    # if not weak_feather_dbl_jump and feather_jump_timer < 5:
    #   if vv < (2*jump_force) / 3:
    #     vv = (2*jump_force) / 3
    # elif not weak_feather_dbl_jump and feather_jump_timer < 8:
    #   if vv < jump_force / 2:
    #     vv = jump_force / 2
    # elif not weak_feather_dbl_jump:
    #   if vv < jump_force / 2.3:
    #     vv = jump_force / 2.3
    # else:
    #   if vv > -1:
    #     vv = jump_force / 3
  elif not play_sound:
    if vv < (1.58*jump_force)/3:
      vv = (1.58*jump_force)/3
  elif glitch_form == global.GlitchForm.INVISIBLE:
    vv = invisible_jump_force
  else:
    # rocket boost boots
    # vv = jump_force*3
    if pressingJump() and not is_touching_water:
      vv = jump_force*1.1
    else:
      vv = jump_force*0.7
  if play_sound and jumpSound != null:
    playJumpSound()
  on_ground = false
  should_do_fallthrough_area_collision = false
  has_just_jumped_timer = 0 

func playJumpSound():
  jumpSound.play()

func isKindOfOnGround():
  # I'm on the ground or just fell off a platform...
  return isKindaSortaOfOnGround() and (pauseAnimation or aniPlayer == null or not "jump" in aniPlayer.assigned_animation)
  
func isKindaSortaOfOnGround():
  # I'm on the ground or just fell off a platform...
  return on_ground or (was_just_on_ground_timer <= was_just_on_ground_time_limit and ((vv < 0 and grav > 0) or vv > 0 and grav < 0))

func getWalkSpeed(_delta):
  # if glitch_form == global.GlitchForm.FLOOR and not on_ground and not jumped_from_true_ground:
  #     curr_walk_speed = floor_glitch_walk_speed
  var run_add = 0
  if pressingRun():
      run_add = 2

  # if glitch_form == global.GlitchForm.FEATHER:
  #   return feather_glitch_walk_speed # no run_add
  if glitch_form == global.GlitchForm.INVISIBLE:
    return invisible_glitch_walk_speed + run_add
  elif is_touching_water:
    return swimming_walk_speed + run_add
  else:
    return walk_speed + run_add

const PROJECTION_ORTHOGONAL = 1
func processHorizontalInputs(delta):
  if is_climbing_ladder: return
  var prevFlipH = mySprite.flip_h

  is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight()
  if is_pressing_horizontal_input:
    if running_timer < running_time_limit:
      if on_ground:
        running_timer += (delta*22)
        if running_timer >= running_time_limit and num_horizontal_input_presses < 2:
          startRun()
      else:
        running_timer = 0
  elif not is_pressing_horizontal_input:
    running_timer = 0

  var is_pressing_opposite_horizontal_input = (pressingMoveLeft() and dir.x > 0) or (pressingMoveRight() and dir.x < 0)
  if is_pressing_opposite_horizontal_input:
    num_horizontal_input_presses = 1
    running_timer = 0
  elif is_pressing_horizontal_input and not was_pressing_horizontal_input and on_ground:
    num_horizontal_input_presses += 1
    if num_horizontal_input_presses == 2 and running_timer < running_time_limit:
      startRun()


  # Forward as "seen" by the camera (OpenGL convention)
  var view_forward = -getGameCamera().get_transform().basis.z
  var view_right = -getGameCamera().get_transform().basis.x
  # Forward as "seen" by the player
  var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()
  var right = view_right

  if glitch_form == global.GlitchForm.FEATHER and not (pauseAnimation and aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"):
    if on_ground:
      # TODO(jaketrower): Initial dash state..???
      forward = forward / 8
      right = right / 8
    else:
      if dir.length() < 0.2:
        forward = forward / 8
        right = right / 8
      else:
        forward = forward / 32
        right = right / 32
  else:
    if is_touching_water:
      forward = forward / 3
      right = right / 3
    else:
      forward = forward / 2
      right = right / 2
  # var glitch_floor_jump_walking = (glitch_form == global.GlitchForm.FLOOR and not on_ground and not (aniPlayer != null and \
  #     (aniPlayer.assigned_animation == "jumpSquat" or aniPlayer.assigned_animation == "jumpStart")))
  # elif glitch_floor_jump_walking:
  #     if dir.length() < 0.2:
  #         forward = forward / 8
  #         right = right / 8
  #     else:
  #         forward = Vector3(0, 0, 0)
  #         right = Vector3(0, 0, 0)
  
  var horizontal_input = false
  if has_just_jumped_timer < has_just_jumped_time_limit:
    has_just_jumped_timer += (delta*22)
    
  if isKindOfOnGround() or has_just_jumped_timer < has_just_jumped_time_limit or \
    is_pressing_horizontal_input or self.isFeatherLike() or self.glitch_form == global.GlitchForm.LADDER:
    
    horizontal_input = true
    if is_pressing_opposite_horizontal_input and (pauseAnimation or aniPlayer == null or aniPlayer.assigned_animation == "jumpStart" or aniPlayer.assigned_animation == "turnAround"):
      if not glitch_form == global.GlitchForm.FLOOR or on_ground:
        dir = Vector3(0.0, 0.0, 0.0)
      

    if not global.pauseMoveInput and not (not pauseAnimation and aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"):
      var multiplier = 0
      var flip_h = false
      if pressingMoveLeft():
        multiplier = 1
        flip_h = true
      elif pressingMoveRight():
        multiplier = -1
        flip_h = false

      if multiplier != 0:
        should_teeter_turn_around = false
        if not pauseAnimation and aniPlayer != null:
          # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
          if mySprite.flip_h != flip_h and on_ground and aniPlayer.assigned_animation != "walkStart" and \
             (aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing())) and \
             (lv.x != 0 or aniPlayer.assigned_animation == "land"):
            dir += (right/2)*(delta*DNUMHORZ)*multiplier
            if aniPlayer.assigned_animation != "turnAround":
              aniPlayer.stop()
              aniPlayer.clear_queue()
              aniPlayer.queue("turnAround")
              aniPlayer.queue("walkStart")
              addJumpSmokeCloud(true)
          elif mySprite.flip_h == flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing() or lv.x == 0:
            dir += right*(delta*DNUMHORZ)*multiplier
            if mySprite.flip_h != flip_h:
              aniPlayer.stop()
              aniPlayer.clear_queue()
              aniPlayer.queue("walkStart")
            mySprite.flip_h = flip_h
            doWalkAnimation()
            if on_ground and should_always_do_jump_smoke_cloud:
              addJumpSmokeCloud(true)
        # if there's no animation player, there's no animation. just flip
        else:
          dir += right*(delta*DNUMHORZ)*multiplier
          mySprite.flip_h = flip_h
  
  # TODO(jaketrower): Maybe this? seems complicated
  if not pauseAnimation and not pressingMoveLeft() and not pressingMoveRight() and on_ground and aniPlayer != null and \
     (aniPlayer.current_animation == "walk" or aniPlayer.assigned_animation == "stand" or \
     (aniPlayer.assigned_animation == "turnAround" and not aniPlayer.is_playing()) or aniPlayer.assigned_animation == "teeter"):
    if aniPlayer.assigned_animation == "turnAround" or (aniPlayer.assigned_animation == "teeter" and should_teeter_turn_around):
      mySprite.flip_h = not mySprite.flip_h
      should_teeter_turn_around = false
    aniPlayer.clear_queue()
    if aniPlayer.assigned_animation != "teeter":
      if half_on_ground and not glitch_form == global.GlitchForm.FLOOR:
        aniPlayer.stop()
        if should_teeter_turn_around:
          aniPlayer.queue("turnAround")
        aniPlayer.queue("teeter")
      elif aniPlayer.assigned_animation != "walkStop" and aniPlayer.assigned_animation != "stand":
        aniPlayer.stop()
        if aniPlayer.assigned_animation == "walk":
          aniPlayer.queue("walkStop")
        aniPlayer.queue("stand")

  var DNUMSKID = DNUMSKID_BASE
  if self.isFeatherLike():
    DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/7)
    if not on_ground:
      DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/10.8)
  # if glitch_form == global.GlitchForm.FLOOR and not on_ground:
  #   DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/9)
    # TODO(jaketrower): RocketJumpBoots # DNUMSKID *= 2

  # TODO(Engine.time_scale suspect)
  if dir.length() > 1 and physics_state != PhysicsState.BEING_TOSSED:
    dir = dir.normalized()
  if on_ground and not self.is_pressing_horizontal_input and shouldGroundHaveFriction():
    dir = dir * 0.9*(delta*DNUMSKID)
    if dir.length() < 0.1:
      dir = Vector3(0, 0, 0)
  elif not on_ground and shouldAirHaveFriction():
    dir = dir * 0.99*(delta*DNUMSKID)
    if dir.length() < 0.01:
      dir = Vector3(0, 0, 0)
  # elif glitch_form == global.GlitchForm.FLOOR and not on_ground:
  #     dir = dir * 0.97*(delta*DNUMSKID)
  #     if dir.length() < 0.1:
  #         dir = Vector3(0, 0, 0)

  if walk_speed == null:
    walk_speed = 8
  if feather_glitch_walk_speed == null:
    feather_glitch_walk_speed = 10
  if floor_glitch_walk_speed == null:
    floor_glitch_walk_speed = 3
  if invisible_glitch_walk_speed == null:
    invisible_glitch_walk_speed = 6
  if swimming_walk_speed == null:
    swimming_walk_speed = 6

  var curr_walk_speed = getWalkSpeed(delta)

  # update x and z
  if not is_touching_water or horizontal_input:
    hv = dir * curr_walk_speed
  elif on_ground:
    # TODO(Engine.time_scale suspect)
    hv -= (hv.normalized()*delta*30)
    if abs(hv.length()) < delta*22:
      hv = Vector3()
      dir = Vector3(0.0, 0.0, 0.0)

  if global.pauseMoveInput:
    hv = Vector3(0, 0, 0)
    is_walking = false
  else:
    updateFacing(dir)

  if aniPlayer != null and aniPlayer.assigned_animation == "sweepFloor":
    mySprite.flip_h = prevFlipH

func shouldAirHaveFriction():
  return true

func shouldGroundHaveFriction():
  return true

func doWalkAnimation():
  if horizontal_collision or pauseAnimation or aniPlayer == null or aniPlayer.assigned_animation == "sinkInSand":
    return

  if on_ground and aniPlayer.current_animation != "walkStart" and aniPlayer.current_animation != "walk":
    if aniPlayer.current_animation != "land" or aniPlayer.current_animation != "walkLand":
      aniPlayer.clear_queue()
      aniPlayer.stop()
    var aa = aniPlayer.assigned_animation
    if aa == "stand" or aa == "turnAround" or aa == "walkStop" or aa == "walkBump":
      aniPlayer.queue("walkStart")
      addJumpSmokeCloud()
    aniPlayer.queue("walk")
  if aniPlayer.current_animation == "walk":
    aniPlayer.play("walk", -1, 1.5 if pressingRun() else 1.0)
    
var is_a_physics_particle = false
# http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/
# https://info.sonicretro.org/SPG:Solid_Tiles
func handleCollisionsAndMove(local_lv, delta):
  if delta == 0 or physics_state == PhysicsState.OCCUPIED:
    return local_lv

  if is_a_physics_particle:
    global_transform.origin.x += local_lv.x / velocity_dampener
    global_transform.origin.y += local_lv.y / velocity_dampener
    return local_lv
     
  # TODO(jaketrower): global.time_dilation_multiplier?
  var DNUM = 1.15
  local_lv.x *= delta*DNUM
  local_lv.y *= delta*DNUM

  if should_collide_horizontally:
    local_lv = handleHorizontalCollisions(local_lv)
  global_transform.origin.x += local_lv.x / velocity_dampener
  
  was_on_ground = on_ground
  if glitch_form == global.GlitchForm.LADDER and was_on_ground:
    on_ground = isWalkingIntoWall()
  elif glitch_form != global.GlitchForm.FLOOR and should_collide_floor:
    on_ground = false
  truly_on_ground = false
  half_on_ground = false

  if not should_do_fallthrough_area_collision and (should_collide_floor or should_collide_ceil):
    last_vv = local_lv.y
    local_lv = handleVerticalCollisions(local_lv)
    if last_vv != 0 and local_lv.y == 0:
      self.vertical_collision = true
  elif should_do_fallthrough_area_collision:
    local_lv = collideWithFloor(local_lv)
    global_transform.origin.y = fallthrough_area_collision_y
  global_transform.origin.y += local_lv.y / velocity_dampener

  handleSpikeCollisions(delta)
  
  local_lv.x /= delta*DNUM
  local_lv.y /= delta*DNUM
  return local_lv

func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
  var checking_for_floor_collisions = is_vertical and sensor_direction == -1
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
  if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    return not pressingDown() and checking_for_floor_collisions and (tileCollisionShape is BoxShape or isTileFallthroughSolidTop(tile_type, tile_pos_coords))
  else:
    var tile_name = getLevelTiles().mesh_library.get_item_name(tile_type)
    return (tileCollisionShape is BoxShape or (not pressingDown() and checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords))) and not "Spikes" in tile_name
  
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
  var y = global_transform.origin.y
  var is_above_top_of_tile = y + bb > tile_pos_coords.y
  
  var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
  return is_above_top_of_tile and (tileCollisionShape is PlaneShape or (glitch_form == global.GlitchForm.WALK_THROUGH_WALLS and tileCollisionShape is BoxShape))
  
func doSensorProbe(is_vertical, sensor, sensor_direction, tile_anchor, _debug = false):
  var z = 0 # global_transform.origin.z
  var TILE_WIDTH = getLevelTiles().cell_size.x
  var TILE_HEIGHT = getLevelTiles().cell_size.y
  
  var coords_a = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y, z))
  var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
  var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)
  
  var tile_pos = 99999 * sensor_direction
  var tile_type = GridMap.INVALID_CELL_ITEM
  if isTileSolid(tile_type_a, is_vertical, sensor_direction, tile_pos_a):
    tile_pos = coords_a.x + tile_anchor
    tile_type = tile_type_a
    if is_vertical:
      tile_pos = coords_a.y + tile_anchor
      
    # We found a collision, regress to see if there is a previous one
    if should_do_simple_sensor_probe:
      var coords_b = getLevelTiles().world_to_map(Vector3(sensor.x - (TILE_WIDTH*sensor_direction), sensor.y, z))
      if is_vertical:
        coords_b = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y - (TILE_HEIGHT*sensor_direction), z))
      var tile_pos_b = getLevelTiles().map_to_world(coords_b.x, coords_b.y, coords_b.z)
      var tile_type_b = getLevelTiles().get_cell_item(coords_b.x, coords_b.y, coords_b.z)
      if isTileSolid(tile_type_b, is_vertical, sensor_direction, tile_pos_b):
        # Found an earlier tile collision, use it instead of tile A
        tile_pos = coords_b.x + tile_anchor
        tile_type = tile_type_b
        if is_vertical:
          tile_pos = coords_b.y + tile_anchor
    # else: # Did not find an earlier tile collision, so use tile A
  elif should_do_simple_sensor_probe:
    # We have found no collision, extend to see if there is an upcoming one
    var coords_b = getLevelTiles().world_to_map(Vector3(sensor.x + (TILE_WIDTH*sensor_direction), sensor.y, z))
    if is_vertical:
      coords_b = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y + (TILE_HEIGHT*sensor_direction), z))
    var tile_pos_b = getLevelTiles().map_to_world(coords_b.x, coords_b.y, coords_b.z)
    var tile_type_b = getLevelTiles().get_cell_item(coords_b.x, coords_b.y, coords_b.z)
    if isTileSolid(tile_type_b, is_vertical, sensor_direction, tile_pos_b):
      # Found a later tile collision, use it
      tile_pos = coords_b.x + tile_anchor
      tile_type = tile_type_b
      if is_vertical:
        tile_pos = coords_b.y + tile_anchor
    # else: # We found no tile collision on this side! Just use default :)
  return Vector2(tile_pos, tile_type)

func probeSensorForTileDistance(sensor, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  
  if is_vertical:
    # add y speed to collision checking if we're in the air
    sensor.y += local_lv.y
    if local_lv.y == 0 and glitch_form == global.GlitchForm.FLOOR:
      sensor.y -= 0.125
    # if local_lv.y == 0 and glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall():
    #   sensor.y += 0.125
  else:
    sensor.x += local_lv.x
  var tile_pos_and_type = doSensorProbe(is_vertical, sensor, sensor_direction, tile_anchor)
  var tile_pos = tile_pos_and_type.x
  var tile_type = tile_pos_and_type.y
  var tile_distance = (tile_pos*sensor_direction) - ((x+sensor_anchor) * sensor_direction)
  if is_vertical:
    tile_distance = (tile_pos*sensor_direction) - ((y+sensor_anchor) * sensor_direction)
  return Vector3(tile_pos, tile_distance, tile_type)

var can_collide_with_floor = true
func collideWithFloor(local_lv):
  # TODO(jaketrower): TopsyTurvy
  local_lv.y = 0
  if can_collide_with_floor:
    on_ground = true
    truly_on_ground = true
  return local_lv

func reactToPotentialCollisions(_tile_type, tile_distance, is_vertical, local_lv, _sensor_anchor, sensor_direction, _tile_anchor, should_collide_with_floor, debug = false):
  if tile_distance <= 0:
    if debug:
      # print("collide sensor A...")
      if not is_vertical: get_tree().paused = true
    # push player out of the tile! # TODO(jaketrower): TopsyTurvy
    if is_vertical:
      global_transform.origin.y += tile_distance * sensor_direction
      if should_collide_with_floor:
        local_lv = collideWithFloor(local_lv) # TODO(jaketrower): TopsyTurvy
      else:
        local_lv.y = 0
        if feather_jump_timer < feather_jump_partial_time_limit:
          feather_jump_timer = feather_jump_partial_time_limit
    else:
      global_transform.origin.x += tile_distance * sensor_direction
      collideWithWall(local_lv)
      local_lv.x = 0
  elif is_vertical and tile_distance < local_lv.y * sensor_direction: # TODO(jaketrower): TopsyTurvy
    global_transform.origin.y += tile_distance * sensor_direction
    if should_collide_with_floor:
      local_lv = collideWithFloor(local_lv) # TODO(jaketrower): TopsyTurvy
    else:
      local_lv.y = 0
      if feather_jump_timer < feather_jump_partial_time_limit:
        feather_jump_timer = feather_jump_partial_time_limit
  elif not is_vertical and tile_distance < local_lv.x * sensor_direction: # TODO(jaketrower): TopsyTurvy
    global_transform.origin.x += tile_distance * sensor_direction
    collideWithWall(local_lv) # TODO(jaketrower): TopsyTurvy
    local_lv.x = 0
  return local_lv

# TODO(jaketrower): TopsyTurvy
func collideWithWall(local_lv):
  self.horizontal_collision = true
  if physics_state == PhysicsState.BEING_TOSSED and glitch_form == global.GlitchForm.FLOOR:
    on_ground = false
  var just_pressed_horizontal_input = is_pressing_horizontal_input and not was_pressing_horizontal_input
  var switched_to_red_from_yellow = glitch_form == global.GlitchForm.FLOOR and prev_glitch_form == global.GlitchForm.LADDER
  var switched_to_yellow = glitch_form == global.GlitchForm.LADDER and prev_glitch_form != global.GlitchForm.LADDER
  var bumpSpeed = 0.06
  if not on_ground and glitch_form != global.GlitchForm.FEATHER:
    bumpSpeed = 0.10
  var should_play_bump = abs(local_lv.x) > bumpSpeed or just_pressed_horizontal_input or switched_to_red_from_yellow or switched_to_yellow
  var bump_ani_speed = 1.0
  if abs(local_lv.x) < 0.16 and not (just_pressed_horizontal_input or switched_to_red_from_yellow or switched_to_yellow):
    bump_ani_speed = 0.75

  var ladder_glitch = glitch_form == global.GlitchForm.LADDER
  if not pauseAnimation and aniPlayer != null and should_play_bump:
    var aa = aniPlayer.assigned_animation
    if not was_on_ground and not is_touching_water:
      if local_lv.y > 0 and aa != "jumpBump" and aa != "jumpSquat":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        playLandSound()
        aniPlayer.play("jumpBump", -1, bump_ani_speed)
        if glitch_form == global.GlitchForm.LADDER:
          aniPlayer.queue("walk")
        else: aniPlayer.queue("fall" if isFeatherLike() else "jump")
      elif local_lv.y < 0 and aa != "fallBump" and aa != "fallFar":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        playLandSound()
        aniPlayer.play("fallBump", -1, bump_ani_speed)
        if glitch_form == global.GlitchForm.LADDER:
          aniPlayer.queue("walk")
        else: aniPlayer.queue("fall")
    # TODO(jaketrower): Should probably have like an animationState FSM (along with physics state?)
    elif ((was_on_ground and not ladder_glitch) or (truly_on_ground and ladder_glitch)) \
       and aa != "walkBump" and ("walk" in aa or "land" in aa):
      aniPlayer.stop()
      aniPlayer.clear_queue()
      playLandSound()
      if glitch_form == global.GlitchForm.LADDER:
        aniPlayer.play("walk")
        bounceAniPlayer.stop()
        if local_lv.x > 0:
          bounceAniPlayer.play("bumpRight", -1, bump_ani_speed)
        if local_lv.x < 0:
          bounceAniPlayer.play("bumpLeft", -1, bump_ani_speed)
      else:
        aniPlayer.play("walkBump", -1, bump_ani_speed)
        aniPlayer.queue("stand")
  dir = Vector3(0, 0, 0)
  num_horizontal_input_presses = 0
  running_timer = 0

var cheating_horizontal_offset = 0
func performCollisionCheck(is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug = false):
  var x = global_transform.origin.x
  var y = global_transform.origin.y

  if not should_only_do_middle_sensor:
    # Check for sensor A
    var sensor_A = Vector2(x+sensor_anchor, y+bb+0.2)
    if is_vertical: sensor_A = Vector2(x+lb, y+sensor_anchor)
    var tile_pos_and_distance_and_type_A = probeSensorForTileDistance(sensor_A, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor)
    var tile_pos_A = tile_pos_and_distance_and_type_A.x
    var tile_distance_A = tile_pos_and_distance_and_type_A.y
    var tile_type_A = tile_pos_and_distance_and_type_A.z

    # Check for sensor B
    var sensor_B = Vector2(x+sensor_anchor, y+tb-0.2)
    if is_vertical: sensor_B = Vector2(x+rb, y+sensor_anchor)
    var tile_pos_and_distance_and_type_B = probeSensorForTileDistance(sensor_B, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor)
    var tile_pos_B = tile_pos_and_distance_and_type_B.x
    var tile_distance_B = tile_pos_and_distance_and_type_B.y
    var tile_type_B = tile_pos_and_distance_and_type_B.z

    if should_do_middle_sensor:
      # Check for middle sensor
      
      var middle_sensor = Vector2(x+sensor_anchor, y)
      if is_vertical: middle_sensor = Vector2(x, y+sensor_anchor)
      var tile_pos_and_distance_and_type_middle = probeSensorForTileDistance(middle_sensor, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor)
      var middle_tile_pos = tile_pos_and_distance_and_type_middle.x
      var middle_tile_distance = tile_pos_and_distance_and_type_middle.y
      var middle_tile_type = tile_pos_and_distance_and_type_middle.z

      if debug:
        print(
          str(is_vertical) + 
          " (x, y): " + str(x) + ", " + str(y) +
          ";; sensor_A_distance: " + str(tile_distance_A) + ", " + str(tile_pos_A) +
          ";; sensor_B_distance: " + str(tile_distance_B) + ", " + str(tile_pos_B) + 
          ";; middle_tile_distance: " + str(middle_tile_distance) + ", " + str(middle_tile_pos)
        )

      # Compare left and right collision tile distances
      if tile_distance_A <= tile_distance_B and tile_distance_A <= middle_tile_distance:
        local_lv = reactToPotentialCollisions(tile_type_A, tile_distance_A, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
      elif tile_distance_B < tile_distance_A and tile_distance_B <= middle_tile_distance:
        local_lv = reactToPotentialCollisions(tile_type_B, tile_distance_B, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
      else:
        local_lv = reactToPotentialCollisions(middle_tile_type, middle_tile_distance, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
      return local_lv
    else:
      # Compare left and right collision tile distances
      if tile_distance_A <= tile_distance_B:
        local_lv = reactToPotentialCollisions(tile_type_A, tile_distance_A, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
      elif tile_distance_B < tile_distance_A:
        local_lv = reactToPotentialCollisions(tile_type_B, tile_distance_B, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
      return local_lv
  else:
    var middle_sensor = Vector2(x+sensor_anchor, y+cheating_horizontal_offset)
    if is_vertical: middle_sensor = Vector2(x, y+sensor_anchor)
    var tile_pos_and_distance_and_type_middle = probeSensorForTileDistance(middle_sensor, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor)
    var middle_tile_distance = tile_pos_and_distance_and_type_middle.y
    var middle_tile_type = tile_pos_and_distance_and_type_middle.z

    local_lv = reactToPotentialCollisions(middle_tile_type, middle_tile_distance, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
    return local_lv

func handleHorizontalCollisions(local_lv):
  self.horizontal_collision = false
  var TILE_WIDTH = getLevelTiles().cell_size.x

  # check for left collisions
  if local_lv.x < 0 or pressingMoveLeft():
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(false, local_lv, lb - 0.2, -1, TILE_WIDTH, false)
    # TODO(jaketrower): TopsyTurvy is_vertical

  # check for right collisions
  if local_lv.x > 0 or pressingMoveRight():
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(false, local_lv, rb + 0.2, 1, 0, false)
    # TODO(jaketrower): TopsyTurvy is_vertical
  return local_lv
  
  
func handleVerticalCollisions(local_lv):
  self.vertical_collision = false
  var TILE_HEIGHT = getLevelTiles().cell_size.y

  # check for bottom collisions
  if should_collide_floor and (on_ground or local_lv.y <= 0):
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(true, local_lv, bb, -1, TILE_HEIGHT, grav >= 0)
    # TODO(jaketrower): TopsyTurvy is_vertical

  # check for top collisions
  if should_collide_ceil and (not on_ground or (glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall())) and local_lv.y > 0:
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(true, local_lv, tb, 1, 0, grav < 0)
    # TODO(jaketrower): TopsyTurvy is_vertical
  
  return local_lv
  
func handleSpikeCollisions(_delta):
  pass

func postProcessInputs(_delta):
  pass
  
func playBounce(aniName, aniNameQueue = []):
  if bounceAniPlayer != null:
    bounceAniPlayer.stop()
    bounceAniPlayer.clear_queue()
    bounceAniPlayer.play(aniName)
    for queuedAniName in aniNameQueue:
      bounceAniPlayer.queue(queuedAniName)

onready var miniSplashSound = get_node("Sounds/MiniSplashSound") if has_node("Sounds/MiniSplashSound") else null
func playLandSound():
  if is_touching_water and miniSplashSound:
      miniSplashSound.play()
  elif landSound:
    landSound.play()

var has_water_double_jumped = false
func landed():
  jump_squat_jump_input_timer = 0
  has_water_double_jumped = false
  var quiet_the_fall_sound = true
  playLandSound()
  addJumpSmokeCloud()
  if physics_state == PhysicsState.BEING_TOSSED:
    pauseAnimation = false
  if not pauseAnimation and aniPlayer != null and not global.pauseGame and last_vv < 1 and aniPlayer.assigned_animation != "jumpSquat" and aniPlayer.assigned_animation != "jumpStart":
    aniPlayer.clear_queue()
    if fall_timer > fall_time_max and not glitch_form == global.GlitchForm.FEATHER:
      quiet_the_fall_sound = false
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("fallFlat", -1, 1.0)
      physics_state = PhysicsState.COLLAPSED
      if bumpSound: bumpSound.play()
      iFellFlat()
    else:
      playLandAnimation()
      if physics_state == PhysicsState.BEING_TOSSED:
        physics_state = PhysicsState.NORMAL
  if bounceAniPlayer:
    if last_vv < -10:
      playBounce("land")
    elif last_vv < -6:
      playBounce("landSoft")
  if fallSound and quiet_the_fall_sound:
    fallSound.stop()
  fall_timer = 0

func iFellFlat():
  pass

func isWalkingIntoWall():
  return abs(linear_velocity.x) < 0.5 \
       and is_pressing_horizontal_input and was_pressing_horizontal_input \
       and (pauseAnimation or aniPlayer == null or aniPlayer.assigned_animation != "jumpSquat") 

func updateFacing(local_dir):
  if local_dir.x != 0 or local_dir.y != 0 or local_dir.z != 0:
    facing = local_dir
    is_walking = true
  else:
    is_walking = false

func isRectColliding(lb1, tb1, rb1, bb1, lb2, tb2, rb2, bb2, debug_ = false):
  if debug_:
    print(str(tb2) + ", " + str(bb1))
    print("\tisRectColliding: " + str(lb2 <= rb1) + ", " + str(rb2 >= lb1) + ", " + str(tb2 >= bb1) + ", " + str(bb2 <= tb1))
  if lb2 <= rb1 and rb2 >= lb1 and tb2 >= bb1 and bb2 <= tb1:
    return true
  return false

func vec3ToVec2(vec3):
    return global.vec3ToVec2(vec3)

func moveToward2D(sourceVec3, targetVec3, delta):
    return global.moveToward2D(sourceVec3, targetVec3, delta)

func compare2D(sourceVec3, targetVec3, closeness_amt = 0.5):
    return global.compare2D(sourceVec3, targetVec3, closeness_amt)

func isTouchingSpikes(collisionShape):
  if not collisionShape.visible:
    return

  var sx = collisionShape.global_transform.origin.x
  var sy = collisionShape.global_transform.origin.y
  var stb = sy + collisionShape.shape.extents.y/2*collisionShape.scale.y + 0.25
  var sbb = sy - collisionShape.shape.extents.y/2*collisionShape.scale.y - 0.25
  var slb = sx - collisionShape.shape.extents.x/2*collisionShape.scale.x - 0.25
  var srb = sx + collisionShape.shape.extents.x/2*collisionShape.scale.x + 0.25
  
  for i in range(int(floor(sbb)), int(ceil(stb))):
    for j in range(int(floor(slb)), int(ceil(srb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileSpikes(tile_type):
        return true
        # TODO(jaketrower): also reset the levelTiles array position?
  return false
