extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var aniPlayer = get_node("AnimationPlayer")
onready var appearSound = get_node("AppearSound")
onready var popSound1 = get_node("PopSound")
onready var popSound2 = get_node("PopSound2")
onready var popSound3 = get_node("PopSound3")
onready var purifyArea = get_node("PurifyArea")
onready var purifyShape = get_node("PurifyArea/CollisionShape")
var my_original_pos = null
var my_target_pos = null
var opacity = 0.5
var target_opacity = 1.0
var didja_get_me = false
export var pop_from_distance = true
export var is_horizontal = false
var horizontal_direction = 1
var pop_distance = 30
var pop_timer = 0
var pop_time_limit = 90
var my_parent = null
var my_speed = 2
var my_speed_start = null
var my_speed_max = null
var my_acc = 5
var has_set_origin = false
var can_purify = false
export var is_dark = false


onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player
  
var gameCamera = null
func getGameCamera():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

func _ready():
  appearSound.play()
  mySprite.material_override = mySprite.material_override.duplicate()
  if is_dark:
    aniPlayer.queue("dark_bubbleGrow")
    aniPlayer.queue("dark_bubble")
  else:
    aniPlayer.queue("bubbleGrow")
    aniPlayer.queue("bubble")
  
  if is_horizontal:
    my_original_pos = global_transform.origin.y
  else:
    my_original_pos = global_transform.origin.x
  randomizeTargetPos()
  if my_speed_start:
    my_speed = my_speed_start
    my_speed_max = rand_range(2, 3.5)
  else:
    my_speed = rand_range(2, 3.5)

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if my_speed_max != null and my_speed < my_speed_max:
    my_speed += my_acc * delta
  
  if didja_get_me:
    if not mySprite.visible:
      queue_free()
  else:
    if can_purify:
      hitStuff(delta)
      
    # pop_timer += (delta*22)
    # if pop_timer >= pop_time_limit:
    #   bubbleStartPop()

    if is_horizontal:
      global_transform.origin.x += delta*my_speed*horizontal_direction

      global_transform.origin.y = global_transform.origin.y + (my_target_pos - global_transform.origin.y) * (delta*5)
      if stepify(global_transform.origin.y, 0.1) == stepify(my_target_pos, 0.1):
        if my_speed_max != null and not has_set_origin:
          my_original_pos = global_transform.origin.y
          has_set_origin = true
        # randomizeTargetPos()
    else:
      global_transform.origin.y += delta*my_speed

      global_transform.origin.x = global_transform.origin.x + (my_target_pos - global_transform.origin.x) * (delta*5)
      if stepify(global_transform.origin.x, 0.1) == stepify(my_target_pos, 0.1):
        if my_speed_max != null and not has_set_origin:
          my_original_pos = global_transform.origin.x
          has_set_origin = true
        # randomizeTargetPos()

    opacity = opacity + (target_opacity - opacity) * (delta * 5)
    mySprite.material_override.set_shader_param("opacity", opacity)
    if stepify(opacity, 0.1) == stepify(target_opacity, 0.1):
      if target_opacity == 1.0:
        target_opacity = 0.5
      else:
        target_opacity = 1.0

    tryDieToOffscreenCamera(delta)
    bulletTryDieToSolids()
    # if pop_from_distance and \
    #    global_transform.origin.y > getPlayer().global_transform.origin.y and \
    #    global_transform.origin.distance_to(getPlayer().global_transform.origin) > pop_distance:
    #   popSound1.max_db = -100
    #   popSound2.max_db = -100
    #   bubbleStartPop()

func isActive(_debug=false):
  return true

var can_broom_pop_me = true
func passiveActivate(_delta, is_player, is_local_broom = false):
  if didja_get_me or global.pauseGame or (is_player and level.player.transformation == level.player.TransformationState.BUBBLE):
    return

  if not is_player and not is_local_broom and not can_broom_pop_me:
    return
  bubbleStartPop()
  if not is_player and not is_local_broom:
    return

  if getPlayer().transformation == getPlayer().TransformationState.FISHY:
    return
  popSound3.pitch_scale = rand_range(1.0, 1.9)
  popSound3.play()
  if getPlayer().physics_state == getPlayer().PhysicsState.BEING_TOSSED and getPlayer().glitch_form == global.GlitchForm.FLOOR:
    return
  if not getPlayer().pressingDown() and (getPlayer().linear_velocity.y <= 0 or getPlayer().on_ground):
    getPlayer().camera_target_y_pos = getPlayer().global_transform.origin.y
    getPlayer().was_just_on_ground_timer = -8
    getPlayer().magicJump()
    if getPlayer().linear_velocity.y < 0:
      getPlayer().linear_velocity.y = -0.01
    if not getPlayer().isFeatherLike():
      getPlayer().physics_vars.applyHalfGrav = true
      getPlayer().physics_vars.applyHalfGravTimer = 5
    if getPlayer().nesting_doll_state == global.NestingDoll.BABY:
      var jump_val = 14
      getPlayer().linear_velocity.y = jump_val
      getPlayer().lv.y = jump_val
      getPlayer().vv = getPlayer().up.dot(getPlayer().lv)
  else:
    getPlayer().has_sweeped_glitch = true

func bubbleStartPop():
  if didja_get_me:
    return

  popSound1.play()
  popSound2.play()
  aniPlayer.clear_queue()
  aniPlayer.stop()
  mySprite.frame_delay = 0.1
  mySprite.should_randomize_frame_delay = false
  mySprite.updateBaseFrame(0, 1)
  mySprite.should_soft_fizzle_out = true
  didja_get_me = true
  global_transform.origin.y += .625

func touchCorporealBody(body):
  if body == level.player.smallInteractionArea:
    bubbleStartPop()

var my_diff_max = 2
func randomizeTargetPos():
  my_target_pos = my_original_pos + rand_range(-my_diff_max, my_diff_max)

func bulletTryDieToSolids():
  for x in range(global_transform.origin.x - 2, global_transform.origin.x + 2):
    var y = global_transform.origin.y + 1
    
    var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
    var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    if isTileSolid(tile_type_a, true, 1, tile_pos_a):
      popSound1.max_db = -100
      popSound2.max_db = -100
      bubbleStartPop()
      break

func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
  var checking_for_floor_collisions = is_vertical and sensor_direction == -1
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = getLevelTiles().mesh_library.get_item_name(tile_type)
  return (global.isTileSolid(tile_type, getLevelTiles().mesh_library) or (checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords)))  and not "Spikes" in tile_name
  
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
  var y = global_transform.origin.y
  var tb = get_node("CollisionShape").shape.height/2
  var bb = -tb
  var is_above_top_of_tile = y + bb > tile_pos_coords.y
  
  var tile_name = getLevelTiles().mesh_library.get_item_name(tile_type)
  return is_above_top_of_tile and ("Semisolid" in tile_name)

func tryDieToOffscreenCamera(_delta):
  # TODO(jaketrower): should be if not in camera range at all...
  # or if far away enough from player
  var DEATH_MARGIN = 5
  if getGameCamera().rightmost_x > -999:
    if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
    global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
    global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
    global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
      queue_free()

func setAsParent(parent):
  mySprite.changeSpriteColorPaletteToLevelPalette()
  my_parent = parent

# dedupe with FallenBroom and SummonedBroom
var smacked_npc = null
var summonedBroom = null
var has_sweeped_glitch = false
func hitStuff(_delta):
  if not visible or didja_get_me: return
  
  var all_overlapping_areas = purifyArea.get_overlapping_areas()
  var non_bubble_areas = []
  for area in all_overlapping_areas:
    if not area.is_in_group("bubble_purify") and not area.is_in_group("bubble_body"):
      non_bubble_areas.push_back(area)
  # smacked_npc = global.broomSmackStuff(non_bubble_areas, not didja_get_me, global_transform, self, level, smacked_npc)
  # erase glitch tiles...
  trySweepUpGlitchTiles(purifyShape)

func getSmacked(_broom_origin = null, _silently = false, _is_local_broom = false):
  bubbleStartPop()

func glitchTickle():
  pass

func trySweepUpGlitchTiles(collisionShape):
  if not collisionShape.visible or didja_get_me:
    return

  var x = collisionShape.global_transform.origin.x
  var y = collisionShape.global_transform.origin.y
  var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y + 0.25
  var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y - 0.25
  var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x - 0.25
  var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x + 0.25
  
  var _has_played_sound = false
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileSpikes(tile_type):
        getLevelTiles().infectSpikes(coords)
        level.player.has_sweeped_glitch = false
