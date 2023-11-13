extends Spatial

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")
onready var sparkleSprite = get_node("SparkleSprite3D") if has_node("SparkleSprite3D") else null
var spawn_timer = 0
var spawn_time_limit = 10
var is_active = true

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

func _ready():
  set_process(true)
  mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if sparkleSprite != null:
    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      newSprite.transform.origin = Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125),
          0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      add_child(newSprite)
      spawn_timer = 0

func isActive():
  return is_active

export var grav_direction = 1
func passiveActivate(_delta, _is_player):
  if grav_direction > 0 and level.player.grav > 0:
    return
  elif grav_direction < 0 and level.player.grav < 0:
    return

  collectSound.play()
  level.player.grav *= -1
  # level.player.mySprite.flip_v = not level.player.mySprite.flip_v
  # level.player.broomSpriteVisible.flip_v = not level.player.broomSpriteVisible.flip_v
  level.player.spriteContainer.rotation_degrees.x += 180
  level.player.spriteContainer.rotation_degrees.x = fmod(level.player.spriteContainer.rotation_degrees.x, 360)
  if level.player.grav < 0:
    level.player.spriteYAlignment -= 0.5
    level.player.spriteContainer.get_node("InnerSpriteContainer").translation.z -= 1
  else:
    level.player.spriteYAlignment += 0.5
    level.player.spriteContainer.get_node("InnerSpriteContainer").translation.z += 1
