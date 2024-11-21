extends "GlitchEnemy.gd"

onready var thudSound = get_node("Sounds/ThudSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var SHELL_GRAV = 60
var should_big_bump = false
onready var myManager = get_node("..")

func _ready():
    if getMyStaticLevelZoneVar():
        visible = false
        queue_free()
        return

    set_process(true)
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2

func _process(delta):
  # ._process(delta) implicit

  if not visible:
    return

  delta = delta * global.time_dilation_multiplier
  secretAniPlayer.playback_speed = global.time_dilation_multiplier

  if physics_state == PhysicsState.NORMAL and "slowSpin" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing():
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("popOutHead")

func tumbleFall(direction_vector, is_corrupted = false):
  if physics_state == PhysicsState.GLITCH_DYING:
    return

  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  var x_val = 0
  var jump_val = 5 if not is_corrupted else 0
  if direction_vector.x < 0:
    secretAniPlayer.play("spinForwardReverse")
    x_val = -10
  elif direction_vector.x > 0:
    secretAniPlayer.play("spinForward")
    x_val = 10
  elif direction_vector.y > 0:
    secretAniPlayer.play("spinForward")
    jump_val = 10
    grav = 0
  elif direction_vector.y < 0:
    secretAniPlayer.play("spinForwardReverse")
    jump_val = -10

  if is_corrupted:
    grav = 0
    on_ground = false
    should_big_bump = true
  else:
    on_ground = true
    grav = SHELL_GRAV
  physics_state = PhysicsState.BEING_TOSSED
  global.pauseGame = false
  global.pauseMoveInput = false
  pauseAnimation = true
  should_collide_floor = true
  can_collide_with_floor = true
  behavior_was_thrown = true
  behavior_walking = true
  walk_direction = direction_vector
  on_ground = false
  walk_speed = abs(x_val)
  hv = Vector3(x_val, 0, 0)
  dir = Vector3(x_val, 0.0, 0.0)
  linear_velocity.x = x_val
  lv.x = x_val

  vv = jump_val
  linear_velocity.y = jump_val
  lv.y = jump_val

  yield(TempTimer.idle_frame(self), "timeout")
  fall_timer = -999

func landed():
  .landed()

  if physics_state == PhysicsState.BEING_TOSSED and walk_direction.x != 0:
    if should_big_bump:
      getSmacked()
      thudSound.play()
    should_big_bump = false
    physics_state = PhysicsState.NORMAL
    walk_speed = 7
    if secretAniPlayer.assigned_animation == "spinForward":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForward")
    elif secretAniPlayer.assigned_animation == "spinForwardReverse":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("slowSpinForwardReverse")

func slowDownMore():
  walk_speed = 4

func okayStop():
  behavior_was_thrown = false
  behavior_walking = false

func becomeACrab():
  if myManager.glitchHermitCrab.get_ref() != null:
    myManager.glitchHermitCrab.get_ref().visible = true
    myManager.glitchHermitCrab.get_ref().global_transform.origin = self.global_transform.origin
    myManager.glitchHermitCrab.get_ref().secretAniPlayer.stop()
    myManager.glitchHermitCrab.get_ref().secretAniPlayer.clear_queue()
    myManager.glitchHermitCrab.get_ref().secretAniPlayer.play("prepare")
    myManager.glitchHermitCrab.get_ref().crab_state = myManager.glitchHermitCrab.get_ref().CrabState.IDLE
    visible = false

# @override
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  return .getSmacked(broom_origin, silently)

# @override
func actuallyDieToOffscreenCamera():
  if is_static_in_level:
    setGlobalMemoryOfHasBeenDefeated()
    trySpawnACrystal()
  myManager.queue_free()

# @override
func unsmack():
  if grav == 0:
    grav = SHELL_GRAV
  .unsmack()
