extends "Enemies/GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

enum ChickenState {
    IDLE,
    PREPARE_JUMP,
    LAND,
    JUMP,
    AFRAID,
    ANGRY,
}
var chicken_state = ChickenState.IDLE
var chicken_state_timer = 0
var chicken_state_idle_time_limit = 10
var chicken_state_dig_time_limit = 6
var chicken_state_reset_dig_time_limit = 8
var afraid_timer = 0
var afraid_time_limit = 10
var far_from_home_dist = 5
var how_many_times_did_u_hit_me = 0

export var can_hop = true
var initial_grav = 60
var initial_true_terminal_vel = 32

var opacity = 1.0

func _ready():
    set_process(true)
    initial_grav = grav
    initial_true_terminal_vel = true_terminal_vel

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier

    should_collide_horizontally = true
    
    if chicken_state == ChickenState.AFRAID:
        behavior_jumping = true
        behavior_walking = true
        mySprite.frame_delay = 0.2
        afraid_timer += (delta*11)
        if afraid_timer >= afraid_time_limit:
            afraid_timer = 0
            chicken_state = ChickenState.IDLE if on_ground else ChickenState.JUMP
            mySprite.updateBaseFrame(4, 3)
            walk_speed = 2
            jump_force = 4
    elif chicken_state == ChickenState.IDLE:
        mySprite.frame_delay = 1
        if can_hop:
            chicken_state_timer += (delta*22)
            if chicken_state_timer >= chicken_state_idle_time_limit:
                chicken_state_timer = 0
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
                    chicken_state = ChickenState.JUMP
    elif chicken_state == ChickenState.PREPARE_JUMP:
        # run away from player
        walk_direction.x = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        behavior_jumping = true
        chicken_state = ChickenState.JUMP
    elif chicken_state == ChickenState.JUMP:
        mySprite.frame_delay = 0.4
        behavior_walking = not on_ground
    elif chicken_state == ChickenState.LAND:
        mySprite.frame_delay = 1
        chicken_state = ChickenState.IDLE

    if am_i_dying:
        return

func isFarFromHome():
    return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist
    

# @override
func landed():
    .landed()
    if chicken_state == ChickenState.AFRAID:
        return
    behavior_jumping = false
    behavior_walking = false
        
    if chicken_state != ChickenState.IDLE:
        chicken_state = ChickenState.LAND


# @override
func getSmacked(broom_origin = null, silently = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently)
  how_many_times_did_u_hit_me += 1
  if dieSound:
    dieSound.pitch_scale = rand_range(0.8, 1.2)
    dieSound.play()
  if notDieSound:
    notDieSound.pitch_scale = rand_range(0.8, 1.2)
    notDieSound.play()
  mySprite.updateBaseFrame(6, 3)
  if how_many_times_did_u_hit_me >= 3:
    how_many_times_did_u_hit_me = 0
    if level.player.transformation != level.player.TransformationState.CHICKEN:
        level.player.gravitySound.play()
        level.player.errorSound.play()
        level.player.getChickenInfected()
        level.player.chicken_timer = 0

  behavior_jumping = true
  behavior_walking = true
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
    
  # pauseSelf = true
  on_ground = true
  walk_speed = 8
  jump_force = 8
  afraid_timer = 0
  if afraid_time_limit < 60:
    afraid_time_limit *= 2
  chicken_state = ChickenState.AFRAID

  if how_many_times_did_u_hit_me >= 3:
    how_many_times_did_u_hit_me = 0
    yield(get_tree().create_timer(0.2), "timeout")
    if level.player.transformation != level.player.TransformationState.CHICKEN:
        level.player.gravitySound.play()
        level.player.getChickenInfected()
        level.player.chicken_timer = 0