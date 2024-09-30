extends "GlitchEnemy.gd"

onready var landing = get_node("landing")
onready var poofSound = get_node("Sounds/PoofSound")
onready var reassembleSound = get_node("Sounds/ReassembleSound")
var basicShroomEnemyRes = preload("res://sceneObjects/Enemies/BasicShroomEnemy.tscn")
var landing_position = null

func _ready():
  smack_time_limit = 5
  smallInteractionArea.add_to_group("no_pushems")
  landing.visible = false
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  landing_position = landing.global_transform.origin

func setAsParent(_owner):
  walk_direction.x = -1

var is_stone = false
var teleporting = false
var has_teleported = false
var teleport_timer = 0
var teleport_time_limit = 15
var teleport_time_limit2 = 30
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
      for _i in range(1):
        spawnASpore(self.global_transform.origin, true)
        if global.memory["magic_lantern"]:
          spawnASpore(level.player.global_transform.origin, true)
      if not has_teleported:
        # TODO
        reassembleSound.play()
        if global.memory["magic_lantern"]:
          var position = self.global_transform.origin
          self.global_transform.origin = level.player.global_transform.origin
          level.player.global_transform.origin = position
        else:
          self.global_transform.origin = landing_position
          landing.global_transform.origin = lastPosition
          var temp_rotation_degrees = mySprite.rotation_degrees.z
          mySprite.rotation_degrees.z = landing.rotation_degrees.z
          landing.rotation_degrees.z = temp_rotation_degrees
          landing_position = lastPosition
        has_teleported = true
    if teleport_timer >= teleport_time_limit2:
      has_ever_been_smacked = false
      teleporting = false
      visible = true
      if global.memory["magic_lantern"]:
        level.player.visible = true
        level.player.physics_state = PhysicsState.NORMAL


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

var old_broom_origin = null
var my_shroom = null
# @override
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  if is_smacked or has_ever_been_smacked:
    return false
  poofSound.play()
  .getSmacked(broom_origin, silently)
  if global.memory["magic_lantern"]:
    level.player.getSmacked()
    level.player.physics_state = PhysicsState.OCCUPIED
  # if getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
  #   behavior_jumping = true
  pauseSelf = true
  on_ground = true
  notDieSound.play()
  old_broom_origin = broom_origin

  # if my_shroom != null:
  #   my_shroom.queue_free()
  #   my_shroom = null

  var babyShroom = basicShroomEnemyRes.instance()
  if old_broom_origin.x > self.global_transform.origin.x:
    babyShroom.walk_direction.x = -1
  else:
    babyShroom.walk_direction.x = 1
  level.add_child(babyShroom)
  babyShroom.global_transform.origin = self.global_transform.origin
  my_shroom = babyShroom

# @override
func unsmack():
  .unsmack()
  visible = false
  if global.memory["magic_lantern"]:
      level.player.visible = false
  teleporting = true
  for _i in range(5):
    spawnASpore(self.global_transform.origin, false)
    if global.memory["magic_lantern"]:
      spawnASpore(level.player.global_transform.origin, false)
  teleport_timer = 0
  has_teleported = false
  
  

# @override
# func pressingMoveLeft():
#   var key_to_check = "ui_right"
#   if who_is_standing_on_me.size() > 0:
#     key_to_check = "ui_left"
#   return Input.is_action_pressed(key_to_check) and getPlayer().glitch_form == global.GlitchForm.INVISIBLE and getPlayer().on_ground

# # @override
# func pressingMoveRight():
#   var key_to_check = "ui_left"
#   if who_is_standing_on_me.size() > 0:
#     key_to_check = "ui_right"
#   return Input.is_action_pressed(key_to_check) and getPlayer().glitch_form == global.GlitchForm.INVISIBLE and getPlayer().on_ground

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
  if not who_is_standing_on_me.has(friend.name):
    playBounce("landSoft")
    # spawnASpore(self.global_transform.origin, false)
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
func spawnASpore(where_origin, inverse):
    var spore = sporeRes.instance()
    level.add_child(spore)
    spore.global_transform.origin = where_origin
    spore.global_transform.origin.z = where_origin.z + 2.0

    if inverse:
      spore.global_transform.origin.x += rand_range(-3, 3)
      spore.global_transform.origin.y += rand_range(-3, 3)
      var r = 1
      spore.target_pos = Vector2(global_transform.origin.x + rand_range(-r, r), global_transform.origin.y + rand_range(-r, r))
      spore.delta_multiplier = 2.0
      spore.mySprite.reverseIt()
    else:
      spore.global_transform.origin.x += rand_range(-1, 1)
      spore.global_transform.origin.y += rand_range(-1, 1)
      var r = 2
      spore.target_pos = Vector2(spore.global_transform.origin.x + rand_range(-r, r), spore.global_transform.origin.y + rand_range(-r, r))
      spore.delta_multiplier = 4.0
