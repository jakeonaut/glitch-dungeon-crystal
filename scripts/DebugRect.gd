extends ColorRect

var lb = 50
var tb = 50
var rb = -50
var bb = -50 
func _ready():
  set_process(true)

func _process(_delta):
  self.rect_position = Vector2(-lb, -tb)
  self.rect_size = Vector2(lb - rb, tb - bb)

