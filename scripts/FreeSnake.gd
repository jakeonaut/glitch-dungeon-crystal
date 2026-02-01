extends "Enemies/GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")
enum ChickenState {
    IDLE,
    AFRAID,
}
var chicken_state = ChickenState.IDLE
var afraid_timer = 0
var afraid_time_limit = 10
var far_from_home_dist = 5
export var how_many_times_did_u_hit_me = 0

export var can_hop = true
var initial_grav = Vector2(0, 60)
var initial_true_terminal_vel = 32

var opacity = 1.0

func _ready():
    set_process(true)
    initial_grav = grav
    initial_true_terminal_vel = true_terminal_vel
    should_smack_pause_me = true
    behavior_walking = true
    behavior_walk_flip = true

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier
    should_collide_with_walls = true
    if chicken_state == ChickenState.AFRAID:
        mySprite.frame_delay = 0.2
        afraid_timer += (delta*11)
        if afraid_timer >= afraid_time_limit:
            afraid_timer = 0
            chicken_state = ChickenState.IDLE
            mySprite.updateBaseFrame(2, 0)
            walk_speed = 2
    elif chicken_state == ChickenState.IDLE:
        mySprite.frame_delay = 1
    if am_i_dying:
        return

func isFarFromHome():
    return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist


# var babyBabushkaFollowerRes = preload("res://sceneObjects/SnakeFollower.tscn")
func passiveActivate(_delta, is_player, is_local_broom = false):
  if is_player:
    level.player.glitchTickle()
#   if is_player and not is_local_broom:
#     var newFollower = level.spawnAnyFollower(self.global_transform.origin, babyBabushkaFollowerRes)
#     newFollower.dieSound.play()
#     queue_free()

# @override
func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently, is_local_broom)
  how_many_times_did_u_hit_me += 1
  if dieSound:
    dieSound.pitch_scale = rand_range(0.8, 1.2)
    dieSound.play()
  if notDieSound:
    notDieSound.pitch_scale = rand_range(0.8, 1.2)
    notDieSound.play()
  mySprite.updateBaseFrame(5, 0)

#   behavior_jumping = true
  behavior_walking = true
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
    
  # pauseSelf = true
  on_ground = true
  walk_speed = 8
#   jump_force = 8
  afraid_timer = 0
  if afraid_time_limit < 60:
    afraid_time_limit *= 2
  chicken_state = ChickenState.AFRAID
