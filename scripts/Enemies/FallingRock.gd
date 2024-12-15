extends "GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var particleSprite1 = get_node("ParticleSprite1")
onready var particleSprite2 = get_node("ParticleSprite2")
onready var particleSprite3 = get_node("ParticleSprite3")
onready var particleSprite4 = get_node("ParticleSprite4")
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
  
  delta = delta * global.time_dilation_multiplier

func isActive(_debug = false):
    return visible and mySprite.visible

func landed():
  if not is_big:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("crackAndShatter")
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
    vv = -true_terminal_vel

  var tiles_underfoot = getTilesBelow(getLevelTiles())
  for tile_coords in tiles_underfoot:
    if tile_coords != null:
      var tile_type = getLevelTiles().get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
      getLevelTiles().set_cell_item(tile_coords.x, tile_coords.y, tile_coords.z, GridMap.INVALID_CELL_ITEM)


# @override
func getSmacked(broom_origin = null, silently = false):
  if not silently:
    unenemize()
    behavior_walking = true
    if (broom_origin != null and broom_origin.x <= self.global_transform.origin.x) or (broom_origin == null and not level.player.mySprite.flip_h):
      walk_direction.x = 1
    elif (broom_origin != null and broom_origin.x > self.global_transform.origin.x) or (broom_origin == null and level.player.mySprite.flip_h):
      walk_direction.x = -1
    var jump_val = 5
    vv = jump_val
    linear_velocity.y = jump_val
    lv.y = jump_val
  return .getSmacked(broom_origin, silently)


func byeBye():
  queue_free()

func collideWithWall(local_lv):
  landed()
  return .collideWithWall(local_lv)