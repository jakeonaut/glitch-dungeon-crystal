extends Spatial

onready var cubeContainer = get_node("CubeContainer")
onready var meshInstance2 = get_node("CubeContainer/MeshInstance2")
var nonGlitchedMaterial = null
var glitchedMaterial = preload("res://materials/PriestessCrystalGlitch.tres")

func _ready():
  set_process(true)
  set_physics_process(false)

  nonGlitchedMaterial = meshInstance2.get_material_override().duplicate()
  meshInstance2.set_material_override(nonGlitchedMaterial)

var glitch_shader_timer = 0
var glitch_shader_time_limit = 1
var is_glitched = false
func _process(delta):
  # super._process(delta) implicit

  cubeContainer.rotation_degrees.y += delta*88
  if is_glitched and meshInstance2.material_override is ShaderMaterial:
    glitch_shader_timer += (delta*11)
    if glitch_shader_timer >= glitch_shader_time_limit:
      meshInstance2.material_override.set_shader_param("corruption_seed", rand_range(0.1, 10.0))
      glitch_shader_timer = 0

func applyGlitchMaterial(influence):
  if is_glitched:
    return
  is_glitched = true
  var new_glitched_material = glitchedMaterial.duplicate()
  new_glitched_material.set_shader_param("corruption_amount", 0.1 + influence*0.1)
  new_glitched_material.set_shader_param("uv_scrolling_velocity", Vector2(influence*0.1, influence*0.1))
  new_glitched_material.set_shader_param("normal_offset", influence*0.125 + 0.25)
  new_glitched_material.set_shader_param("time_influence", influence + 2)
  new_glitched_material.set_shader_param("y_div", influence * 0.5 + 3)
  meshInstance2.set_material_override(new_glitched_material)

func unapplyGlitchMaterial():
  meshInstance2.set_material_override(nonGlitchedMaterial)