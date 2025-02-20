extends "GlitchEnemy.gd"

enum ChickenState {
    IDLE,
    PREPARE_JUMP,
    LAND,
    JUMP,
}
var chicken_state = ChickenState.IDLE
var chicken_state_timer = 0
var chicken_state_idle_time_limit = 10
var chicken_state_dig_time_limit = 6
var chicken_state_reset_dig_time_limit = 8
var far_from_home_dist = 5
export var is_fan_spinning = false

export var can_hop = false
var initial_grav = 60
var initial_true_terminal_vel = 32
onready var fanAnimationPlayer = get_node("FanAnimationPlayer")
onready var windGust = get_node("WindGust")
onready var chargeSound = get_node("ChargeSound")

var opacity = 1.0

func _ready():
    set_process(true)
    initial_grav = grav
    initial_true_terminal_vel = true_terminal_vel
    should_smack_pause_me = false

func _process(delta):
  # ._process(delta) implicit
  
  delta = delta * global.time_dilation_multiplier

  should_collide_horizontally = true

  if chicken_state == ChickenState.IDLE:
    if is_fan_spinning:
      tryToPlayAnimation("spinny")
    else:
      tryToPlayAnimation("idle")
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
    if vv < 0:
      if is_fan_spinning:
        tryToPlayAnimation("jump")
      else:
        tryToPlayAnimation("jumpSpinny")
    else:
      if is_fan_spinning:
        tryToPlayAnimation("fall")
      else:
        tryToPlayAnimation("fallSpinny")
  elif chicken_state == ChickenState.LAND:
    chicken_state = ChickenState.IDLE

  if am_i_dying:
    return

func tryToPlayAnimation(aniName):
  if fanAnimationPlayer.assigned_animation != aniName:
    fanAnimationPlayer.stop()
    fanAnimationPlayer.play(aniName)

func isFarFromHome():
  return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist
    

# @override
func landed():
  .landed()
  behavior_jumping = false
      
  if chicken_state != ChickenState.IDLE:
    chicken_state = ChickenState.LAND


# @override
func getSmacked(broom_origin = null, silently = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently)
  if dieSound:
    dieSound.pitch_scale = rand_range(0.8, 1.2)
    dieSound.play()
  if notDieSound:
    notDieSound.pitch_scale = rand_range(0.8, 1.2)
    notDieSound.play()
  mySprite.updateBaseFrame(6, 3)

  behavior_jumping = true
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
    
  # pauseSelf = true
  on_ground = true
  walk_speed = 8
  jump_force = 8

  if is_fan_spinning:
    is_fan_spinning = false
    chargeSound.play()
  else:
    is_fan_spinning = true
    global.gustSound.play()
  windGust.is_active = is_fan_spinning

func actuallyDieToOffscreenCamera(_delta):
    queue_free()
