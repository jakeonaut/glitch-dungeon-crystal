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
var cooldown_time_limit = 40
var is_in_cooldown = false
onready var wormAniPlayer = get_node("WormAnimationPlayer")
onready var mushroomBounceAniPlayer = get_node("MushroomBounceAniPlayer")

func _ready():
  original_material = mySprite.get_material_override().duplicate()
  pass

func _process(delta):
  if not visible:
    return

  mySprite.flip_h = level.player.global_transform.origin.x > global_transform.origin.x

  # flip_timer += (delta*22)
  # if flip_timer >= flip_time_limit:
  #   flip_timer = 0
  #   flip_time_limit = rand_range(5, 30)
  #   mySprite.flip_h = not mySprite.flip_h

  if is_in_cooldown:
    cooldown_timer += (delta*22)
    if cooldown_timer >= cooldown_time_limit:
      cooldown_timer = 0
      is_in_cooldown = false

# @override
func glitchSetSpritesAndCollision():
  pass


func glitchSwitchSprite(_delta):
  pass


var has_transformed = false
func passiveActivate(_delta, _is_player):
  if is_smacked or is_in_cooldown:
    return
  # if not getPlayer().is_mushroom_infected:
  #   return

  is_in_cooldown = true
  cooldown_timer = 0
  .getSmacked(null)
  global_transform.origin.z = 2
  getPlayer().pauseInput = true
  global.pauseMoveInput = true
  getPlayer().pauseAnimation = true
  wormAniPlayer.stop()
  wormAniPlayer.clear_queue()
  wormAniPlayer.queue("gulp")
  if not has_transformed:
    wormAniPlayer.queue("transform")
    has_transformed = true
  wormAniPlayer.queue("bob")

func jumpToPlayerPosition():
  global_transform.origin.x = getPlayer().global_transform.origin.x  
  if mySprite.flip_h:
    global_transform.origin.x -= 1
  else:
    global_transform.origin.x += 1
  
  global_transform.origin.y = getPlayer().global_transform.origin.y + 1

func cureMushroom():
  var playerMushroomOrigin = getPlayer().mushroomSpriteVisible.global_transform.origin
  level.summonSmokeClouds(playerMushroomOrigin, 1)
  getPlayer().getMushroomCured()

func finishGulp():
  global_transform.origin.z = 0
  getPlayer().pauseInput = false
  global.pauseMoveInput = false
  getPlayer().pauseAnimation = false
  global_transform.origin = Vector3(spawn_origin.x, spawn_origin.y, spawn_origin.z)

  
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
    spore.global_transform.origin.y -= rand_range(0, 1)
    spore.lifespan_time_limit = 15

onready var bounceSound = get_node("Sounds/BounceSound")
func fallthroughCollisionActivate(possible_game_mover):
  if not has_transformed:
    return

  # if level.player.nesting_doll_state == global.NestingDoll.BABY:
  if possible_game_mover != null and possible_game_mover == level.player and not level.player.pressingDown():
      getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y
      var jump_val = 14
      possible_game_mover.magicJump()
      getPlayer().linear_velocity.y = jump_val
      getPlayer().lv.y = jump_val
      getPlayer().vv = jump_val
      # getPlayer().physics_vars.applyHalfGrav = true
      # getPlayer().physics_vars.applyHalfGravTimer = 3
      bounceSound.pitch_scale = rand_range(0.8, 1.5)
      bounceSound.play()
      getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y
      mushroomBounceAniPlayer.stop()
      mushroomBounceAniPlayer.clear_queue()
      mushroomBounceAniPlayer.play("bounce")
      spawnASpore()