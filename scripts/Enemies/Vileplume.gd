extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30
var water_jump_time_limit = 10

var air_timer = 0
var air_time_limit = 15
var spawn_timer = 0
var spawn_time_limit = 15

var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")

export var is_static = false
export var is_infected = false

onready var interactionArea = get_node("SmallInteractionArea")
var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
var original_material = null

var flip_timer = 0
var flip_time_limit = 20

func _ready():
  original_material = mySprite.get_material_override().duplicate()

func _process(delta):
  if not visible:
    return

  flip_timer += (delta*22)
  if flip_timer >= flip_time_limit:
    flip_timer = 0
    flip_time_limit = rand_range(5, 30)
    mySprite.flip_h = not mySprite.flip_h

# @override
func glitchSetSpritesAndCollision():
  pass


func glitchSwitchSprite(_delta):
  pass

# @override
func getSmacked(broom_origin):
  if is_smacked:
    return
  .getSmacked(broom_origin)
  summonSmokeClouds(5)
  spawnFiveSpores()

func spawnFiveSpores():
  for _i in range(10):
      spawnASpore()
  
var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
func spawnASpore():
    var spore = sporeRes.instance()
    spore.initially_fly_up = true
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    level.add_child(spore)
    spore.setAsParent(self)
    spore.bubble_speed = -rand_range(2.925, 3.8)
    spore.target_pos.x = self.global_transform.origin.x + rand_range(-3, 3)
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-2, 2)
    spore.global_transform.origin.y -= rand_range(0, .725)
    spore.lifespan_time_limit = 15
