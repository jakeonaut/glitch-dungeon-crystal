extends Sprite3D

func _ready():
    set_process(true)

func _process(delta):
    self.rotate_y(delta*2)
