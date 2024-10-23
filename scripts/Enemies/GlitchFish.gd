extends "GlitchEnemy.gd"

var can_flip_flop = false
var can_flip_flop_timer = 0
var can_flip_flop_time_limit = 10
var weak_fish_jump_force = 6
export var fish_jump_force = 18
var no_longer_glitched = false

# Called when the node enters the scene tree for the first time.
func _ready():
  # ._ready() implicit
  grav = 0
  
  if behavior_jumping:
    grav = 60
    jump_force = weak_fish_jump_force
    should_collide_horizontally = false
  else:
    should_collide_floor = false
    should_collide_ceil = false
  should_only_do_middle_sensor = true
  should_do_simple_sensor_probe = true
    
  myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())

func _process(delta):
  # ._process(delta) implicit
  
  delta = delta * global.time_dilation_multiplier

  if not can_flip_flop:
    can_flip_flop_timer += (delta*22)
    if can_flip_flop_timer >= can_flip_flop_time_limit:
      can_flip_flop_timer = 0
      can_flip_flop = true

  if (was_on_ground or on_ground) and can_flip_flop:
    can_flip_flop = false
    if jump_force == weak_fish_jump_force:
      jump_force = fish_jump_force
    else:
      jump_force = weak_fish_jump_force
      
  if no_longer_glitched:
    if smallInteractionArea.is_touching_water:
      behavior_walking = false
      behavior_jumping = true
      grav = 60
      jump_force = weak_fish_jump_force
    else:
      behavior_walking = false
      behavior_jumping = false
      grav = 0
      behavior_mini_explore = true

func processDeath():
  if not dieSound.is_playing():
    no_longer_glitched = true
    pauseSelf = false
    
func ouchies(_broom_origin):
  .ouchies(_broom_origin)
  myOtherSprite.material_override.set_shader_param("enable_palette_cycle", false)
