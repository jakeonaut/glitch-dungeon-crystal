extends KinematicBody

# TODO(jaketrower): This "class" is monolithic when it should be Modular... but how in gdscript?

onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null
onready var fallSound = get_node("Sounds/FallSound") if has_node("Sounds/FallSound") else null
onready var jumpSound = get_node("Sounds/JumpSound") if has_node("Sounds/JumpSound") else null
onready var doubleJumpSound = get_node("Sounds/DoubleJumpSound") if has_node("Sounds/DoubleJumpSound") else null
onready var wetJumpSound = get_node("Sounds/WetJumpSound") if has_node("Sounds/WetJumpSound") else null

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

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

onready var smallInteractionArea = get_node("SmallInteractionArea")
onready var collisionShape = get_node("CollisionShape")
onready var aniPlayer = get_node("AnimationPlayer") if has_node("AnimationPlayer") else null
var animation_speed_multiplier = 1.0
onready var mySprite = get_node("Sprite3D")

export var true_terminal_vel = 32
var true_terminal_feather_vel = 12
var water_terminal_vel = 4
var water_fall_terminal = 8
var hit_water_terminal_vel = 1
var terminal_vel = true_terminal_vel
var is_touching_water = false
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
var was_just_on_ground_timer = 0
var was_just_on_ground_time_limit = 2
var just_landed = false
var spawn_origin
var last_grounded_y = 0
var falling_y_offset = 16
var fall_timer = 0
var should_collide_horizontally = true
var should_collide_floor = true 
var should_collide_ceil = true
var should_do_middle_sensor = false
var should_only_do_middle_sensor = false
var should_do_simple_sensor_probe = true
var should_do_fallthrough_area_collision = false
var fallthrough_area_collision_y = 0
var should_always_do_jump_smoke_cloud = false

var tile_coords_below_me_a = null
var tile_coords_below_me_b = null
var tile_coords_below_me_mid = null


var jumpSmokeCloudRes = preload("res://sceneObjects/JumpSmokeCloud.tscn")

enum PhysicsState {
  NORMAL,
  COLLAPSED,
  CAN_WAKE_UP,
  WAKING_UP,
  GLITCH_DYING,
  GLITCH_HURT,
  GLITCH_RECOVERY,
}
var physics_state = PhysicsState.NORMAL

var linear_velocity = Vector3()
var lv = linear_velocity

export var grav = 60
var g = Vector3(0, -grav, 0) if grav != 0 else Vector3(0, -1, 0)

# TODO(jaketrower): Maybe should remove dir, and only rely on linear_velocity ?
var dir = Vector3(0, 0, 0)
var prev_dir = dir
var up = -g.normalized() # (up is against gravity)
var vv = up.dot(lv) # vertical velocity
var last_vv = vv
var hv = lv - up * vv # horizontal velocity

export var walk_speed = 8
  
var glitch_form = global.GlitchForm.NORMAL
var prev_glitch_form = global.GlitchForm.NORMAL
var feather_fall_timer = 0
var feather_fall_initial_time_limit = 20
var feather_fall_time_limit = 60
var feather_jump_timer = 0
var feather_jump_time_limit = 10
var feather_jump_partial_time_limit = 7
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
var facing = Vector3(0, 0, 1) #default to facing "down" toward the player behind the screen
var transitioning = false
var is_falling = false
var was_walking_into_wall = false
var pauseSelf = false

var horizontal_collision = false

var DNUMHORZ = 65.0
var DNUMSKID_BASE = 54.0

func _ready():
  set_process_input(true)
  set_process(true)
  set_physics_process(true)
  spawn_origin = global_transform.origin
  last_grounded_y = spawn_origin.y

  if true_terminal_vel == null: true_terminal_vel = 32

func _process(_delta):
  if aniPlayer:
    aniPlayer.playback_speed = global.time_dilation_multiplier * animation_speed_multiplier

func _physics_process(delta):
  if global.pauseGame or pauseSelf: return

  is_touching_water = smallInteractionArea.is_touching_water
  is_touching_ladder = smallInteractionArea.is_touching_ladder

  DNUMHORZ = 65.0 * global.time_dilation_multiplier
  DNUMSKID_BASE = 54.0 / global.time_dilation_multiplier
  processPhysics(delta * global.time_dilation_multiplier)

  if not on_ground and translation.y < (last_grounded_y - falling_y_offset) and not transitioning:
    is_falling = true

  alignMySprite()

func alignMySprite():
  var pixelSize = 0.125
  if mySprite:
    mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + 0.25
     
func isActive():
  return visible

func tryDieToEnemy(_should_glitch, _should_kill_invis):
  pass    
  
func getHitByBroom():
  pass

func processPhysics(delta):
  if grav == null: grav = 0 # ???

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
    if not aniPlayer or not aniPlayer.is_playing():
      physics_state = PhysicsState.CAN_WAKE_UP
  elif physics_state == PhysicsState.CAN_WAKE_UP:
    var pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight()
    var pressing_jump = justPressedJump() or recentlyJustPressedJump()
    if not global.pauseMoveInput and (pressing_horizontal_input or pressing_jump or pressingDown() or not on_ground):
      if aniPlayer:
        aniPlayer.play("wakeup")
      physics_state = PhysicsState.WAKING_UP
  elif physics_state == PhysicsState.WAKING_UP:
    if not aniPlayer or not aniPlayer.is_playing():
      physics_state = PhysicsState.NORMAL
    
  lv = hv + (up * vv)
  
  linear_velocity = handleCollisionsAndMove(lv, delta)
  last_vv = vv

  postProcessInputs(delta)
  prev_dir = dir
  
  just_landed = false
  if not was_on_ground and on_ground: # I just landed!!
    landed()
    just_landed = true
  # TODO(jaketrower): all this animation code IS going to break everything one day :)
  if aniPlayer != null and not global.pauseGame and not aniPlayer.assigned_animation == "getItem":
    if not is_climbing_ladder:
      if on_ground:
        if (aniPlayer.assigned_animation == "land" or aniPlayer.assigned_animation == "walkStart") and not aniPlayer.is_playing():
          aniPlayer.play("stand")
        elif aniPlayer.assigned_animation == "jump" or aniPlayer.assigned_animation == "jumpBump":
          aniPlayer.play("land")
      elif linear_velocity.y > 0 and not "jump" in aniPlayer.assigned_animation and not "Jump" in aniPlayer.assigned_animation \
        and not (glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall()):
        aniPlayer.stop()
        aniPlayer.clear_queue()
        if is_touching_water:
          aniPlayer.queue("swimJump")
        else:
          aniPlayer.queue("jump")

  if was_on_ground and not on_ground: # I just fell off platform!
    was_just_on_ground_timer = 0
    if prev_glitch_form == global.GlitchForm.FLOOR and glitch_form != global.GlitchForm.FLOOR:
      was_just_on_ground_timer = -4
  was_touching_water = is_touching_water

  if was_just_on_ground_timer <= was_just_on_ground_time_limit:
    was_just_on_ground_timer += (delta*22)
  was_pressing_horizontal_input = is_pressing_horizontal_input
  prev_glitch_form = glitch_form
    
func applyGravity(delta):
  if is_touching_water:
    g = Vector3(0, -grav/3, 0)
    if fallSound:
      fallSound.stop()
  elif isFeatherLike():
    if pressingDown() or (feather_fall_time_limit >= feather_fall_time_limit and not pressingJump()):
      g = Vector3(0, -grav/2, 0)
    else:
      g = Vector3(0, -grav/3, 0)
  else:
    g = Vector3(0, -grav, 0)

  if not is_climbing_ladder and (not on_ground or glitch_form != global.GlitchForm.FLOOR):
    lv += g * delta
    if glitch_form != global.GlitchForm.FEATHER and vv < -1 and not is_touching_water:
      fall_timer += (delta*22)
    else:
      fall_timer = 0
    if lv.y < 0:
      if not on_ground and aniPlayer:
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
      if fall_timer > 20 and aniPlayer and aniPlayer.current_animation != "fallFar":
        aniPlayer.clear_queue()
        aniPlayer.stop()
        aniPlayer.play("fallFar")
        if not transitioning and fallSound: fallSound.play()
      

func applyTerminalVelocity(delta):
  if feather_fall_timer < feather_fall_initial_time_limit:
    feather_fall_timer += (delta*22)

  if is_touching_water:
    if not was_touching_water:
      terminal_vel = hit_water_terminal_vel
    elif pressingJump() and feather_fall_timer < feather_fall_initial_time_limit:
      terminal_vel = water_terminal_vel/2
    elif pressingDown() or feather_fall_timer >= feather_fall_time_limit:
      terminal_vel = water_fall_terminal
      feather_fall_timer = feather_fall_time_limit
    else:
      terminal_vel = water_terminal_vel
  elif glitch_form == global.GlitchForm.FEATHER:
    if pressingJump() and feather_fall_timer < feather_fall_initial_time_limit:
      terminal_vel = water_terminal_vel/2
    elif pressingDown() or feather_fall_timer >= feather_fall_time_limit:
      terminal_vel = true_terminal_feather_vel
      feather_fall_timer = feather_fall_time_limit
    else:
      terminal_vel = water_terminal_vel
  else:
    terminal_vel = true_terminal_vel
    if pressingJump():
      feather_fall_timer = 0

  if vv < -terminal_vel:
    vv = -terminal_vel
  if grav < 0 and vv > terminal_vel:
    vv = terminal_vel

  if glitch_form == global.GlitchForm.FLOOR and on_ground:
    vv = 0
    

func areTilesBelow(currLevelTiles):
  tile_coords_below_me_a = null
  tile_coords_below_me_b = null
  tile_coords_below_me_mid = null

  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  var lb = -get_node("CollisionShape").shape.radius
  var rb = -lb
  var bb = -get_node("CollisionShape").shape.height/2
  
  var coords_a = currLevelTiles.world_to_map(Vector3(x + lb, y + bb - 0.1, z))
  var tile_pos_a = currLevelTiles.map_to_world(coords_a.x, coords_a.y, coords_a.z)
  var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

  var coords_b = currLevelTiles.world_to_map(Vector3(x + rb, y + bb - 0.1, z))
  var tile_pos_b = currLevelTiles.map_to_world(coords_b.x, coords_b.y, coords_b.z)
  var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

  var coords_mid = currLevelTiles.world_to_map(Vector3(x, y + bb - 0.1, z))
  var tile_pos_mid = currLevelTiles.map_to_world(coords_mid.x, coords_mid.y, coords_mid.z)
  var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

  if isTileSolid(tile_type_a, true, 1, tile_pos_a):
    tile_coords_below_me_a = coords_a
  if isTileSolid(tile_type_b, true, 1, tile_pos_b):
    tile_coords_below_me_b = coords_b
  if isTileSolid(tile_type_mid, true, 1, tile_pos_mid):
    tile_coords_below_me_mid = coords_mid

  return tile_coords_below_me_a != null or tile_coords_below_me_b != null or tile_coords_below_me_mid != null

func processInputs(delta):
  processLadderInputs(delta)
  processJumpInputs(delta)
  processHorizontalInputs(delta)
  if justPressedDown():
    on_ground = false
    should_do_fallthrough_area_collision = false

  # fail safe...
  if vv > jump_force*2:
    vv = jump_force*2
    if was_walking_into_wall and not isWalkingIntoWall():
      vv = 1
  was_walking_into_wall = isWalkingIntoWall()
  if was_walking_into_wall and glitch_form == global.GlitchForm.LADDER and not global.pauseMoveInput:
    vv = 6
    if aniPlayer.assigned_animation == "stand":
      aniPlayer.stop()
      aniPlayer.queue("walkBump")
      aniPlayer.queue("walk")
    should_do_fallthrough_area_collision = false
    ladderUpdateTargetLastGroundedY()

func ladderUpdateTargetLastGroundedY():
  pass

func justPressedDown():
  return false
  
func pressingDown():
  return false

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
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("climb")
      dir = Vector3(0, 0, 0)
      on_ground = true
  else:
    if is_climbing_ladder:
      is_climbing_ladder = false
      feather_fall_timer = 0
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

    is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight()

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
    # Jump from the water
    if is_touching_water:
      was_touching_water_at_start_of_jump = true
      vv = jump_force / 2

      if is_touching_water and wetJumpSound != null and justPressedJump():
        wetJumpSound.pitch_scale = rand_range(0.8, 1.3)
        wetJumpSound.play()
      on_ground = false
      should_do_fallthrough_area_collision = false
      has_just_jumped_timer = -has_just_jumped_time_limit
      feather_fall_timer = 0

      if aniPlayer:
        aniPlayer.clear_queue()
        aniPlayer.play("swimJumpStart")
        aniPlayer.queue("swimJump")
    # Jump from the ground
    elif isKindOfOnGround():
      was_touching_water_at_start_of_jump = false
      was_just_on_ground_timer = was_just_on_ground_time_limit
      jumped_from_true_ground = truly_on_ground
      jump_squat_jump_input_timer = 0
      feather_jump_timer = 0
      weak_feather_dbl_jump = false
      if on_ground:
        addJumpSmokeCloud()
      if not aniPlayer:
        jump_squat_jump_input_timer = 1
        actuallyApplyJump()

      if aniPlayer and not "jump" in aniPlayer.assigned_animation:
        aniPlayer.clear_queue()
        aniPlayer.play("jumpSquat", -1, 1.0 if isFeatherLike() else 1.0)
        aniPlayer.queue("jumpStart")
        aniPlayer.queue("jump")

  if aniPlayer:
    if aniPlayer.assigned_animation == "jumpSquat":
      vv = 0
      if pressingJump():
        jump_squat_jump_input_timer += (delta*22)
    if aniPlayer.assigned_animation != "jumpSquat" and jump_squat_jump_input_timer > 0:
      actuallyApplyJump()
      jump_squat_jump_input_timer = 0
      

  if isFeatherLike() and feather_jump_timer < feather_jump_time_limit and pressingJump() and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat"): 
    feather_jump_timer += (delta*22)
    if weak_feather_dbl_jump:
      feather_jump_timer += (delta*22)
    actuallyApplyJump(false)
  elif feather_jump_timer < 4 and pressingJump() and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat"):
    feather_jump_timer += (delta*22)
    if feather_jump_timer > 3: 
      actuallyApplyJump(false)
  elif pressingJump() and feather_jump_timer < feather_jump_partial_time_limit: 
    feather_jump_timer += (delta*22)
    
  if not is_touching_water and was_touching_water_at_start_of_jump and pressingJump():
    feather_jump_timer = 0
    should_magic_jump = true
    actuallyApplyJump(false)
    was_touching_water_at_start_of_jump = false
    
  if not pressingJump():
    weak_feather_dbl_jump = true
    if glitch_form != global.GlitchForm.FEATHER:
      feather_jump_timer = 200
      
  if vv > 0 or on_ground:
    should_magic_jump = false

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

func actuallyApplyJump(play_sound = true):
  if isFeatherLike():
    if not weak_feather_dbl_jump and feather_jump_timer < 5:
      if vv < (2*jump_force) / 3:
        vv = (2*jump_force) / 3
    elif not weak_feather_dbl_jump and feather_jump_timer < 8:
      if vv < jump_force / 2:
        vv = jump_force / 2
    elif not weak_feather_dbl_jump:
      if vv < jump_force / 2.3:
        vv = jump_force / 2.3
    else:
      if vv > -1:
        vv = jump_force / 3
  elif not play_sound:
    if vv < (1.58*jump_force)/3:
      vv = (1.58*jump_force)/3
  elif glitch_form == global.GlitchForm.INVISIBLE:
    vv = invisible_jump_force
  else:
    # rocket boost boots
    # vv = jump_force*3
    if pressingJump():
      vv = jump_force*1.1
    else:
      vv = jump_force*0.7
  if not is_touching_water and play_sound and jumpSound != null:
    playJumpSound()
  on_ground = false
  should_do_fallthrough_area_collision = false
  has_just_jumped_timer = 0 
  feather_fall_timer = 0
  if glitch_form == global.GlitchForm.FEATHER:
    should_magic_jump = false

func playJumpSound():
  jumpSound.play()

func isKindOfOnGround():
  # I'm on the ground or just fell off a platform...
  return isKindaSortaOfOnGround() and (not aniPlayer or not "jump" in aniPlayer.assigned_animation)
  
func isKindaSortaOfOnGround():
  # I'm on the ground or just fell off a platform...
  return on_ground or (was_just_on_ground_timer <= was_just_on_ground_time_limit and vv < 0)
    

const PROJECTION_ORTHOGONAL = 1
func processHorizontalInputs(delta):
  if is_climbing_ladder: return

  is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight()
  var is_pressing_opposite_horizontal_input = (pressingMoveLeft() and dir.x > 0) or (pressingMoveRight() and dir.x < 0)

  # Forward as "seen" by the camera (OpenGL convention)
  var view_forward = -getGameCamera().get_transform().basis.z
  var view_right = -getGameCamera().get_transform().basis.x
  # Forward as "seen" by the player
  var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()
  var right = view_right

  if glitch_form == global.GlitchForm.FEATHER and not (aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"):
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
    if is_pressing_opposite_horizontal_input and (aniPlayer == null or aniPlayer.assigned_animation == "jumpStart" or aniPlayer.assigned_animation == "turnAround"):
      if not glitch_form == global.GlitchForm.FLOOR or on_ground:
        dir = Vector3(0.0, 0.0, 0.0)
      

    if not global.pauseMoveInput and not (aniPlayer and aniPlayer.assigned_animation == "jumpSquat"):
      if pressingMoveLeft():
        should_teeter_turn_around = false
        if aniPlayer != null:
          # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
          if not mySprite.flip_h and on_ground and lv.x > 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
            dir += (right/2)*(delta*DNUMHORZ)
            if aniPlayer.assigned_animation != "turnAround":
              aniPlayer.stop()
              aniPlayer.clear_queue()
              aniPlayer.queue("turnAround")
              aniPlayer.queue("walkStart")
              addJumpSmokeCloud(true)
          elif mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
            dir += right*(delta*DNUMHORZ)
            mySprite.flip_h = true
            doWalkAnimation()
            if on_ground and should_always_do_jump_smoke_cloud:
              addJumpSmokeCloud(true)
        # if there's no animation player, there's no animation. just flip
        else:
          dir += right*(delta*DNUMHORZ)
          mySprite.flip_h = true
      elif pressingMoveRight():
        should_teeter_turn_around = false
        if aniPlayer != null:
          # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
          if mySprite.flip_h and on_ground and lv.x < 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
            dir -= (right/2)*(delta*DNUMHORZ)
            if aniPlayer.assigned_animation != "turnAround":
              aniPlayer.clear_queue()
              aniPlayer.play("turnAround")
              aniPlayer.queue("walkStart")
              addJumpSmokeCloud(true)
          elif not mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
            dir -= right*(delta*DNUMHORZ)
            mySprite.flip_h = false
            doWalkAnimation()
            if on_ground and should_always_do_jump_smoke_cloud:
              addJumpSmokeCloud(true)
        # if there's no animation player, there's no animation. just flip
        else:
          dir -= right*(delta*DNUMHORZ)
          mySprite.flip_h = false
  
  # TODO(jaketrower): Maybe this? seems complicated
  if not pressingMoveLeft() and not pressingMoveRight() and on_ground and aniPlayer and \
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
    DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/13.5)
    if not on_ground and is_pressing_horizontal_input:
      DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/10.8)
  if glitch_form == global.GlitchForm.FLOOR and not on_ground:
    DNUMSKID = DNUMSKID_BASE + (DNUMSKID_BASE/9)
    # TODO(jaketrower): RocketJumpBoots # DNUMSKID *= 2

  
  # TODO(Engine.time_scale suspect)
  if dir.length() > 1:
    dir = dir.normalized()
  if on_ground and not self.is_pressing_horizontal_input:
    dir = dir * 0.9*(delta*DNUMSKID)
    if dir.length() < 0.1:
      dir = Vector3(0, 0, 0)
  elif not on_ground:
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

  var curr_walk_speed = walk_speed
  # if glitch_form == global.GlitchForm.FLOOR and not on_ground and not jumped_from_true_ground:
  #     curr_walk_speed = floor_glitch_walk_speed
  if glitch_form == global.GlitchForm.FEATHER:
    curr_walk_speed = feather_glitch_walk_speed
  elif glitch_form == global.GlitchForm.INVISIBLE:
    curr_walk_speed = invisible_glitch_walk_speed
  elif is_touching_water:
    curr_walk_speed = swimming_walk_speed

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

func doWalkAnimation():
  if horizontal_collision:
    return

  if on_ground and aniPlayer.current_animation != "walkStart" and aniPlayer.current_animation != "walk":
    if aniPlayer.current_animation != "land":
      aniPlayer.clear_queue()
      aniPlayer.stop()
    var aa = aniPlayer.assigned_animation
    if aa == "stand" or aa == "turnAround" or aa == "walkStop" or aa == "walkBump":
      aniPlayer.queue("walkStart")
      addJumpSmokeCloud()
    aniPlayer.queue("walk")
    
# http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/
# https://info.sonicretro.org/SPG:Solid_Tiles
func handleCollisionsAndMove(local_lv, delta):
  if delta == 0:
    return local_lv
     
  # TODO(jaketrower): global.time_dilation_multiplier?
  var DNUM = 1.15
  local_lv.x *= delta*DNUM
  local_lv.y *= delta*DNUM

  if should_collide_horizontally:
    local_lv = handleHorizontalCollisions(local_lv)
  global_transform.origin.x += local_lv.x
  
  was_on_ground = on_ground
  if glitch_form == global.GlitchForm.LADDER and was_on_ground:
    on_ground = isWalkingIntoWall()
  elif glitch_form != global.GlitchForm.FLOOR:
    on_ground = false
  truly_on_ground = false
  half_on_ground = false
  if not should_do_fallthrough_area_collision and (should_collide_floor or should_collide_ceil):
    local_lv = handleVerticalCollisions(local_lv)
  elif should_do_fallthrough_area_collision:
    local_lv = collideWithFloor(local_lv)
    global_transform.origin.y = fallthrough_area_collision_y
  global_transform.origin.y += local_lv.y

  handleSpikeCollisions()
  
  if on_ground:
    if was_on_ground:
      fall_timer = 0
    feather_fall_timer = 0
  
  local_lv.x /= delta*DNUM
  local_lv.y /= delta*DNUM
  return local_lv

func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
  var checking_for_floor_collisions = is_vertical and sensor_direction == -1
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
  if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    return checking_for_floor_collisions and (tileCollisionShape is BoxShape or isTileFallthroughSolidTop(tile_type, tile_pos_coords))
  else:
    return tileCollisionShape is BoxShape or (checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords))
  
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
  var y = global_transform.origin.y
  var tb = get_node("CollisionShape").shape.height/2
  var bb = -tb
  var is_above_top_of_tile = y + bb > tile_pos_coords.y
  
  var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
  return is_above_top_of_tile and (tileCollisionShape is PlaneShape or (glitch_form == global.GlitchForm.WALK_THROUGH_WALLS and tileCollisionShape is BoxShape))
  
func isTileSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
  return tileCollisionShape is RayShape
  
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
    if not truly_on_ground:
      # add y speed to collision checking if we're in the air
      sensor.y += local_lv.y
  else:
    sensor.x += local_lv.x
  var tile_pos_and_type = doSensorProbe(is_vertical, sensor, sensor_direction, tile_anchor)
  var tile_pos = tile_pos_and_type.x
  var tile_type = tile_pos_and_type.y
  var tile_distance = (tile_pos*sensor_direction) - ((x+sensor_anchor) * sensor_direction)
  if is_vertical:
    tile_distance = (tile_pos*sensor_direction) - ((y+sensor_anchor) * sensor_direction)
  return Vector3(tile_pos, tile_distance, tile_type)

func collideWithFloor(local_lv):
  local_lv.y = 0
  on_ground = true
  truly_on_ground = true
  return local_lv

func reactToPotentialCollisions(_tile_type, tile_distance, is_vertical, local_lv, _sensor_anchor, sensor_direction, _tile_anchor, should_collide_with_floor, debug = false):
  if tile_distance <= 0:
    if debug:
      # print("collide sensor A...")
      if not is_vertical: get_tree().paused = true
    # push player out of the tile!
    if is_vertical:
      global_transform.origin.y += tile_distance * sensor_direction
      if should_collide_with_floor:
        local_lv = collideWithFloor(local_lv)
      else:
        local_lv.y = 0
        if feather_jump_timer < feather_jump_partial_time_limit:
          feather_jump_timer = feather_jump_partial_time_limit
    else:
      global_transform.origin.x += tile_distance * sensor_direction
      collideWithWall(local_lv)
      local_lv.x = 0
  elif is_vertical and tile_distance < local_lv.y * sensor_direction:
    global_transform.origin.y += tile_distance * sensor_direction
    if should_collide_with_floor:
      local_lv = collideWithFloor(local_lv)
    else:
      local_lv.y = 0
      if feather_jump_timer < feather_jump_partial_time_limit:
        feather_jump_timer = feather_jump_partial_time_limit
  elif not is_vertical and tile_distance < local_lv.x * sensor_direction:
    global_transform.origin.x += tile_distance * sensor_direction
    collideWithWall(local_lv)
    local_lv.x = 0
  return local_lv

func collideWithWall(local_lv):
  self.horizontal_collision = true
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
  if aniPlayer and should_play_bump:
    var aa = aniPlayer.assigned_animation
    if not was_on_ground and not is_touching_water:
      if local_lv.y > 0 and aa != "jumpBump" and aa != "jumpSquat":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.play("jumpBump", -1, bump_ani_speed)
        aniPlayer.queue("jump")
      elif local_lv.y < 0 and aa != "fallBump" and aa != "fallFar":
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.play("fallBump", -1, bump_ani_speed)
        aniPlayer.queue("fall")
    # TODO(jaketrower): Should probably have like an animationState FSM (along with physics state?)
    elif ((was_on_ground and not ladder_glitch) or (truly_on_ground and ladder_glitch)) \
       and aa != "walkBump" and ("walk" in aa or "land" in aa):
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("walkBump", -1, bump_ani_speed)
      if glitch_form == global.GlitchForm.LADDER:
        aniPlayer.queue("walk")
      else:
        aniPlayer.queue("stand")
  dir = Vector3(0, 0, 0)

func performCollisionCheck(is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug = false):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var lb = -get_node("CollisionShape").shape.radius
  var rb = -lb
  var tb = get_node("CollisionShape").shape.height/2
  var bb = -tb

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
    var middle_sensor = Vector2(x+sensor_anchor, y)
    if is_vertical: middle_sensor = Vector2(x, y+sensor_anchor)
    var tile_pos_and_distance_and_type_middle = probeSensorForTileDistance(middle_sensor, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor)
    var middle_tile_distance = tile_pos_and_distance_and_type_middle.y
    var middle_tile_type = tile_pos_and_distance_and_type_middle.z

    local_lv = reactToPotentialCollisions(middle_tile_type, middle_tile_distance, is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor)
    return local_lv

func handleHorizontalCollisions(local_lv):
  self.horizontal_collision = false
  var rb = get_node("CollisionShape").shape.radius
  var lb = -rb
  var TILE_WIDTH = getLevelTiles().cell_size.x

  # check for left collisions
  if local_lv.x < 0 or pressingMoveLeft():
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(false, local_lv, lb - 0.2, -1, TILE_WIDTH, false)

  # check for right collisions
  if local_lv.x > 0 or pressingMoveRight():
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(false, local_lv, rb + 0.2, 1, 0, false)
  return local_lv
  
  
func handleVerticalCollisions(local_lv):
  var tb = get_node("CollisionShape").shape.height/2
  var bb = -tb
  var TILE_HEIGHT = getLevelTiles().cell_size.y

  # check for bottom collisions
  if should_collide_floor and (truly_on_ground or local_lv.y <= 0):
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(true, local_lv, bb, -1, TILE_HEIGHT, true)

  # check for top collisions
  if should_collide_ceil and not truly_on_ground and local_lv.y > 0:
    # params are is_vertical, local_lv, sensor_anchor, sensor_direction, tile_anchor, should_collide_with_floor, debug
    local_lv = performCollisionCheck(true, local_lv, tb, 1, 0, false)
  
  return local_lv
  
func handleSpikeCollisions():
  pass

func postProcessInputs(_delta):
  pass
  
func landed():
  var quiet_the_fall_sound = true
  last_grounded_y = global_transform.origin.y 
  if landSound: landSound.play()
  addJumpSmokeCloud()
  if aniPlayer != null and not global.pauseGame and last_vv < 1 and aniPlayer.assigned_animation != "jumpSquat" and aniPlayer.assigned_animation != "jumpStart":
    aniPlayer.clear_queue()
    if fall_timer > 30 and not glitch_form == global.GlitchForm.FEATHER:
      quiet_the_fall_sound = false
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("fallFlat", -1, 1.0)
      physics_state = PhysicsState.COLLAPSED
      if bumpSound: bumpSound.play()
    # TODO(jaketrower): all of this non FSM animation code WILL break everything some day
    elif aniPlayer.assigned_animation != "getItem" and not "fishing" in aniPlayer.assigned_animation:
      # if horizontal_collision:
      #     aniPlayer.play("landBump", -1, 1.0 if isFeatherLike() else 1.5)
      # else:
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("land", -1, 1.0 if isFeatherLike() else 1.5)
  if fallSound and quiet_the_fall_sound:
    fallSound.stop()
  fall_timer = 0

func isWalkingIntoWall():
  return abs(linear_velocity.x) < 0.5 \
       and is_pressing_horizontal_input and was_pressing_horizontal_input \
       and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat") 

func updateFacing(local_dir):
  if local_dir.x != 0 or local_dir.y != 0 or local_dir.z != 0:
    facing = local_dir
    is_walking = true
  else:
    is_walking = false

func isRectColliding(o_lb, o_tb, o_rb, o_bb, lb, tb, rb, bb, debug_ = false):
  if debug_:
    print("\tisRectColliding: " + str(lb <= o_rb) + ", " + str(rb >= o_lb) + ", " + str(tb >= o_bb) + ", " + str(bb <= o_tb))
  if lb <= o_rb and rb >= o_lb and tb >= o_bb and bb <= o_tb:
    return true
  return false
