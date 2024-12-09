extends "GlitchEnemy.gd"

var just_a_figment = false
var my_opacity = 0.9
var x_speed = 0
var y_speed = 1
var original_pos = null
var true_original_pos = null
var target_pos = null
var is_following_player = false
var do_i_belong_here = true

func _process(delta):
  # ._process(delta) implicit
  if not visible: return
  
  delta = delta * global.time_dilation_multiplier

  if just_a_figment:
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
    if my_opacity <= 0:
      queue_free()
  else:
    behavior_phase_through_walls = true

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

func passiveActivate(_delta, is_player):
  if is_player and not level.player.malware_infected and not is_following_player and not level.player.isOnSavePoint() and not just_a_figment:
    is_following_player = true
    level.player.glitchTickle()
    level.player.malwareCorruptMe()