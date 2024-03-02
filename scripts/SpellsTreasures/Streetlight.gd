extends Spatial

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")
onready var mySpriteBase = get_node("Sprite3DBase")
onready var sparkleSprite = get_node("SparkleSprite3D") if has_node("SparkleSprite3D") else null
onready var streetlightGlitchAura  = get_node("StreetlightGlitchAura")
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
  mySpriteBase.material_override = mySprite.material_override

var has_changed_palette = false
var streetlightUpsideDownMaterial = preload("res://sceneObjects/SpellsTreasureCollectables/StreetlightUpsideDownMaterial.tres")
func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if grav_direction < 0 and not has_changed_palette:
    streetlightGlitchAura.mainTextureRect.material = streetlightUpsideDownMaterial
    has_changed_palette = true

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()
  elif is_sparkle_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= sparkle_smack_time_limit:
      is_sparkle_smacked = false

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
      if is_sparkle_smacked:
        newSprite.should_fly_somewhere = true
        newSprite.fly_pos = level.player.global_transform.origin + newSprite.transform.origin
        newSprite.fly_speed = 5
        newSprite.should_fizzle_out = true
        newSprite.max_frames = 4
        newSprite.pixel_size = 0.18

func unsmack():
  smack_timer = 0
  is_smacked = false
  mySprite.material_override.set_shader_param("time_influence", 3)
  mySprite.material_override.set_shader_param("y_div", 2.3)
  mySprite.material_override.set_shader_param("normal_offset", .02)
  mySprite.material_override.set_shader_param("enable_palette_cycle", false)
  
  # mySpriteBase.material_override.set_shader_param("time_influence", 3)
  # mySpriteBase.material_override.set_shader_param("y_div", 2.3)
  # mySpriteBase.material_override.set_shader_param("normal_offset", .02)
  # mySpriteBase.material_override.set_shader_param("enable_palette_cycle", false)
  
func isActive(debug=false):
  return is_active

var is_smacked = false
var is_sparkle_smacked = false
var smack_timer = 0
var smack_time_limit = 15
var sparkle_smack_time_limit = 16
var time_influence = 35
var y_div = 2.3
var normal_offset = .15
export var grav_direction = 1
func passiveActivate(_delta, _is_player):
  if grav_direction > 0 and level.player.grav > 0:
    return
  elif grav_direction < 0 and level.player.grav < 0:
    return

  global.memory["grav_direction"] = grav_direction
  collectSound.play()
  level.flipGravity()

  level.player.mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  level.player.getSmacked()
  level.player.pauseSelf = false

  mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  mySprite.material_override.set_shader_param("time_influence", time_influence)
  mySprite.material_override.set_shader_param("y_div", y_div)
  mySprite.material_override.set_shader_param("normal_offset", normal_offset)
  # mySpriteBase.material_override.set_shader_param("enable_palette_cycle", true)
  # mySpriteBase.material_override.set_shader_param("time_influence", time_influence)
  # mySpriteBase.material_override.set_shader_param("y_div", y_div)
  # mySpriteBase.material_override.set_shader_param("normal_offset", normal_offset)
  smack_timer = 0
  is_smacked = true
  is_sparkle_smacked = true
