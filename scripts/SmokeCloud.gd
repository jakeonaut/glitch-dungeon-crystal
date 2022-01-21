extends "res://scripts/Sprite.gd"

var target_y = 0
func _ready():
    var randint = randi() % 4
    if randint == 1:
        flip_v = true
    if randint == 2:
        flip_h = true
    if randint == 3:
        flip_h = true
        flip_v = true

func _process(delta):
    global_transform.origin.y = global_transform.origin.y + (target_y - global_transform.origin.y) * (delta*2)
