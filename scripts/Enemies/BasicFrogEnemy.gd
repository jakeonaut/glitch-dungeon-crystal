extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30

var air_timer = 0
var air_time_limit = 15

onready var interactionArea = get_node("SmallInteractionArea")

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

func _process(delta):
  print(should_do_fallthrough_area_collision)

  if on_ground:
    jump_timer +=  (delta * 22)
    if jump_timer >= jump_time_limit:
      behavior_jumping = true
      behavior_walking = true
      jump_timer = 0
  else:
    behavior_jumping = false
    mySprite.max_frames = 1
    if vv > 0:
      mySprite.updateBaseFrame(2, 0)
    else:
      mySprite.updateBaseFrame(3, 0)

    if behavior_walking:
      air_timer += (delta * 22)
      if air_timer >= air_time_limit:
        behavior_walking = false
        air_timer = 0

func glitchSwitchSprite(_delta):
  pass

func landed():
  .landed()
  behavior_walking = false
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)
  