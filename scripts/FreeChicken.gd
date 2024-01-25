extends "Enemies/GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

enum MoleState {
    IDLE,
    PREPARE_JUMP,
    LAND,
    JUMP,
}
var mole_state = MoleState.IDLE
var mole_state_timer = 0
var mole_state_idle_time_limit = 10
var mole_state_dig_time_limit = 6
var mole_state_reset_dig_time_limit = 8
var far_from_home_dist = 5

export var can_hop = true
var initial_grav = 60
var initial_true_terminal_vel = 32

var opacity = 1.0

func _ready():
    set_process(true)
    initial_grav = grav
    initial_true_terminal_vel = true_terminal_vel

export var is_digging_left = false
func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier

    should_collide_horizontally = true
    
    if mole_state == MoleState.IDLE:
        if can_hop:
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_idle_time_limit:
                mole_state_timer = 0
                var i = randi() % 4
                if i == 0:
                    pass # stay idle
                elif can_hop and (i == 1 or i == 2):
                    walk_direction.x = 1 if i == 1 else -1
                    if isFarFromHome():
                        if global_transform.origin.x > spawn_origin.x:
                            walk_direction.x = -1
                        else:
                            walk_direction.x = 1
                    behavior_jumping = true
                    mole_state = MoleState.JUMP
    elif mole_state == MoleState.PREPARE_JUMP:
        # run away from player
        walk_direction.x = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        behavior_jumping = true
        mole_state = MoleState.JUMP
    elif mole_state == MoleState.JUMP:
        walk_speed = 5
        behavior_walking = not on_ground
    elif mole_state == MoleState.LAND:
        mole_state = MoleState.IDLE

    if am_i_dying:
        return

func isFarFromHome():
    return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist

# @override
func glitchSetSpritesAndCollision():
    pass
    

# @override
func landed():
    .landed()
    behavior_jumping = false
    behavior_walking = false
        
    if mole_state != MoleState.IDLE:
        mole_state = MoleState.LAND
