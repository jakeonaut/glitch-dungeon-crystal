extends "GlitchEnemy.gd"

onready var interactionArea = get_node("SmallInteractionArea")

func _ready():
  smack_time_limit = 5
  interactionArea.add_to_group("no_pushems")

func setAsParent(_owner):
  walk_direction.x = -1

var is_stone = false
func _process(_delta):
  if pauseSelf and not is_smacked:
    pauseSelf = false
    on_ground = true
  if on_ground and getPlayer().summonedBroom != null and getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
    behavior_jumping = true

  if not is_smacked:
    if getPlayer().glitch_form == global.GlitchForm.INVISIBLE and is_stone:
      is_stone = false
      mySprite.material_override.set_shader_param("target_palette", global.black_palette)
      mySprite.max_frames = 2
      mySprite.set_frame(76)
    elif getPlayer().glitch_form != global.GlitchForm.INVISIBLE and not is_stone:
      is_stone = true
      mySprite.material_override.set_shader_param("target_palette", global.tidepool_palette)
      mySprite.max_frames = 1
      mySprite.set_frame(78)

func glitchSwitchSprite(_delta):
  pass

func landed():
  .landed()
  behavior_jumping = false

# @override
func getSmacked(broom_origin):
  if is_smacked:
    return false
  .getSmacked(broom_origin)
  if getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
    behavior_jumping = true
  pauseSelf = true
  on_ground = true
  notDieSound.play()

# @override
func pressingMoveLeft():
  return on_ground and Input.is_action_pressed("ui_right") and getPlayer().glitch_form == global.GlitchForm.INVISIBLE

# @override
func pressingMoveRight():
  return on_ground and Input.is_action_pressed("ui_left") and getPlayer().glitch_form == global.GlitchForm.INVISIBLE

# @override
func shouldIDoCollisions():
    should_collide_floor = true
    should_collide_ceil = true
    should_collide_horizontally = true