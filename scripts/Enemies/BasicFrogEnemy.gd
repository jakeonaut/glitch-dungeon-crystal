extends "GlitchEnemy.gd"

var jump_timer = 0
var jump_time_limit = 30

var air_timer = 0
var air_time_limit = 15
var spawn_timer = 0
var spawn_time_limit = 3

var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")

export var is_static = false
export var is_infected = false

onready var interactionArea = get_node("SmallInteractionArea")
var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)

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

  if on_ground or is_static:
    if not is_static:
      jump_timer +=  (delta * 22)
      if jump_timer >= jump_time_limit:
        behavior_jumping = true
        behavior_walking = true
        jump_timer = 0

    if not is_infected:
      spawn_timer += (delta*22)
      if spawn_timer >= spawn_time_limit:
          spawn_timer = 0
          # var bubble = bubbleRes.instance()
          # level.add_child(bubble)
          # bubble.global_transform.origin = self.global_transform.origin
          # bubble.original_pos_x = self.global_transform.origin.x
          # bubble.target_pos_x = self.global_transform.origin.x + rand_range(-1, 1)
          # bubble.global_transform.origin.y += 1
          # bubble.setAsParent(self)
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

  moveMyFriends(delta)
  lastPosition = self.global_transform.origin

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

# @override
func getSmacked():
  .getSmacked()
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction = 1
  if level.player.mySprite.flip_h:
    walk_direction = -1
  is_static = false
  pauseSelf = true
  on_ground = true
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
    var lb = -get_node("CollisionShape").shape.radius
    var rb = -lb
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
