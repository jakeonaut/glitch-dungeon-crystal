extends "res://scripts/GameMover.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    should_collide_ceil = false
    should_collide_horizontally = false
    should_only_do_middle_sensor = true
    grav = rand_range(5, 15)
    true_terminal_vel = 45
        
# @override
func landed():
    .landed()
    queue_free()
    
func alignMySprite():
    var pixelSize = 0.125
    if mySprite:
        mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
        
func addJumpSmokeCloud(_flip_flip_h = false):
    pass
