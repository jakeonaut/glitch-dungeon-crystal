extends "GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")

func _ready():
  can_spawn_mini_crystal = false
  only_activate_in_range = false

func _process(delta):
  # ._process(delta) implicit
  if not visible: return
  
  delta = delta * global.time_dilation_multiplier

func isActive(_debug = false):
    return visible and mySprite.visible

func landed():
  ouchies(null)

func ouchies(broom_origin):
  .ouchies_base(broom_origin)

  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  secretAniPlayer.play("crackAndShatter")