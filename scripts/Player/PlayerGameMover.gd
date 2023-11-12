extends "../GameMover.gd"

onready var interactionArea = get_node("InteractionArea")

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

var new_carcass = null
var cherryCarcassRes = preload("res://sceneObjects/CherryCarcass.tscn")
var spriteSheet = preload("res://assets/player_sheet_old.png")
var spriteSheetNoBroom = preload("res://assets/player_sheet_old_nobroom.png")
var spriteSheetTiny = preload("res://assets/player_sheet_tiny.png")
var broomSpriteSheetTiny = preload("res://assets/player_sheet_broom_tiny.png")
var is_tiny = false

onready var nullifySound = get_node("Sounds/NullifySound")
onready var rechargeSound = get_node("Sounds/RechargeSound")
onready var cameraTarget = get_node("CameraTarget")
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
var mushroom_turn_time_limit = 2

func _ready():
  set_physics_process(true)
  set_process(true)
  
  should_do_middle_sensor = true
  should_do_simple_sensor_probe = false
  target_last_grounded_y = global_transform.origin.y

func ladderUpdateTargetLastGroundedY():
  target_last_grounded_y = global_transform.origin.y

func processPauseAnimation():
  if aniPlayer.assigned_animation == "hookCaught":
    return
  
  if is_mushroom_infected:
    pauseAnimation = true # (not on_ground or (on_ground and (justPressedJump() or recentlyJustPressedJump()))) and not has_mushroom_double_jumped
    if pauseAnimation and aniPlayer.assigned_animation != "walk" and not "etItem" in aniPlayer.assigned_animation:
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("walk")
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  processPauseAnimation()

  if is_touching_water or is_touching_ladder or global_transform.origin.y < target_last_grounded_y:
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

  if is_tiny and Input.is_action_just_pressed("sub_action_button"):
    regainNestingDoll()

  # if global.memory.has("fishingRod") and on_ground and justPressedDown():
  #   aniPlayer.stop()
  #   aniPlayer.clear_queue()
  #   aniPlayer.queue("fishingSitDown")
    

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

  if global.memory["mp"] > 0:
    sparkle_timer += (delta*22)
    if sparkle_timer >= sparkle_time_limit:
      global.memory["mp"] -= 1
      showMpTimer = 0
      
      spawnOneSparkle(.5, above_the_head)
      spawnOneSparkle(-.5, above_the_head)
      sparkle_timer = 0
      if global.memory["mp"] == 0:
        mySprite.get_material_override().set_shader_param("opacity", 1.0)
        self.normalGlitch()
        nullifySound.play()
        blink_timer = 0
        blink_time_limit = 20
        is_blinked = false

func normalGlitch():
  glitch_form = global.GlitchForm.NORMAL
  level.normalGlitch()
  changeSpriteColorPalette(global.player_base_palette)
  # mySprite.setNormalClothes()

func changeSpriteColorPalette(palette):
  if level.spellbook_forbidden:
    return

  mySprite.material_override.set_shader_param("target_palette", palette)
  print(palette)

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
  jumpSound.pitch_scale = rand_range(0.8, 1.2)
  .playJumpSound()

# @override
func landed():
  .landed()
  has_sweeped_glitch = false
  global.num_cherries_eaten = global.num_cherries_gained
  has_mushroom_double_jumped = false

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
  # if is_mushroom_infected:
  #   return mushroom_infection_direction == -1
  return Input.is_action_pressed("ui_left") and not pauseInput

# @override
func pressingMoveRight():
  # if is_mushroom_infected:
  #   return mushroom_infection_direction == 1
  return Input.is_action_pressed("ui_right") and not pauseInput

func magicJump():
  should_magic_jump = true
  actuallyApplyJump(false)

func regainNestingDoll():
  global.memory["nesting_doll"] = true
  if is_tiny:
    is_tiny = false
    mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
    global.memory["broom"] = global.memory["had_broom"]
    if new_carcass != null:
      new_carcass.queue_free()
      new_carcass = null

# @override
func getWalkSpeed(delta):
  # var is_really_pressing_horizontal_input = (pressingRun() and on_ground) or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
  # if is_mushroom_infected:
  #  return 0 if mushroom_turn_timer > 0 else 6 if is_really_pressing_horizontal_input else 1
  if not global.memory["broom"] and global.memory["has_gotten_broom"] > 0:
    return 7 if pressingRun() and on_ground else 6
  else:
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
func getABroom():
  pauseAnimation = false 
  global.memory["broom"] = true
  global.memory["has_gotten_broom"] = 2
  mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  smacked_npc = null
  is_in_broom_cooldown = false

onready var infectSound = get_node("Sounds/InfectSound")
onready var wormSound = get_node("Sounds/WormSound")
var has_mushroom_double_jumped = false
var mush_carcasses = []
var max_num_mush_carcasses = 3
func processJumpInputs(delta):
  if not is_touching_ladder and not is_touching_water and not isKindaSortaOfOnGround() and not on_ground:
    var triedToDoubleJump = justPressedJump() and not should_magic_jump and not global.pauseMoveInput
    if is_mushroom_infected and not has_mushroom_double_jumped and triedToDoubleJump:
      has_mushroom_double_jumped = true
      feather_jump_timer = 0
      wormSound.play()
      # var turning_left = mushroom_infection_direction == 1 and Input.is_action_pressed("ui_left")
      # var turning_right = mushroom_infection_direction == -1 and Input.is_action_pressed("ui_right")
      # if turning_left or turning_right:
      #   mushroom_infection_direction = -mushroom_infection_direction
      for _i in range(5):
        spawnASpore(0, -1)
      # is_mushroom_infected = false
      summonSmokeClouds(2, true, true)
      aniPlayer.clear_queue()
      aniPlayer.play("jumpSquat", -1, 1.0 if isFeatherLike() else 1.0)
      aniPlayer.queue("jumpStart")
      aniPlayer.queue("jump")
      var mush_carcass = cherryCarcassRes.instance()
      level.add_child(mush_carcass)
      mush_carcass.global_transform.origin = self.global_transform.origin
      mush_carcass.mySprite.flip_h = mySprite.flip_h
      mush_carcasses.push_back(weakref(mush_carcass))
      var num_mush_carcasses = len(mush_carcasses)
      # remove freed mush_carcasses
      for _i in range(num_mush_carcasses):
        var mush_carcass_ref = mush_carcasses.pop_front()
        if mush_carcass_ref.get_ref() != null:
          mush_carcasses.push_back(mush_carcass_ref)
      # free mushrooms when there are too many
      while len(mush_carcasses) > max_num_mush_carcasses:
        mush_carcasses.pop_front().get_ref().queue_free()
    elif global.memory["nesting_doll"] and triedToDoubleJump: 
      doubleJump()
      new_carcass = cherryCarcassRes.instance()
      level.add_child(new_carcass)
      new_carcass.global_transform.origin = self.global_transform.origin
      new_carcass.mySprite.flip_h = mySprite.flip_h
      # if randi() % 4 == 1:
      #   new_carcass.mySprite.flip_h = not new_carcass.mySprite.flip_h
      global.memory["nesting_doll"] = false
      global.memory["had_broom"] = global.memory["broom"]
      global.memory["broom"] = false
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)
      is_tiny = true
        
  .processJumpInputs(delta)

var sporeRes = preload("res://sceneObjects/Environment/PlayerSpore.tscn")
func spawnASpore(x_dir = 0, y_dir = 1):
  summonSmokeClouds(1, 0, 0, 0)
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
  
  var margin = 0.12

  for i in range(int(round(y+bb-0.24))-1, int(round(y+tb))+1):
    for j in range(int(round(x+lb))-1, int(round(x+rb))+1):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
      var tile_x = tile_pos.x - TILE_WIDTH/2
      var tile_y = tile_pos.y - TILE_HEIGHT/2
      if isTileSpikes(tile_type) and not getLevelTiles().isNeighborOfInfectedSpikes(coords) and isRectColliding(
        tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
        x + lb + margin, y + tb - margin, x + rb - margin, y + bb + margin
      ):
        tryDieToEnemy(delta, true, false)
        return
