extends Spatial

onready var cubeContainer = get_node("CubeContainer")
onready var meshInstance2 = get_node("CubeContainer/MeshInstance2")
var glitchedMaterial = preload("res://materials/PriestessCrystalGlitch.tres")

func _ready():
  set_process(true)
  set_physics_process(false)

  meshInstance2.set_material_override(meshInstance2.get_material_override().duplicate())

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

func applyGlitchMaterial():
  if is_glitched:
    return
  is_glitched = true
  meshInstance2.set_material_override(glitchedMaterial.duplicate())
