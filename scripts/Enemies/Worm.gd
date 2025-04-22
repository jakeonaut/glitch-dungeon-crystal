extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30
var water_jump_time_limit = 10

var air_timer = 0
var air_time_limit = 15
var spawn_timer = 0
var spawn_time_limit = 15

export var is_static = false
export var is_hungry = false

var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
var original_material = null

var flip_timer = 0
var flip_time_limit = 20
var cooldown_timer = 0
var cooldown_time_limit = 40
var is_in_cooldown = false

func _ready():
  original_material = mySprite.get_material_override().duplicate()
  slime_walk_time_limit = 3
  slime_idle_time_limit = 3

func _process(delta):
  if not visible: return

  if is_in_cooldown:
    cooldown_timer += (delta*22)
  if cooldown_timer >= cooldown_time_limit:
    cooldown_timer = 0
    is_in_cooldown = false
  lastPosition = self.global_transform.origin
  checkForWalkPathOverrides()

func checkForWalkPathOverrides():
  if has_ever_been_smacked:
    return

  var areas = smallInteractionArea.get_overlapping_areas()
  for area in areas:
      if area.is_in_group("walkpath"):
        var walk_anchor = area.get_node("..")
        if walk_anchor.frame == 1:
          walk_direction.x = 1
        elif walk_anchor.frame == 2:
          walk_direction.x = -1

# @override
func pressingMoveLeft():
  if am_i_dying or not visible: return false
  return walk_direction.x == -1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
  if am_i_dying or not visible: return false
  return walk_direction.x == 1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))


func glitchSwitchSprite(_delta):
  pass

func passiveActivate(_delta, _is_player):
  pass

# @override
func handleSlimeWalking(delta):
  if behavior_intermittent_walking:
    slime_state_timer += (delta*22)
    if slime_state == SlimeState.WALK:
      mySprite.trySetFrame(20 if not is_hungry else 18)
      behavior_walking = true
      if slime_state_timer >= slime_walk_time_limit:
        slime_state_timer = 0
        slime_state = SlimeState.IDLE 
    elif slime_state == SlimeState.IDLE:
      mySprite.trySetFrame(19 if not is_hungry else 17)
      behavior_walking = false
      if slime_state_timer >= slime_idle_time_limit:
        slime_state_timer = 0
        slime_state = SlimeState.WALK


func cureMushroom():
  getPlayer().tryDieToEnemy(0, true, true, true)

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

# @override
func getSmacked(broom_origin = null, silently = false):
  if has_ever_been_smacked:
    return
  .getSmacked(broom_origin, silently)
  walk_speed = 0
  grav = 0
  walk_direction.x = -1
  if level.player.mySprite.flip_h:
    walk_direction.x = 1
  linear_velocity.y = 0
  lv.y = 0
  behavior_walking = false
  behavior_intermittent_walking = false
  smallInteractionArea.add_to_group("no_pushems")

export var building_time_limit = 10
var moleCricketRes = preload("res://sceneObjects/Enemies/GlitchMoleCricket.tscn")
# @override
func unsmack():
  .unsmack()
  var evolvedSelf = moleCricketRes.instance()
  evolvedSelf.is_builder = not is_hungry
  evolvedSelf.behavior_stick_to_walls = true
  evolvedSelf.do_i_care_about_time_limit = true
  evolvedSelf.grav = 0
  evolvedSelf.on_ground = true
  evolvedSelf.my_up_vector = self.my_up_vector
  evolvedSelf.building_time_limit = building_time_limit
  evolvedSelf.permanently_alter_tiles = false
  evolvedSelf.keep_spawning_anyway = true
  level.add_child(evolvedSelf)
  evolvedSelf.global_transform.origin = self.global_transform.origin
  evolvedSelf.get_node("Sprite3D2").rotation_degrees = mySprite.rotation_degrees
  evolvedSelf.startDigging()
  queue_free()
