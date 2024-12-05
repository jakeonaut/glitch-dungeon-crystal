extends "GlitchEnemy.gd"

onready var thudSound = get_node("Sounds/ThudSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var SHELL_GRAV = 28
var should_big_bump = false
onready var myManager = get_node("..")

func _ready():
    if getMyStaticLevelZoneVar():
        visible = false
        queue_free()
        return

    set_process(true)
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2
    should_smack_pause_me = false

func _process(delta):
  # ._process(delta) implicit

  if not visible:
    updateFallthroughSolids()
    return

  if global.activeInteractor == self:
    self.global_transform.origin = level.player.global_transform.origin
    self.global_transform.origin.y += 2
    self.global_transform.origin.z += 2
    self.myOtherSprite.flip_h = level.player.mySprite.flip_h

  delta = delta * global.time_dilation_multiplier
  secretAniPlayer.playback_speed = global.time_dilation_multiplier

  if is_smacked and glitch_tiles_around_me:
    glitchTilesAroundMe()

  if physics_state == PhysicsState.NORMAL and "slowSpin" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing() and not pauseAnimation:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("popOutHead")

func flipWalkingDirection():
  .flipWalkingDirection()
  landSound.play()
  if not on_ground:
    if walk_direction.x < 0:
      secretAniPlayer.play("spinForwardReverse")
    elif walk_direction.x > 0:
      secretAniPlayer.play("spinForward")

  if not is_extra_bouncy and physics_state == PhysicsState.NORMAL and on_ground: # i don't know how we got into this state.
    if secretAniPlayer.assigned_animation == "spinForward":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForwardReverse")
    elif secretAniPlayer.assigned_animation == "spinForwardReverse":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForward")

# @override
func doVerticalWalkingBehavior():
  if behavior_walking and walk_direction.y != 0:
    if not on_ground and linear_velocity.y == 0:
      walk_direction.y = -1
      grav = 60
      if should_big_bump:
        glitch_tiles_around_me = true
        getSmacked(null, true)
        thudSound.play()
      should_big_bump = false
  
func tumbleFall(direction_vector, is_corrupted = false):
  if physics_state == PhysicsState.GLITCH_DYING:
    return

  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  var x_val = 0
  var jump_val = 5 if not is_corrupted else 0
  if direction_vector.x < 0:
    secretAniPlayer.play("spinForwardReverse")
    x_val = -10
  elif direction_vector.x > 0:
    secretAniPlayer.play("spinForward")
    x_val = 10
  elif direction_vector.y > 0:
    secretAniPlayer.play("spinForward")
    jump_val = 10
    grav = 0
  elif direction_vector.y < 0:
    secretAniPlayer.play("spinForwardReverse")
    jump_val = -10

  if is_corrupted:
    unsmack()
    grav = 0
    on_ground = false
    should_big_bump = true
    x_val *= 1.5
    jump_val *= 1.5
  else:
    on_ground = true
    grav = SHELL_GRAV
  behavior_walk_flip = not should_big_bump
  physics_state = PhysicsState.BEING_TOSSED
  global.pauseGame = false
  global.pauseMoveInput = false
  pauseAnimation = true
  should_collide_floor = true
  can_collide_with_floor = true
  behavior_was_thrown = true
  behavior_walking = true
  walk_direction = direction_vector
  on_ground = false
  walk_speed = abs(x_val)
  hv = Vector3(x_val, 0, 0)
  dir = Vector3(x_val, 0.0, 0.0)
  linear_velocity.x = x_val
  lv.x = x_val

  vv = jump_val
  linear_velocity.y = jump_val
  lv.y = jump_val
  fall_timer = -999

# @ override
func isActive(_debug=false):
  # same as GlitchEnemy.gd except allow is_smacked to still count as "active"
  if global.activeInteractor == self:
    return false
  return visible and not behavior_evolve and not is_frozen and not am_i_dying and (glitch_form == global.GlitchForm.NORMAL or glitch_form == getPlayer().glitch_form)

func collideWithWall(local_lv):
  if should_big_bump:
    glitch_tiles_around_me = true
    getSmacked(null, true)
    thudSound.play()
    # physics_state = PhysicsState.NORMAL
    # if secretAniPlayer.assigned_animation == "spinForward":
    #   secretAniPlayer.stop()
    #   secretAniPlayer.clear_queue()
    #   secretAniPlayer.play("land")
    # elif secretAniPlayer.assigned_animation == "spinForwardReverse":
    #   secretAniPlayer.stop()
    #   secretAniPlayer.clear_queue()
    #   secretAniPlayer.play("landRight")
  should_big_bump = false
  return .collideWithWall(local_lv)

# func collideWithCeiling(local_lv):
#   if should_big_bump:
#     glitch_tiles_around_me = true
#     getSmacked(null, true)
#     thudSound.play()
#   should_big_bump = false
#   return .collideWithCeiling(local_lv)

var glitch_tiles_around_me = false
func landed():
  .landed()

  if not is_extra_bouncy:
    behavior_jumping = false
  if physics_state == PhysicsState.BEING_TOSSED:
    if should_big_bump:
      getSmacked(null, true)
      thudSound.play()
    should_big_bump = false
    physics_state = PhysicsState.NORMAL
    if not is_extra_bouncy:
      if walk_direction.x != 0:
        walk_speed = 7
        if secretAniPlayer.assigned_animation == "spinForward":
          secretAniPlayer.stop()
          secretAniPlayer.clear_queue()
          secretAniPlayer.play("slowSpinForward")
        elif secretAniPlayer.assigned_animation == "spinForwardReverse":
          secretAniPlayer.stop()
          secretAniPlayer.clear_queue()
          secretAniPlayer.play("slowSpinForwardReverse")
      else:
        behavior_walking = false
        behavior_was_thrown = false
        if secretAniPlayer.assigned_animation == "spinForward":
          secretAniPlayer.stop()
          secretAniPlayer.clear_queue()
          secretAniPlayer.play("slowSpinForward")
        elif secretAniPlayer.assigned_animation == "spinForwardReverse":
          secretAniPlayer.stop()
          secretAniPlayer.clear_queue()
          secretAniPlayer.play("slowSpinForwardReverse")
  elif not is_extra_bouncy:
    if secretAniPlayer.assigned_animation == "spinForward":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForward")
    elif secretAniPlayer.assigned_animation == "spinForwardReverse":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForwardReverse")

# @override
func canSwim():
  return false

func slowDownMore():
  walk_speed = 4

func okayStop():
  behavior_was_thrown = false
  behavior_walking = false

func becomeACrab():
  if pauseAnimation:
    return
  if myManager.glitchHermitCrab.get_ref() != null:
    var glitchHermitCrab = myManager.glitchHermitCrab.get_ref()
    glitchHermitCrab.visible = true
    glitchHermitCrab.global_transform.origin = self.global_transform.origin
    glitchHermitCrab.secretAniPlayer.stop()
    glitchHermitCrab.secretAniPlayer.clear_queue()
    glitchHermitCrab.secretAniPlayer.play("prepare")
    glitchHermitCrab.crab_state = glitchHermitCrab.CrabState.RESPAWN_PREPARE
    glitchHermitCrab.spawn_origin = self.global_transform.origin
    glitchHermitCrab.pauseAnimation = false
    visible = false

# @override
func getSmacked(broom_origin = null, silently = false):
  die_offscreen_timer = 0
  # if should_big_bump:
  #   .getSmacked(broom_origin, silently)
  #   dieSound.play()
  #   notDieSound.stop()
  #   return

  if not silently:
    if (broom_origin != null and broom_origin.x <= self.global_transform.origin.x) or (broom_origin == null and not level.player.mySprite.flip_h):
      tumbleFall(Vector2(1, 0), false)
    elif (broom_origin != null and broom_origin.x > self.global_transform.origin.x) or (broom_origin == null and level.player.mySprite.flip_h):
      tumbleFall(Vector2(-1, 0), false)
    var jump_val = 10
    vv = jump_val
    linear_velocity.y = jump_val
    lv.y = jump_val
  if is_extra_bouncy:
    behavior_jumping = true
  return .getSmacked(broom_origin, silently)

var die_offscreen_timer = 0
var die_offscreen_time_limit = 10
# @override
func actuallyDieToOffscreenCamera(delta):
  if physics_state == PhysicsState.BEING_TOSSED:
    global_transform.origin.y -= 2
    linear_velocity.y = 0
    lv.y = 0
    vv = 0
    die_offscreen_timer = 0
    if should_big_bump:
      getSmacked(null, true)
    should_big_bump = false
    physics_state = PhysicsState.NORMAL
    behavior_was_thrown = false
    behavior_walking = false
    behavior_jumping = false
  die_offscreen_timer += (delta*11)
  if die_offscreen_timer >= die_offscreen_time_limit:
    myManager.dieOffscreen()
    die_offscreen_timer = 0

# @override
func unsmack():
  if grav == 0:
    grav = SHELL_GRAV
  .unsmack()
  glitch_tiles_around_me = false
  is_smacked = false

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
func activate(_is_player):
  if is_extra_bouncy:
    return false
  if global.activeInteractor == null:
    should_big_bump = false
    physics_state = PhysicsState.NORMAL
    is_smacked = false
    behavior_was_thrown = false
    behavior_walking = false
    behavior_jumping = false
    rotation_degrees.z = 0
    global.activeInteractor = self
    global.memory["broom"] = false
    level.player.inventorySound.play()
    if level.player.summonedBroom:
      level.player.broomStop()
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("RESET")

# activeInteractor responsibilities... sorry
var am_i_a_textbox = false
var textboxParent = null
var is_tiny = false
var is_important = false
var can_camera_zoom = false
var textboxCameraTarget = null
func InteractActivate():
  if global.activeInteractor == self:
    global.activeInteractor = null
    level.player.getABroom()
    var direction_vector = Vector2(1 if not level.player.mySprite.flip_h else -1, 0)
    tumbleFall(direction_vector, false)
    pauseAnimation = false
  
func hideTextbox():
  pass

func stopInteract():
  pass

func tryStopInteractPassive():
  pass

# @override
func handleSpikeCollisions(_delta):
  if not behavior_walking:
    return
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  
  var TILE_WIDTH = levelTiles.cell_size.x
  var TILE_HEIGHT = levelTiles.cell_size.y

  var amt = 0.5 if should_big_bump else 0.0
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
        getLevelTiles().infectSpikes(coords)