extends "GlitchEnemy.gd"

onready var poofSound = get_node("Sounds/PoofSound")
onready var reassembleSound = get_node("Sounds/ReassembleSound")
onready var spawnSound = get_node("Sounds/SpawnSound")
export var is_evil = false

func _ready():
  smack_time_limit = 5
  smallInteractionArea.add_to_group("no_pushems")
  on_ground = false
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")

func setAsParent(_owner):
  walk_direction.x = -1

var is_stone = false
var teleporting = false
var has_teleported = false
var teleport_timer = 0
var teleport_time_limit = 30
var teleport_time_limit2 = 45
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if linear_velocity.y > 0:
    mySprite.frame_delay = 0.2
  else:
    mySprite.frame_delay = 0.4
  # if pauseSelf and not is_smacked:
  #   pauseSelf = false
  #   on_ground = true
  # if on_ground and getPlayer().summonedBroom != null and getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
  #   behavior_jumping = true

  # moveMyFriends(delta)
  lastPosition = self.global_transform.origin
  if teleporting:
    teleport_timer += (delta*22)
    if teleport_timer >= teleport_time_limit:
      if not has_teleported:
        queue_free() # bye bye
        # # TODO
        # reassembleSound.play()
        # has_teleported = true
        # for _i in range(1):
        #   spawnASpore(self.global_transform.origin, true)
    # if teleport_timer >= teleport_time_limit2:
    #   has_ever_been_smacked = false
    #   teleporting = false
    #   pauseSelf = false
    #   visible = true

  if is_evil and not teleporting:
    rotation_timer += (delta*22)
    if rotation_timer >= rotation_time_limit:
      rotation_timer = 0
      rotateClockwise()


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

func landed(_was_on_fallthrough_solid = false):
  .landed()
  behavior_jumping = false
  if is_evil:
    should_flip = false
    getSmacked()

# @override
func tryDieToOffscreenCamera(_delta):
  return

var should_flip = true
var my_shroom = null
# @override
func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
  if is_smacked or has_ever_been_smacked:
    return false
  spawnGlitchSprout()
  poofSound.play()
  .getSmacked(broom_origin, silently, is_local_broom)
  # if getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
  #   behavior_jumping = true
  pauseSelf = true
  # on_ground = true
  notDieSound.play()
  if is_local_broom and should_flip:
    playerInhale()

func passiveActivate(_delta, is_player, is_local_broom = false):
  if is_player:
    getSmacked(null, false, is_local_broom)
    playerInhale()
    if is_evil:
      pass
      # if level.player.malware_infected:
      #   level.player.malwareCured()
      # else:
      #   level.player.malwareCorruptMe()

var rotation_timer = 0
var rotation_time_limit = 20
func rotateClockwise():
  var rotZ = round(rotation_degrees.z)
  if rotZ == 0 or rotZ == 360:
    rotation_degrees.z = 270
  elif rotZ == 270 or rotZ == -90:
    rotation_degrees.z = 180
  elif rotZ == 180 or rotZ == -180:
    rotation_degrees.z = 90
  elif rotZ == 90 or rotZ == -270:
    rotation_degrees.z = 0
    
func playerInhale():
  level.player.gravitySound.pitch_scale = rand_range(0.8, 1.2)
  level.player.gravitySound.play()
  level.player.glitchTickle()
  if round(rotation_degrees.z) == -90 or round(rotation_degrees.z) == 270:
    level.flipGravity(Vector2(1, 0))
  elif round(rotation_degrees.z) == 90 or round(rotation_degrees.z) == -270:
    level.flipGravity(Vector2(-1, 0))
  elif round(rotation_degrees.z) == 180 or round(rotation_degrees.z) == -180:
    level.flipGravity(Vector2(0, -1))
  else:
    level.flipGravity(Vector2(0, 1))
  for _i in range(5):
    level.player.spawnASpore(level.player.global_transform.origin, false)

# @override
func unsmack():
  .unsmack()
  visible = false
  teleporting = true
  for _i in range(5):
    spawnASpore(self.global_transform.origin, false)
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
  should_collide_with_walls = true

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
  

func fallthroughCollisionClear(exFriend, _was_it_a_jump = false):
  who_is_standing_on_me.erase(exFriend.name)

func moveMyFriends(delta):
  for friend_key in who_is_standing_on_me.keys():
    var friendArray = who_is_standing_on_me[friend_key]
    var friend = friendArray[0]
    var relativePosition = friendArray[2]
    if friend.linear_velocity.y > 0 or friend.should_magic_jump:
      continue
    friend.was_fallthrough_area_collision_triggered = true
    var friend_x = friend.global_transform.origin.x
    friend.global_transform.origin += self.global_transform.origin - lastPosition
    friend.global_transform.origin.x = friend_x

    if friend.global_transform.origin.x < self.global_transform.origin.x + lb or \
       friend.global_transform.origin.x > self.global_transform.origin.x + rb:
      who_is_standing_on_me.erase(friend_key)
      continue
    friend.on_ground = true
    friend.linear_velocity.y = 0
    # TODO(jaketrower): TopsyTurvy
    # TODO(gravity): 
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
      spore.mySprite.get_ref().reverseIt()
    else:
      spore.global_transform.origin.x += rand_range(-1, 1)
      spore.global_transform.origin.y += rand_range(-1, 1)
      var r = 2
      spore.target_pos = Vector2(spore.global_transform.origin.x + rand_range(-r, r), spore.global_transform.origin.y + rand_range(-r, r))
      spore.delta_multiplier = 4.0

var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
func spawnGlitchSprout():
  if is_evil:
    var newGlitchEnemy = glitchEnemyRes.instance()
    newGlitchEnemy.is_static_in_level = false
    newGlitchEnemy.visible = true
    newGlitchEnemy.grav = Vector2(0, 0)
    newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
    # newGlitchEnemy.behavior_evolve = true
    # newGlitchEnemy.behavior_fizzle_out_after_evolve = true
    level.add_child(newGlitchEnemy)
    newGlitchEnemy.global_transform.origin = self.global_transform.origin
    var newGlitchMaterial = newGlitchEnemy.mySprite.get_material_override().duplicate()
    if newGlitchEnemy.mySprite.is_in_group("sprite"):
      newGlitchEnemy.mySprite.remove_from_group("sprite")
    if newGlitchMaterial is ShaderMaterial:
      newGlitchMaterial.set_shader_param("target_palette", global.weird_base_palette)
    newGlitchEnemy.mySprite.set_material_override(newGlitchMaterial)
    newGlitchEnemy.glitchOut()
