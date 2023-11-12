extends "GlitchEnemy.gd"

onready var interactionArea = get_node("SmallInteractionArea")
onready var landing = get_node("landing")
var landing_position = null

func _ready():
  smack_time_limit = 5
  interactionArea.add_to_group("no_pushems")
  landing.visible = false
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  landing_position = landing.global_transform.origin

func setAsParent(_owner):
  walk_direction.x = -1

var is_stone = false
func _process(delta):
  # if pauseSelf and not is_smacked:
  #   pauseSelf = false
  #   on_ground = true
  # if on_ground and getPlayer().summonedBroom != null and getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
  #   behavior_jumping = true

  moveMyFriends(delta)
  lastPosition = self.global_transform.origin
  if teleporting:
    teleport_timer += (delta*22)
    if teleport_timer >= teleport_time_limit:
      has_ever_been_smacked = false
      teleporting = false
      visible = true
      self.global_transform.origin = landing_position
      landing.global_transform.origin = lastPosition
      landing_position = lastPosition
      for _i in range(5):
        spawnASpore()


  # if not is_smacked:
  #   if getPlayer().glitch_form == global.GlitchForm.INVISIBLE and is_stone:
  #     is_stone = false
  #     mySprite.material_override.set_shader_param("target_palette", global.black_palette)
  #   elif getPlayer().glitch_form != global.GlitchForm.INVISIBLE and not is_stone:
  #     is_stone = true
  #     mySprite.material_override.set_shader_param("target_palette", global.black_palette_town)

  # if is_stone:
  #   self.linear_velocity.y = 0
  #   self.lv.y = 0
  #   self.terminal_vel = 0
  # else:
  #   self.terminal_vel = 14

func glitchSwitchSprite(_delta):
  pass

func landed():
  .landed()
  behavior_jumping = false

# @override
func getSmacked(broom_origin):
  if is_smacked or has_ever_been_smacked:
    return false
  .getSmacked(broom_origin)
  if getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
    behavior_jumping = true
  pauseSelf = true
  on_ground = true
  notDieSound.play()

var teleporting = false
var teleport_timer = 0
var teleport_time_limit = 10
# @override
func unsmack():
  .unsmack()
  visible = false
  teleporting = true
  for _i in range(5):
    spawnASpore()
  teleport_timer = 0
  
  

# @override
func pressingMoveLeft():
  var key_to_check = "ui_right"
  if who_is_standing_on_me.size() > 0:
    key_to_check = "ui_left"
  return Input.is_action_pressed(key_to_check) and getPlayer().glitch_form == global.GlitchForm.INVISIBLE and getPlayer().on_ground

# @override
func pressingMoveRight():
  var key_to_check = "ui_left"
  if who_is_standing_on_me.size() > 0:
    key_to_check = "ui_right"
  return Input.is_action_pressed(key_to_check) and getPlayer().glitch_form == global.GlitchForm.INVISIBLE and getPlayer().on_ground

# @override
func shouldIDoCollisions():
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
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
    if friend.linear_velocity.y > 0 or friend.should_magic_jump:
      continue
    friend.should_do_fallthrough_area_collision = true
    var friend_x = friend.global_transform.origin.x
    friend.global_transform.origin += self.global_transform.origin - lastPosition
    friend.global_transform.origin.x = friend_x

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

var sporeRes = preload("res://sceneObjects/Environment/CatSpore.tscn")
func spawnASpore():
    var spore = sporeRes.instance()
    level.add_child(spore)
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-1, 1)
    spore.global_transform.origin.y += rand_range(-1, 1)
    spore.global_transform.origin.z = self.global_transform.origin.z + 1.0
    var r = 2
    if visible:
      r = 1
    spore.target_pos = Vector2(spore.global_transform.origin.x + rand_range(-r, r), spore.global_transform.origin.y + rand_range(-r, r))
