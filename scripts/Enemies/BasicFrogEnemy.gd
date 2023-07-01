extends "GlitchEnemy.gd"

var jump_timer = 0
export var jump_time_limit = 30
var water_jump_time_limit = 10

var air_timer = 0
export var air_time_limit = 15
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

onready var mushroomSprite = get_node("MushroomSprite") if has_node("MushroomSprite") else null
onready var mySprite2 = get_node("Sprite3D2") if has_node("Sprite3D2") else null
export var goBackToPlayer = false

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)
  original_material = mySprite.get_material_override().duplicate()

  smack_time_limit = 5
  interactionArea.add_to_group("no_pushems")
    

func setAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = -1

func _process(delta):
  if not visible:
    return

  if am_i_in_range_of_player:
    override_am_i_in_range_of_player = true

  if is_infected:
    if mySprite2:
      mySprite.set_material_override(mySprite2.get_material_override())
    if mushroomSprite:
      mushroomSprite.visible = true
    if not interactionArea.is_in_group("enemies"):
      interactionArea.add_to_group("enemies")
  else:
    if original_material:
      mySprite.set_material_override(original_material)
    if mushroomSprite:
      mushroomSprite.visible = false

  if pauseSelf and not is_smacked:
    pauseSelf = false
    on_ground = true

  if on_ground or is_static or is_touching_water:
    if not is_static:
      jump_timer +=  (delta * 22)
      if jump_timer >= jump_time_limit or (is_touching_water and jump_timer >= water_jump_time_limit):
        behavior_jumping = true
        behavior_walking = true
        jump_timer = 0

    if not is_infected and is_static:
      spawn_timer += (delta*22)
      if spawn_timer >= spawn_time_limit or (is_touching_water and spawn_timer >= water_jump_time_limit):
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

    if behavior_walking and air_time_limit > 0:
      air_timer += (delta * 22)
      if air_timer >= air_time_limit:
        behavior_walking = false
        air_timer = 0

  moveMyFriends(delta)
  lastPosition = self.global_transform.origin

  if not on_ground:
    mySprite.max_frames = 1
    if vv > 0:
      mySprite.updateBaseFrame(2, 0)
    else:
      mySprite.updateBaseFrame(3, 0)

func glitchSwitchSprite(_delta):
  pass

# @override
func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            if goBackToPlayer:
              actuallyGoBackToPlayer()
            else:
              setGlobalMemoryOfHasBeenDefeated()
              queue_free()

    if goBackToPlayer:
      var dist = self.global_transform.origin.distance_to(level.player.global_transform.origin)
      if dist > 20:
        actuallyGoBackToPlayer()

func actuallyGoBackToPlayer():
  self.global_transform.origin = level.player.global_transform.origin
  self.lv.y = jump_force
  self.vv = jump_force
  self.linear_velocity.y = jump_force
  walk_direction.x = randi() % 2
  if walk_direction.x == 0: walk_direction.x = -1

func landed():
  .landed()
  behavior_walking = false
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

  if is_infected:
    var how_many = randi() % 3 + 1
    for _i in range(how_many):
      spawnASpore()
  
var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
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

# @override
func getSmacked(broom_origin):
  .getSmacked(broom_origin)
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
  # is_static = false
  pauseSelf = true
  on_ground = true
  if notDieSound and not notDieSound.is_playing():
    notDieSound.play()

func fallthroughCollisionActivate(friend):
  if not friend.on_ground:
    pass # just landed
  # TODO(jaketrower): The downside to this if there are multiple fallthroughSolids a game_mover is "on"
  # is that multiple of them could fight for control here
  # so TODO(jaketrower): Need to make the game_mover call like "fallthroughCollisionClear"
  # if we are on another 
  # ALSO, need to make game_mover call "fallthroughCollisionClear" if we ever
  # like jump, or fall off too...
  var relativePosition = self.global_transform.origin - friend.global_transform.origin
  who_is_standing_on_me[friend.name] = [friend, 0, relativePosition]

func fallthroughCollisionClear(exFriend):
  who_is_standing_on_me.erase(exFriend.name)


  
func moveMyFriends(delta):
  for friend_key in who_is_standing_on_me.keys():
    var friendArray = who_is_standing_on_me[friend_key]
    var friend = friendArray[0]
    var relativePosition = friendArray[2]
    friend.should_do_fallthrough_area_collision = true
    friend.global_transform.origin += self.global_transform.origin - lastPosition
    if friend.global_transform.origin.x < self.global_transform.origin.x + lb or \
       friend.global_transform.origin.x > self.global_transform.origin.x + rb:
      who_is_standing_on_me.erase(friend_key)
      continue
    friend.on_ground = true
    friend.linear_velocity.y = 0
    friend.fallthrough_area_collision_y = self.global_transform.origin.y - relativePosition.y + (self.linear_velocity.y*delta)

    # try to clean up
    friendArray[1] += (delta*22)
    if friendArray[1] >= move_my_friends_time_limit:
      who_is_standing_on_me.erase(friend_key)
