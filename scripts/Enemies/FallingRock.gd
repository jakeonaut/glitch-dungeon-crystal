extends "GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var particleSprite1 = get_node("ParticleSprite1")
onready var particleSprite2 = get_node("ParticleSprite2")
onready var particleSprite3 = get_node("ParticleSprite3")
onready var particleSprite4 = get_node("ParticleSprite4")
onready var cautionWarning = weakref(get_node("CautionWarning"))
var caution_timer = 0
var caution_time_limit = 5
var is_big = false

func _ready():
  can_spawn_mini_crystal = false
  only_activate_in_range = false
  on_ground = false
  walk_speed = 14
  should_smack_pause_me = false
  
  particleSprite1.material_override = particleSprite1.material_override.duplicate()
  particleSprite2.material_override = particleSprite1.material_override
  particleSprite3.material_override = particleSprite3.material_override.duplicate()
  particleSprite4.material_override = particleSprite3.material_override
  behavior_walk_flip = false

func _process(delta):
  # ._process(delta) implicit
  if not visible: return
  
  delta_time_dilation = global.SLOW_BOSS_MULTIPLIER if global.memory["secret_bauble"] and global.memory["secret_bauble_enabled"] else 1.0
  delta = delta * global.time_dilation_multiplier * delta_time_dilation
  secretAniPlayer.playback_speed = delta_time_dilation

  if cautionWarning != null and cautionWarning.get_ref() != null and not mySprite.visible:
    grav = 0
    caution_timer += (delta * 11)
    placeCautionWarning()
    if caution_timer >= caution_time_limit:
      mySprite.visible = true
      var prevOrigin = cautionWarning.get_ref().global_transform.origin
      self.remove_child(cautionWarning.get_ref())
      level.add_child(cautionWarning.get_ref())
      cautionWarning.get_ref().global_transform.origin = prevOrigin
      cautionWarning.get_ref().aniPlayer.stop()
      cautionWarning.get_ref().aniPlayer.clear_queue()
      cautionWarning.get_ref().aniPlayer.play("byebye")
      cautionWarning = null
  elif cautionWarning == null and mySprite.visible:
    grav = 30

func placeCautionWarning():
  if cautionWarning == null or cautionWarning.get_ref() == null:
    return
  var unprojectedPosition = getGameCamera().unproject_position(self.global_transform.origin + Vector3(0, 1, 0))
  unprojectedPosition.y = max(32, unprojectedPosition.y)
  cautionWarning.get_ref().global_transform.origin = getGameCamera().project_position(unprojectedPosition, 0)
  cautionWarning.get_ref().global_transform.origin.z = 10

func isActive(_debug = false):
    return visible and mySprite.visible

func landed(_was_on_fallthrough_solid = false):
  if not is_big:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("crackAndShatter")
    notDieSound.play()
    behavior_walking = false
    on_ground = true
    grav = 0
    linear_velocity.y = 0
    lv.y = 0
    vv = 0
  else:
    on_ground = false
    linear_velocity.y = -true_terminal_vel
    lv.y = -true_terminal_vel
    vv = up.dot(lv)

  var tiles_underfoot = getTilesBelow(getLevelTiles())
  for tile_coords in tiles_underfoot:
    if tile_coords != null:
      var tile_type = getLevelTiles().get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
      getLevelTiles().set_cell_item(tile_coords.x, tile_coords.y, tile_coords.z, GridMap.INVALID_CELL_ITEM)


# @override
func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
  if is_big:
    return
  if not silently:
    unenemize()
    behavior_walking = true
    if (broom_origin != null and broom_origin.x <= self.global_transform.origin.x) or (broom_origin == null and not level.player.mySprite.flip_h):
      walk_direction.x = 1
    elif (broom_origin != null and broom_origin.x > self.global_transform.origin.x) or (broom_origin == null and level.player.mySprite.flip_h):
      walk_direction.x = -1
    var jump_val = 5
    linear_velocity.y = jump_val
    lv.y = jump_val
    vv = up.dot(lv)
  return .getSmacked(broom_origin, silently, is_local_broom)


func byeBye():
  queue_free()

func collideWithWall(local_lv):
  if walk_direction.x > 0:
    var tiles = getTilesRightOf(getLevelTiles())
    for tile_coords in tiles:
      if tile_coords != null:
        getLevelTiles().set_cell_item(tile_coords.x, tile_coords.y, tile_coords.z, GridMap.INVALID_CELL_ITEM)
  elif walk_direction.x < 0:
    var tiles = getTilesLeftOf(getLevelTiles())
    for tile_coords in tiles:
      if tile_coords != null:
        getLevelTiles().set_cell_item(tile_coords.x, tile_coords.y, tile_coords.z, GridMap.INVALID_CELL_ITEM)

  landed()
  return .collideWithWall(local_lv)
