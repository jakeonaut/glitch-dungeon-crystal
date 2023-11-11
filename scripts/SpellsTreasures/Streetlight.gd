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

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()
    if smack_timer >= smack_recovery_time_limit:
        is_smacked = false

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

func activate(_is_player):
  level.player.getSmacked()
  is_active = false
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
  getSmacked()


var last_palette = global.grey_palette
func unsmack():
  is_active = true
  # mySprite.material_override.set_shader_param("enable_glitch", false)
  mySprite.material_override.set_shader_param("time_influence", 3)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", false)
  mySprite.material_override.set_shader_param("enable_no_transparency", false)
  mySprite.material_override.set_shader_param("enable_dither", false)
  mySprite.material_override.set_shader_param("y_div", 2.3)
  mySprite.material_override.set_shader_param("normal_offset", .02)
  mySprite.material_override.set_shader_param("shake_power", 0.03)
  mySprite.material_override.set_shader_param("shake_block_size", 30.5)
  mySprite.material_override.set_shader_param("shake_color_rate", 0.01)
  mySprite.material_override.set_shader_param("target_palette", last_palette)

var is_smacked = false
var has_ever_been_smacked = false
var smack_timer = 0
export var smack_time_limit = 5
export var smack_recovery_time_limit = 15
export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
func getSmacked():
  if is_smacked:
    return false

  # mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("time_influence", time_influence)
  mySprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  mySprite.material_override.set_shader_param("enable_no_transparency", false)
  mySprite.material_override.set_shader_param("enable_dither", true)
  mySprite.material_override.set_shader_param("y_div", y_div)
  mySprite.material_override.set_shader_param("normal_offset", normal_offset)
  mySprite.material_override.set_shader_param("shake_power", 0.143)
  mySprite.material_override.set_shader_param("shake_block_size", 60)
  mySprite.material_override.set_shader_param("shake_color_rate", 0.219)
  last_palette = mySprite.material_override.get_shader_param("target_palette")
  mySprite.material_override.set_shader_param("target_palette", global.white_palette)
  
  smack_timer = 0
  is_smacked = true
  has_ever_been_smacked = true
  return true
