extends Control

onready var torch = get_node("../../Torch")
onready var gameCamera = get_node("../../GameCamera")
onready var mainColorRect = get_node("ColorRect")

func _ready():
    set_process(true)
    setPosition()

func _process(delta):
    setPosition()

func setPosition():
    var torch_x = torch.global_transform.origin.x
    var torch_y = torch.global_transform.origin.y
   
    var gameCamera_x = gameCamera.global_transform.origin.x
    var gameCamera_y = gameCamera.global_transform.origin.y

    var center_x = 960/2
    var center_y = 720/2
    var m = 48
    # m = multiplicative, needs to be relative to gameCamera.size!!!
    self.rect_position.x = ((torch_x - gameCamera_x)*48) + (center_x - (mainColorRect.rect_size.x/2))
    self.rect_position.y = ((torch_y - gameCamera_y)*-48) + (center_y - (mainColorRect.rect_size.y/2))
    # print("torch_x: " + str(torch_x) + ", gameCamera_x: " + str(gameCamera_x) + "rect_position.x: " + str(self.rect_position.x))
