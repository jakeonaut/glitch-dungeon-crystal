extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  set_process(true)
  mySprite.material_override = mySprite.material_override.duplicate()

var grow_timer = 0
var grow_time_limit = 3
var opacity = 0.0
var pixel_size = 0.0625
var growing = true # if false, shrinking
var OPACITY_CHANGE = 0.02
var PIX_CHANGE = 0.01
var y_speed = 1
func _process(delta):
  if growing:
    opacity += (delta*11) * OPACITY_CHANGE * 2
    pixel_size += (delta*11) * PIX_CHANGE

    grow_timer += (delta*11)
    if grow_timer >= grow_time_limit:
      growing = false
      grow_timer = 0
  else:
    opacity -= (delta*11) * OPACITY_CHANGE
    pixel_size -= (delta*11) * PIX_CHANGE

  mySprite.pixel_size = pixel_size
  mySprite.material_override.set_shader_param("opacity", opacity)
  mySprite.global_transform.origin.y += delta*y_speed

  if opacity <= 0.0:
    queue_free()
