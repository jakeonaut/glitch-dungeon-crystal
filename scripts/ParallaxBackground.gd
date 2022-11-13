extends Spatial


onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var camera = get_node("../GameCamera")
var camera_origin


func _ready():
    camera_origin = camera.global_transform.origin


func _process(_delta):
    self.global_transform.origin.x = (camera.global_transform.origin.x - camera_origin.x) / 2
