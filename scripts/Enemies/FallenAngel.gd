extends "GlitchEnemy.gd"

var fallen_angel_timer = 0
var fallen_angel_time_limit = 10
var has_fallen = false
var is_heavy = false

func _process(delta):
  if not has_fallen:
    grav = Vector2(0, 0)
    fallen_angel_timer += (delta*11)
    if fallen_angel_timer >= fallen_angel_time_limit:
      fallen_angel_timer = 0
      has_fallen = true
      glitchSecretAniPlayer.stop()
      glitchSecretAniPlayer.clear_queue()
      glitchSecretAniPlayer.queue("preGlitchOut")
      glitchSecretAniPlayer.queue("glitchOut")
  elif is_heavy:
    if on_ground and was_on_ground:
      if not am_i_dying:
        dieSound.play()
      am_i_dying = true


func getHeavy():
  is_heavy = true
  grav = Vector2(0, 30)
  on_ground = false