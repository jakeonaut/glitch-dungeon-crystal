extends "../../GameMover.gd"

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var crowRes = preload("res://sceneObjects/Enemies/CrowWitch.tscn")

func _ready():
  set_process(true)
  set_physics_process(false)

  mySprite.material_override = mySprite.material_override.duplicate()
  mySprite.should_randomize_frame_delay = false
  should_collide_ceil = false

func _process(delta):
  # super._process(delta) implicit

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      unsmack()

func unsmack():
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 3)
    # material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .02)
    mySprite.material_override = material

func getSmacked(_broom_origin = null, _silently = false):
  # if not can_be_smacked:
  #   return false
  if is_smacked:
    return false
    
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 35)
    material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .15)
    mySprite.material_override = material
  smack_timer = 0
  is_smacked = true

func isActive(_debug = false):
  return not is_smacked and visible

var has_landed = false
func landed():
  .landed()
  if not has_landed:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("hatch")

# @override
func alignMySprite():
  pass

func hatchEmAll():
  var babaYagaBoss = level.get_node("BabaYagaBoss/CrowContainer") if level.has_node("BabaYagaBoss/CrowContainer") else level
  for _i in range(5):
    var newCrow = crowRes.instance()
    babaYagaBoss.add_child(newCrow)
    newCrow.global_transform.origin = Vector3(
      self.global_transform.origin.x + rand_range(-0.2, 0.2),
      self.global_transform.origin.y + rand_range(0, 0.4),
      0
    )
    newCrow.should_scatter = true
    newCrow.original_pos = Vector3(7, 6, 0)