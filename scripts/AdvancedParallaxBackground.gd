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
var layers = []

func _ready():
    camera_origin = camera.global_transform.origin

func _process(delta):
    camera.respectLevelTilesEdges()
    layers = [background, layer0, layer1, layer2, layer3, layer4, layer5, layer6, layer7]
    handleParallax(delta)
    if dont_recolor_me and background.get_node("Sprite").is_in_group("sprite"):
        for layer in layers:
            layer.get_node("Sprite").remove_from_group("sprite")
            layer.get_node("Sprite2").remove_from_group("sprite")
    if hiding:
        opacity = opacity + (0.0 - opacity) * (delta * 1)
        # mySprite.material_override.set_shader_param("opacity", opacity)
    else:
        opacity = opacity + (1.0 - opacity) * (delta * 1)
        # mySprite.material_override.set_shader_param("opacity", opacity)

func hideMe():
    hiding = true

func handleParallax(_delta):
  background.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x)
  layer0.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 2
  layer1.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 3
  layer2.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 4
  layer3.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 5
  layer4.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 6
  layer5.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 7
  layer6.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 8
  layer7.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 9
