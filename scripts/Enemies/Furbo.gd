extends "GlitchEnemy.gd"

onready var sparkleSprite = get_node("SparkleSprite3D")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

var spawn_timer = 0
var spawn_time_limit = 5

func _ready():
  smack_time_limit = 5

func setAsParent(_owner):
  walk_direction.x = -1

func glitchSwitchSprite(_delta):
  pass

var rejump_timer = 0
var rejump_time_limit = 10
func _process(delta):
  # behavior_walking = not on_ground
  if pauseSelf and not is_smacked and not secretAniPlayer.is_playing():
    pauseSelf = false
    on_ground = true

  spawn_timer += (delta*22)
  if spawn_timer >= spawn_time_limit:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      level.add_child(newSprite)
      newSprite.global_transform.origin = Vector3(
          global_transform.origin.x + stepify(rand_range(-1.0, 1.0), 0.125),
          global_transform.origin.y + stepify(rand_range(0.5, 1.5), 0.125),
          0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      spawn_timer = 0
    
  if not behavior_jumping and on_ground:
    rejump_timer += (delta*22)
    if rejump_timer >= rejump_time_limit:
      behavior_jumping = true
  elif not on_ground:
    rejump_timer = 0

# @override
func landed():
  .landed()
  # behavior_jumping = false
  rejump_timer = 0

# @override
func shouldIDoCollisions():
    should_collide_floor = true
    should_collide_ceil = true
    should_collide_horizontally = true

# @override
func getSmacked(broom_origin = null, silently = false):
  smacked_palette = global.weird_base_palette
  if is_smacked:
    return false
  .getSmacked(broom_origin, silently)
  pauseSelf = true
  on_ground = true
  notDieSound.play()
  secretAniPlayer.stop()
  secretAniPlayer.play("evilGrin")