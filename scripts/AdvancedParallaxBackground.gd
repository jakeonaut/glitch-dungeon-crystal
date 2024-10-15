extends Spatial

onready var background = get_node("Background")
onready var layer0 = get_node("Layer0")
onready var layer1 = get_node("Layer1")
onready var layer2 = get_node("Layer2")
onready var layer3 = get_node("Layer3")
onready var layer4 = get_node("Layer4")
onready var layer5 = get_node("Layer5")
onready var layer6 = get_node("Layer6")
onready var layer7 = get_node("Layer7")

onready var camera = get_node("../GameCamera")
var camera_origin
export var dont_recolor_me = false
var hiding = false
var opacity = 1.0
var did_i_do_that = false
var MAX_OPACITY = 0.1

func _ready():
  camera_origin = camera.global_transform.origin

func _process(delta):
  camera.respectLevelTilesEdges()
  handleParallax(delta)
  if dont_recolor_me and background.get_node("Sprite").is_in_group("sprite") and not did_i_do_that:
    var layers = [background, layer0, layer1, layer2, layer3, layer4, layer5, layer6, layer7]
    for layer in layers:
      layer.get_node("Sprite").remove_from_group("sprite")
      layer.get_node("Sprite2").remove_from_group("sprite")
    did_i_do_that = true
          
  if hiding and opacity > 0:
    opacity = opacity + (0.0 - opacity) * (delta * 1)
    # mySprite.material_override.set_shader_param("opacity", opacity)
  elif not hiding and opacity < 1.0:
    opacity = opacity + (MAX_OPACITY - opacity) * (delta * 1)
    # mySprite.material_override.set_shader_param("opacity", opacity)

func hideMe():
  hiding = true

var glitchy_parallax = false
func handleParallax(_delta):
  var value = camera.global_transform.origin.x - camera_origin.x
  if glitchy_parallax:
    background.global_transform.origin.x = fmod(value, 0.5)
    layer0.global_transform.origin.x = fmod(value / 2, 0.5)
    layer1.global_transform.origin.x = fmod(value / 3, 0.5)
    layer2.global_transform.origin.x = fmod(value / 4, 0.5)
    layer3.global_transform.origin.x = fmod(value / 5, 0.5)
    layer4.global_transform.origin.x = fmod(value / 6, 0.5)
    layer5.global_transform.origin.x = fmod(value / 7, 0.5)
    layer6.global_transform.origin.x = fmod(value / 8, 0.5)
    layer7.global_transform.origin.x = fmod(value / 9, 0.5)
  else:
    background.global_transform.origin.x = value
    layer0.global_transform.origin.x = value / 2
    layer1.global_transform.origin.x = value / 3
    layer2.global_transform.origin.x = value / 4
    layer3.global_transform.origin.x = value / 5
    layer4.global_transform.origin.x = value / 6
    layer5.global_transform.origin.x = value / 7
    layer6.global_transform.origin.x = value / 8
    layer7.global_transform.origin.x = value / 9
