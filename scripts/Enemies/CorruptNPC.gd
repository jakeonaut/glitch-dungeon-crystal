extends "GlitchEnemy.gd"

onready var screamSound = get_node("Sounds/ScreamSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
enum ZombieState {
  IDLE,
  SLIME_WALK,
  LURCH_START,
  LURCH_ATTACK,
  LURCH_END,
  DYING,
  REVIVING,
}
var zombie_state = ZombieState.IDLE
var fast_walk_speed = 12
var slow_walk_speed = 4
var death_timer = 0
var death_time_limit = 60
var spawn_point = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    should_collide_ceil = false
    only_activate_in_range = false
    should_reset_slime_timer_on_flip = false
    slime_idle_time_limit = 30
    yield(get_tree().create_timer(0.1), "timeout")
    spawn_point = global_transform.origin

func _process(delta):
  # ._process(delta) implicit
  if not visible: return
  
  delta = delta * global.time_dilation_multiplier

  if zombie_state == ZombieState.IDLE:
    zombie_state = ZombieState.SLIME_WALK
  elif zombie_state == ZombieState.SLIME_WALK:
    walk_speed = slow_walk_speed
    if am_i_really_in_range_of_player:
      zombie_state = ZombieState.LURCH_START
      behavior_intermittent_walking = false
    else:
      behavior_walk_flip = true
      if not behavior_intermittent_walking:
        behavior_intermittent_walking = true
        slime_state_timer = 0
        slime_state = SlimeState.WALK
      if slime_state == SlimeState.WALK:
        if slime_state_timer == 0:
          if secretAniPlayer.assigned_animation == "walk2":
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("walk1")
          else:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("walk2")
      elif slime_state == SlimeState.IDLE:
        pass
  elif zombie_state == ZombieState.LURCH_START:
    behavior_intermittent_walking = false
    behavior_walking = false
    slime_state = SlimeState.NULL
    if secretAniPlayer.assigned_animation != "lurchStart":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchStart")
    elif secretAniPlayer.assigned_animation == "lurchStart" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.LURCH_ATTACK
    if getPlayer().global_transform.origin.x > self.global_transform.origin.x + 0.2:
      walk_direction.x = 1
      mySprite.flip_h = false
    elif getPlayer().global_transform.origin.x < self.global_transform.origin.x - 0.2:
      walk_direction.x = -1
      mySprite.flip_h = true
  elif zombie_state == ZombieState.LURCH_ATTACK:
    behavior_walking = true
    behavior_walk_flip = false
    walk_speed = fast_walk_speed
    if secretAniPlayer.assigned_animation != "lurchAttack":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchAttack")
      behavior_jumping = true
      # see stopJumping, called by lurchAttack
      screamSound.pitch_scale = rand_range(0.4, 0.6)
      screamSound.play()
    elif secretAniPlayer.assigned_animation == "lurchAttack" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.LURCH_END
  elif zombie_state == ZombieState.LURCH_END:
    if secretAniPlayer.assigned_animation != "lurchEnd":
      behavior_walking = false
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchEnd")
    elif secretAniPlayer.assigned_animation == "lurchEnd" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.IDLE
  elif zombie_state == ZombieState.DYING:
    # see ouchies()
    death_timer += (delta*11)
    if death_timer >= death_time_limit:
      zombie_state = ZombieState.REVIVING
      death_timer = 0
      unsmack()
  elif zombie_state == ZombieState.REVIVING:
    if secretAniPlayer.assigned_animation != "revive":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("revive")
      global_transform.origin = spawn_point
    else:
      if not secretAniPlayer.is_playing():
        unsmack()
        zombie_state = ZombieState.IDLE
        am_i_dying = false

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func passiveActivate(_delta, _is_player):
    if am_i_dying or not visible or not mySprite.visible: return
        
    # var aniPlayer = get_node("HeartSprite/AnimationPlayer")
    # if level.player.glitch_form == global.GlitchForm.INVISIBLE and not aniPlayer.is_playing():
    #     heartSound.play()
    #     aniPlayer.stop()
    #     aniPlayer.queue("heartWiggle")
    #     aniPlayer.queue("noHeart")

func processDeath():
    pass

func stopJumping():
  behavior_jumping = false

func unenemize():
    if smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.remove_from_group("enemies")
    if smallInteractionArea.is_in_group("weak_enemies"):
        smallInteractionArea.remove_from_group("weak_enemies")
        
# @override
func ouchies(_broom_origin):
    .ouchies_base()
    if am_i_dying or not visible: return

    if zombie_state == ZombieState.LURCH_ATTACK:
      notDieSound.play()
      return
        
    behavior_walking = false
    behavior_intermittent_walking = false
    behavior_jumping = false
    slime_state = SlimeState.NULL
    am_i_dying = true
    zombie_state = ZombieState.DYING
    dieSound.play()
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("die")
    death_timer = 0
