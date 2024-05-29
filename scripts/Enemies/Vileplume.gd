extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30
var water_jump_time_limit = 10

var air_timer = 0
var air_time_limit = 15
var spawn_timer = 0
var spawn_time_limit = 15

export var is_static = false
export var is_infected = false

var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
var original_material = null

var flip_timer = 0
var flip_time_limit = 20
var cooldown_timer = 0
var cooldown_time_limit = 80
var is_in_cooldown = true

onready var vileAniPlayer = get_node("VileplumeAnimationPlayer")

func _ready():
  original_material = mySprite.get_material_override().duplicate()
  pass

func _process(delta):
  if not visible:
    return

  # flip_timer += (delta*22)
  # if flip_timer >= flip_time_limit:
  #   flip_timer = 0
  #   flip_time_limit = rand_range(5, 30)
  #   mySprite.flip_h = not mySprite.flip_h
  mySprite.flip_h = level.player.global_transform.origin.x > global_transform.origin.x

  if is_in_cooldown:
    cooldown_timer += (delta*22)
    if cooldown_timer >= cooldown_time_limit:
      cooldown_timer = 0
      is_in_cooldown = false
      getSmacked(self.global_transform.origin)

# @override
func glitchSetSpritesAndCollision():
  pass

func glitchSwitchSprite(_delta):
  pass

# @override
func getSmacked(broom_origin):
  if (getPlayer().is_mushroom_infected or getPlayer().is_mushroom_prefected) and (is_smacked or is_in_cooldown):
    return
  is_in_cooldown = true
  cooldown_timer = 0
  .getSmacked(broom_origin)
  var smokeOrigin = Vector3(global_transform.origin.x, global_transform.origin.y + 1, 0)
  level.summonSmokeClouds(smokeOrigin, 5)
  spawnFiveSpores()

func passiveActivate(_delta, _is_player):
  # getSmacked(self.global_transform.origin)
  # getPlayer().getMushroomInfected()
  # getPlayer().tryDieToEnemy(delta, true, false, false)
  pass

# @override
func unsmack():
  .unsmack()
  vileAniPlayer.play("bob")


func spawnFiveSpores():
  for _i in range(5):
      spawnASpore()
  
var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
func spawnASpore():
    var spore = sporeRes.instance()
    spore.initially_fly_up = true
    level.add_child(spore)
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    spore.setAsParent(self)
    spore.bubble_speed = -rand_range(2.925, 3.8)
    spore.target_pos.x = self.global_transform.origin.x + rand_range(-4, 4)
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-3, 3)
    spore.global_transform.origin.y += rand_range(0, 1)
    spore.lifespan_time_limit = 15
