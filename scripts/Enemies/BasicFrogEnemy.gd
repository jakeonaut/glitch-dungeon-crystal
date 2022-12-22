extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30

var air_timer = 0
var air_time_limit = 15
var spawn_timer = 0
var spawn_time_limit = 10

var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")

export var is_infected = false

onready var interactionArea = get_node("SmallInteractionArea")

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

func setAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction = -1

func _process(delta):
  if on_ground:
    jump_timer +=  (delta * 22)
    if jump_timer >= jump_time_limit:
      behavior_jumping = true
      behavior_walking = true
      jump_timer = 0

    if not is_infected:
      spawn_timer += (delta*22)
      if spawn_timer >= spawn_time_limit:
          spawn_timer = 0
          var bubble = bubbleRes.instance()
          level.add_child(bubble)
          bubble.global_transform.origin = self.global_transform.origin
          bubble.original_pos_x = self.global_transform.origin.x
          bubble.target_pos_x = self.global_transform.origin.x + rand_range(-1, 1)
          bubble.global_transform.origin.y += 1
          bubble.setAsParent(self)
  else:
    spawn_timer = 0
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

  if is_infected:
    var how_many = randi() % 3 + 1
    for _i in range(how_many):
      spawnASpore()
  
func spawnASpore():
    var spore = sporeRes.instance()
    spore.initially_fly_up = true
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    level.add_child(spore)
    spore.bubble_speed = -rand_range(1.925, 2.8)
    spore.target_pos.x = self.global_transform.origin.x + rand_range(-1, 1)
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-1, 1)
    spore.global_transform.origin.y += 1.5
    spore.global_transform.origin.y -= rand_range(0, .225)
