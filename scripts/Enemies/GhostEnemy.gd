extends "GlitchEnemy.gd"

var just_a_figment = false
var my_opacity = 0.9
var x_speed = 0
var y_speed = 2
var original_pos = null
var true_original_pos = null
var target_pos = null
var is_following_player = false
var do_i_belong_here = true
export var moving_towards_player = false
var scared_timer = 0
var scared_time_limit = 30
onready var booSound = get_node("Sounds/BooSound")
onready var hauntSound = get_node("Sounds/HauntSound")
onready var secretAniPlayer = get_node("SecretAniPlayer")

func _ready():
  scared_timer = scared_time_limit

func _process(delta):
  # ._process(delta) implicit
  if not visible or global.pauseGame: return
  
  delta = delta * global.time_dilation_multiplier
  behavior_phase_through_walls = true

  if just_a_figment:
    mySprite.material_override.set_shader_param("enable_glitch_3d", false)
    global_transform.origin.x += x_speed * delta
    if x_speed > 0:
      mySprite.flip_h = false
      x_speed -= delta * 0.5
      if x_speed < 0:
        x_speed = 0
    elif x_speed < 0:
      mySprite.flip_h = true
      x_speed += delta * 0.5
      if x_speed > 0:
        x_speed = 0
    global_transform.origin.y += y_speed * delta * 2
    my_opacity -= (delta)
    mySprite.material_override.set_shader_param("opacity", my_opacity)
    if my_opacity <= 0.0:
      if moving_towards_player:
        my_opacity = 0.0
        mySprite.material_override.set_shader_param("opacity", my_opacity)
        just_a_figment = false
      else:
        queue_free()
  elif scared_timer < scared_time_limit:
    scared_timer += (delta*11)
    global_transform.origin = level.player.global_transform.origin
    if level.player.mySprite.flip_h:
      global_transform.origin.x += 5
    else:
      global_transform.origin.x -= 5
    global_transform.origin.y += 5
    mySprite.flip_h = (level.player.global_transform.origin.x < global_transform.origin.x)
    if scared_timer >= scared_time_limit:
      hauntSound.play()
  elif my_opacity < 0.9:
    my_opacity += (delta)
    mySprite.material_override.set_shader_param("opacity", my_opacity)
    if my_opacity >= 0.9:
      my_opacity = 0.9
      mySprite.material_override.set_shader_param("opacity", my_opacity)
  elif moving_towards_player:
    if global.activeInteractor != null:
      if mySprite.should_animate: secretAniPlayer.play("shy")
      return
    mySprite.flip_h = (level.player.global_transform.origin.x < global_transform.origin.x)
    if mySprite.flip_h != level.player.mySprite.flip_h:
      if mySprite.should_animate: secretAniPlayer.play("shy")
      return
      
    if not mySprite.should_animate: secretAniPlayer.play("scary")
    var step = 2
    var directionVector = (level.player.global_transform.origin - global_transform.origin).normalized()
    global_transform.origin += directionVector * (delta*step)
  else:
    var step = 10
    if target_pos != null:
      global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
      var diff = target_pos - global_transform.origin
      var buff = 0.1
      if stepify(abs(diff.x), buff) == 0 and stepify(abs(diff.y), buff) == 0:
        randomizeTargetPos()

    if is_following_player and level.player.isOnSavePoint():
      is_following_player = false
      randomizeTargetPos()
  
func randomizeTargetPos():
  var amt = 0.5
  if is_following_player:
    amt *= 2
    target_pos = Vector3(
      level.player.global_transform.origin.x + rand_range(-amt, amt),
      level.player.global_transform.origin.y + rand_range(-amt, amt),
      level.player.global_transform.origin.z + rand_range(-amt, amt)
    )   
  else:
    target_pos = Vector3(
      original_pos.x + rand_range(-amt, amt),
      original_pos.y + rand_range(-amt, amt),
      original_pos.z
    )

  mySprite.flip_h = (target_pos.x < global_transform.origin.x)

func getSmacked(broom_origin = null, silently = false):
  if not is_smacked:
    booSound.play()
    var speed = 8
    if broom_origin != null:
      if broom_origin.x > self.global_transform.origin.x:
        x_speed = -speed
      else:
        x_speed = speed
    else:
      if level.player.mySprite.flip_h: x_speed = -speed
      else: x_speed = speed
    scared_timer = 0
    just_a_figment = true
    mySprite.material_override.set_shader_param("enable_glitch_3d", false)
    .getSmacked(broom_origin, silently)

# func passiveActivate(_delta, is_player):
#   if just_a_figment or is_following_player:
#     return
#   if is_player and not level.player.malware_infected and not is_following_player and not level.player.isOnSavePoint() and not just_a_figment:
#     moving_towards_player = false
#     is_following_player = true
#     randomizeTargetPos()
#     level.player.glitchTickle()
#     level.player.malwareCorruptMe()

func isActive(_debug = false):
  return visible