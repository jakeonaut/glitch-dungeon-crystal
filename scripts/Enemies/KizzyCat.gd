extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 0

onready var interactionArea = get_node("SmallInteractionArea")

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

  smack_time_limit = 5
  interactionArea.add_to_group("no_pushems")

func setAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction = -1

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
    # mySprite.max_frames = 1
    # if vv > 0:
    #   mySprite.updateBaseFrame(2, 0)
    # else:
    #   mySprite.updateBaseFrame(3, 0)

func glitchSwitchSprite(_delta):
  pass

func landed():
  .landed()
  behavior_walking = false
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

# @override
func getSmacked():
  .getSmacked()
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction = 1
  if level.player.mySprite.flip_h:
    walk_direction = -1
  pauseSelf = true
  on_ground = true
  notDieSound.play()