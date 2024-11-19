extends "GlitchEnemy.gd"

var just_a_figment = false
var my_opacity = 0.9
var x_speed = 0
var y_speed = 1
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

  