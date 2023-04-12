extends Spatial


onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var camera = get_node("../GameCamera")
var camera_origin
export var dont_recolor_me = false


func _ready():
    camera_origin = camera.global_transform.origin


func _process(_delta):
    self.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 2
    if dont_recolor_me and mySprite.is_in_group("sprite"):
        mySprite.remove_from_group("sprite")
        mySprite2.remove_from_group("sprite")