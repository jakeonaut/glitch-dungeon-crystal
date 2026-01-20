extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 0


func _ready():
  smack_time_limit = 5
  smallInteractionArea.add_to_group("no_pushems")

func setAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = -1

func _process(delta):
  if pauseSelf and not is_smacked:
    pauseSelf = false
    on_ground = true

  if on_ground:
    jump_timer +=  (delta * 22)
    if jump_timer >= jump_time_limit:
        behavior_jumping = true
        behavior_walking = true
        jump_timer = 0
  else:
    behavior_jumping = false

func glitchSwitchSprite(_delta):
  pass

func landed(_was_on_fallthrough_solid = false):
  .landed()
  behavior_walking = false

# @override
func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
  .getSmacked(broom_origin, silently, is_local_broom)
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
  pauseSelf = true
  on_ground = true
  notDieSound.play()