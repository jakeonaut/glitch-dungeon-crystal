extends "GlitchEnemy.gd"

var can_flip_flop = false
var can_flip_flop_timer = 0
var can_flip_flop_time_limit = 10

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    grav = 0
    
    if behavior_jumping:
        grav = 60
        jump_force = 6

func _process(delta):
    # ._process(delta) implicit

    if not can_flip_flop:
        can_flip_flop_timer += (delta*22)
        if can_flip_flop_timer >= can_flip_flop_time_limit:
            can_flip_flop_timer = 0
            can_flip_flop = true

    if (was_on_ground or on_ground) and can_flip_flop:
        can_flip_flop = false
        if jump_force == 6:
            jump_force = 18
        else:
            jump_force = 6
