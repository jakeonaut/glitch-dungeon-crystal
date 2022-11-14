extends "../GameMover.gd"

onready var interactionArea = get_node("InteractionArea")

var broom_timer = 0
var broom_time_limit = 2
var broom_state = 0
var can_broom = global.can_broom
var jump_press_timer = 999
var jump_press_time_limit = 5
var jump_press_broom_time_limit = 30
var target_last_grounded_y = 0
var pauseInput = false

var has_played_fall_sound = false

var has_sweeped_glitch = false

var cherryCarcassRes = preload("res://sceneObjects/CherryCarcass.tscn")

onready var cameraTarget = get_node("CameraTarget")
var camera_target_origin_x_target = 0

func _ready():
  set_physics_process(true)
  set_process(true)
  
  should_do_middle_sensor = true
  should_do_simple_sensor_probe = false
  target_last_grounded_y = global_transform.origin.y

func ladderUpdateTargetLastGroundedY():
  target_last_grounded_y = global_transform.origin.y
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if is_touching_water or is_touching_ladder or global_transform.origin.y < target_last_grounded_y:
    target_last_grounded_y = global_transform.origin.y
  
  if jump_press_timer <= jump_press_broom_time_limit:
    jump_press_timer += 1

  if justPressedJump():
    jump_press_timer = 0
    if has_sweeped_glitch and aniPlayer.assigned_animation == "broomSweep":
      has_sweeped_glitch = false
      target_last_grounded_y = global_transform.origin.y
      should_magic_jump = true
    
  # this is a little weird but fixes the fallthrough area situation:
  if linear_velocity.y < 0:
    interactionArea.transform.origin.y = -2
  else:
    interactionArea.transform.origin.y = 0
    
  if linear_velocity.x > 0.5:
    camera_target_origin_x_target = 2
  elif linear_velocity.x < -0.5:
    camera_target_origin_x_target = -2

  cameraTarget.transform.origin.x = cameraTarget.transform.origin.x + (camera_target_origin_x_target - cameraTarget.transform.origin.x) * (delta*5)
  if stepify(cameraTarget.transform.origin.x, 0.1) == camera_target_origin_x_target:
    cameraTarget.transform.origin.x = camera_target_origin_x_target
  cameraTarget.global_transform.origin.y = target_last_grounded_y


  if global.memory.has("fishingRod") and on_ground and justPressedDown():
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.queue("fishingSitDown")

func _physics_process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if not global.pauseGame and pauseSelf:
    # linear_velocity = handleCollisionsAndMove(linear_velocity, delta)
    pass

func playJumpSound():
  jumpSound.pitch_scale = rand_range(0.9, 1.1)
  .playJumpSound()

# @override
func landed():
  .landed()
  has_sweeped_glitch = false
  global.num_cherries_eaten = global.num_cherries_gained

# @override
func justPressedDown():
  return Input.is_action_just_pressed("ui_down") and not pauseInput

# @override
func pressingDown():
  return Input.is_action_pressed("ui_down") and not pauseInput

# @override
func justPressedJump():
  return (Input.is_action_just_pressed("jump_button") and not pauseInput) or should_magic_jump
  
# @override
func recentlyJustPressedJump():
  return jump_press_timer < jump_press_time_limit

# @override
func pressingJump():
  return (Input.is_action_pressed("jump_button") and not pauseInput) or should_magic_jump

# @override
func pressingMoveUp():
  return Input.is_action_pressed("ui_up") and not pauseInput
  
# @override
func pressingMoveDown():
  return Input.is_action_pressed("ui_down") and not pauseInput
  
# @override
func pressingMoveLeft():
  return Input.is_action_pressed("ui_left") and not pauseInput

# @override
func pressingMoveRight():
  return Input.is_action_pressed("ui_right") and not pauseInput

func magicJump():
  should_magic_jump = true

func processJumpInputs(delta):
  if not is_touching_ladder and not is_touching_water and not isKindaSortaOfOnGround() and not on_ground:
    if global.num_cherries_eaten > 0 and glitch_form == global.GlitchForm.INVISIBLE:
      if justPressedJump() and not should_magic_jump and not global.pauseMoveInput: 
        was_just_on_ground_timer = was_just_on_ground_time_limit
        jumped_from_true_ground = truly_on_ground
        jump_squat_jump_input_timer = 1
        feather_jump_timer = 0
        weak_feather_dbl_jump = false
        should_magic_jump = true
        if on_ground:
          addJumpSmokeCloud()
  
        if not "jump" in aniPlayer.assigned_animation:
          aniPlayer.clear_queue()
          aniPlayer.play("jumpSquat", -1, 1.0 if isFeatherLike() else 1.0)
          aniPlayer.queue("jumpStart")
          aniPlayer.queue("jump")

        target_last_grounded_y = global_transform.origin.y
        var new_carcass = cherryCarcassRes.instance()
        level.add_child(new_carcass)
        new_carcass.global_transform.origin = self.global_transform.origin
        new_carcass.mySprite.flip_h = mySprite.flip_h
        if randi() % 4 == 1:
          new_carcass.mySprite.flip_h = not new_carcass.mySprite.flip_h
        tryDieToEnemy(true, false)
        global.num_cherries_eaten -= 1
        
  .processJumpInputs(delta)
    

# @override
func handleSpikeCollisions():
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var rb = get_node("CollisionShape").shape.radius
  var lb = -rb
  var tb = get_node("CollisionShape").shape.height/2
  var bb = -tb
  
  var TILE_WIDTH = levelTiles.cell_size.x
  var TILE_HEIGHT = levelTiles.cell_size.y
  
  var margin = 0.12

  for i in range(int(round(y+bb-0.24))-1, int(round(y+tb))+1):
    for j in range(int(round(x+lb))-1, int(round(x+rb))+1):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
      var tile_x = tile_pos.x - TILE_WIDTH/2
      var tile_y = tile_pos.y - TILE_HEIGHT/2
      if isTileSpikes(tile_type) and isRectColliding(
        tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
        x + lb + margin, y + tb - margin, x + rb - margin, y + bb + margin
      ):
        tryDieToEnemy(true, false)
        return
