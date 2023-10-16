extends Spatial


onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var camera = get_node("../GameCamera")
var camera_origin
export var dont_recolor_me = false
var hiding = false
var opacity = 1.0


func _ready():
    camera_origin = camera.global_transform.origin


func _process(delta):
    self.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 2
    if dont_recolor_me and mySprite.is_in_group("sprite"):
        mySprite.remove_from_group("sprite")
        mySprite2.remove_from_group("sprite")

    if hiding:
        opacity = opacity + (0.0 - opacity) * (delta * 1)
        mySprite.material_override.set_shader_param("opacity", opacity)
        mySprite2.material_override.set_shader_param("opacity", opacity)
    else:
        opacity = opacity + (1.0 - opacity) * (delta * 1)
        mySprite.material_override.set_shader_param("opacity", opacity)
        mySprite2.material_override.set_shader_param("opacity", opacity)
func hideMe():
    hiding = true