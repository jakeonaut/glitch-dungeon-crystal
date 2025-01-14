extends "GlitchEnemy.gd"

var jump_timer = 0
export var jump_time_limit = 30
var water_jump_time_limit = 10

var air_timer = 0
export var air_time_limit = 15
export var spawn_timer = 0
var spawn_time_limit = 15

export var is_static = false
export var is_licker = false
export var is_bubble_spitter = false
export var is_infected = false
var is_fragile = false
var was_infected = false

var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
export var blow_bubble_horizontally = false

onready var mushroomSprite = get_node("MushroomSprite") if has_node("MushroomSprite") else null
onready var tileSpikes = get_node("TileSpikes") if has_node("TileSpikes") else null
onready var mySprite2 = get_node("Sprite3D2") if has_node("Sprite3D2") else null
onready var tongueSprite = get_node("TongueSprite") if has_node("TongueSprite") else null
onready var tongueSprite2 = get_node("TongueSprite2") if has_node("TongueSprite2") else null
onready var tongueSprite3 = get_node("TongueSprite3") if has_node("TongueSprite3") else null
onready var tongueSprite4 = get_node("TongueSprite4") if has_node("TongueSprite4") else null
export var should_have_fallthrough = true

func _ready():
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)
  mySprite.set_material_override(mySprite.get_material_override().duplicate())
  if is_bubble_spitter:
    mySprite.material_override.set_shader_param("target_palette", global.base_palette)
    mySprite.material_override.set_shader_param("offset", -1)
  if tongueSprite:
    var tongueSpriteMaterial = tongueSprite.get_material_override().duplicate()
    tongueSprite.set_material_override(tongueSpriteMaterial)
    tongueSprite2.set_material_override(tongueSpriteMaterial)
    tongueSprite3.set_material_override(tongueSpriteMaterial)
    tongueSprite4.set_material_override(tongueSpriteMaterial)

  smallInteractionArea.add_to_group("no_pushems")
  should_smack_pause_me = false

  if self.getMyStaticLevelZoneVar():
    is_infected = false

func setAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = -1

func evilSetAsParent(_owner):
  behavior_jumping = true
  behavior_walking = true
  jump_timer = 0
  walk_direction.x = -1
  is_infected = true

func _process(delta):
  if not visible:
    return

  if gulpin and tongueController and tongueController.hookTarget and tongueController.hookTarget.get_ref():
    var lickedGameMover = tongueController.hookTarget.get_ref()
    lickedGameMover.visible = false
    if lickedGameMover == level.player:
      level.player.processCastingLogic(delta)
    if tongueAniPlayer != null and tongueAniPlayer.assigned_animation != "spitOut":
      # if Input.is_action_pressed("ui_left"):
      #   mySprite.flip_h = true
      # elif Input.is_action_pressed("ui_right"):
      #   mySprite.flip_h = false
      var valid_inputs = ["sub_action_button"]
      for valid_input in valid_inputs:
        if (not tongueAniPlayer.is_playing() or (lickedGameMover == level.player and Input.is_action_just_pressed(valid_input))):
          tongueAniPlayer.stop()
          tongueAniPlayer.clear_queue()
          tongueAniPlayer.play("spitOut")
          break
    # if tongueAniPlayer.assigned_animation == "gulpIdle" and not tongueAniPlayer.is_playing():
    #   tongueAniPlayer.play("gulpIdle")
    return

  if am_i_in_range_of_player:
    override_am_i_in_range_of_player = true
    if level.player.global_transform.origin.y > self.global_transform.origin.y + 1:
      mySprite.translation.z = 1.5
    else:
      mySprite.translation.z = 0.5

  if is_infected:
    is_turn_based = true
    if not was_infected:
      mySprite.get_material_override().set_shader_param("enable_glitch", true)
      mySprite.get_material_override().set_shader_param("time_influence", 21.644)
      mySprite.get_material_override().set_shader_param("shake_color_rate", 0.625)
      mySprite.get_material_override().set_shader_param("target_palette", global.rgb_palette)
    if tileSpikes:
      tileSpikes.visible = true
    if not smallInteractionArea.is_in_group("weak_enemies"):
      smallInteractionArea.add_to_group("weak_enemies")
    if not smallInteractionArea.is_in_group("enemies"):
      smallInteractionArea.add_to_group("enemies")
  else:
    is_turn_based = false
    if tileSpikes:
      tileSpikes.visible = false
    if smallInteractionArea.is_in_group("weak_enemies"):
      smallInteractionArea.remove_from_group("weak_enemies")
    if smallInteractionArea.is_in_group("enemies"):
      smallInteractionArea.remove_from_group("enemies")
  was_infected = is_infected

  if pauseSelf and not is_smacked:
    pauseSelf = false
    on_ground = true

  elif on_ground or is_static: # or is_touching_water:
    if not is_static:
      jump_timer +=  (delta * 22)
      if jump_timer >= jump_time_limit: # or (is_touching_water and jump_timer >= water_jump_time_limit):
        behavior_jumping = true
        behavior_walking = true
        jump_timer = 0

    if on_ground and is_static and (not is_infected or is_licker):
      if not is_licker or tongueAniPlayer == null or not tongueAniPlayer.is_playing():
        spawn_timer += (delta*22)
        if spawn_timer >= spawn_time_limit: # or (is_touching_water and spawn_timer >= water_jump_time_limit):
            spawn_timer = 0
            if is_bubble_spitter:
              spawnABubble(blow_bubble_horizontally)
            if is_licker and tongueAniPlayer != null:
              tongueAniPlayer.stop()
              tongueAniPlayer.clear_queue()
              if mySprite.flip_h:
                tongueAniPlayer.play_backwards("lickSudden")
                tongueAniPlayer.queue("lickIdle")
                tongueAniPlayer.queue("lick")
              else:
                tongueAniPlayer.play_backwards("lickSuddenRight")
                tongueAniPlayer.queue("lickIdle")
                tongueAniPlayer.queue("lickRight")
            else:
              spawnABubble(blow_bubble_horizontally)
  elif behavior_jumping and tongueAniPlayer != null and tongueAniPlayer.is_playing():
    pass
  else:
    spawn_timer = 0
    behavior_jumping = false

    if behavior_walking and air_time_limit > 0 and not is_turn_based:
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

# @override
func updateFallthroughSolids():
  if is_infected or not should_have_fallthrough:
    if fallthroughSolid and fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.remove_from_group("fallthrough")
  else:
    if fallthroughSolid and not fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.add_to_group("fallthrough")

var gulpin = false
func startGulp():
  if not gulpin:
    gulpin = true
    var lickedGameMover = tongueController.hookTarget.get_ref() if tongueController and tongueController.hookTarget else null
    if lickedGameMover != null:
      if lickedGameMover.physics_state == -1:
        if lickedGameMover.has_method("corruptMyself"):
          lickedGameMover.corruptMyself()
        corruptMyself()
      else:
        lickedGameMover.physics_state = lickedGameMover.PhysicsState.IGNORE_PHYSICS
      
    notDieSound.play()

onready var tongueController = get_node("TongueController") if has_node("TongueController") else null
var SPIT_OFFSET = Vector2(0.2, 0.2)
func spitOut():
  var lickedGameMover = tongueController.hookTarget.get_ref() if tongueController and tongueController.hookTarget else null
  if lickedGameMover != null:
    lickedGameMover.global_transform.origin = self.global_transform.origin
    lickedGameMover.global_transform.origin.y += SPIT_OFFSET.y
    if mySprite.flip_h: # left
      lickedGameMover.global_transform.origin.x -= SPIT_OFFSET.x
      if is_bubble_spitter and lickedGameMover.pressingMoveLeft():
        lickedGameMover.global_transform.origin.x -= SPIT_OFFSET.x * 2
    else: # right
      lickedGameMover.global_transform.origin.x += SPIT_OFFSET.x
      if is_bubble_spitter and lickedGameMover.pressingMoveRight():
        lickedGameMover.global_transform.origin.x += SPIT_OFFSET.x * 2
  notDieSound.play()
  gulpin = false
  if lickedGameMover != null:
    lickedGameMover.visible = true
    lickedGameMover.on_ground = true
  if tongueController != null:
    tongueController.hooked = false
    tongueController.hookTarget = null
  if lickedGameMover != null:
    if lickedGameMover.has_method("glitchTickle"): lickedGameMover.glitchTickle()
    if lickedGameMover.has_method("tumbleFall"): lickedGameMover.tumbleFall(Vector2(-1 if mySprite.flip_h else 1, 0))
    if lickedGameMover == level.player and level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
      level.player.playBounce("grow")
    if is_bubble_spitter and lickedGameMover.has_method("getBubbleInfected"):
      lickedGameMover.getBubbleInfected()
      yield(get_tree().create_timer(0.2), "timeout")
      lickedGameMover.physics_state = lickedGameMover.PhysicsState.NORMAL
    yield(get_tree().create_timer(0.1), "timeout")
    lickedGameMover.visible = true

func queueGulpAnimation():
  if tongueAniPlayer == null:
    return
  var gulpIdleAnimation = tongueAniPlayer.get_animation("gulpIdle")
  gulpIdleAnimation.loop = false
  gulpIdleAnimation.length = 1.4
  if tongueController and tongueController.hookTarget and tongueController.hookTarget.get_ref() != level.player:
    gulpIdleAnimation.length = 2.1
  tongueAniPlayer.queue("gulpIdle")
  # tongueAniPlayer.queue("spitOut")

func unqueueGulpAnimation():
  if tongueAniPlayer == null:
    return
  var queuedAnimations = tongueAniPlayer.get_queue()
  tongueAniPlayer.clear_queue()
  for aniName in queuedAnimations:
    if aniName != "gulpIdle" and aniName != "spitOut":
      tongueAniPlayer.queue(aniName)


func glitchSwitchSprite(_delta):
  pass

# @override
func tryDieToOffscreenCamera(_delta):
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            setGlobalMemoryOfHasBeenDefeated()
            queue_free()

# @override
func justPressedJump():
  if tongueAniPlayer != null and tongueAniPlayer.is_playing():
    return false
  return .justPressedJump()

# @override
func pressingJump():
  if tongueAniPlayer != null and tongueAniPlayer.is_playing():
    return false
  return .pressingJump()

# @override
func landed():
  .landed()
  behavior_walking = false
  mySprite.max_frames = 2
  mySprite.updateBaseFrame(0, 0)

  if behavior_jumping and is_static and not is_infected:
    behavior_jumping = false

  if is_infected:
    spawnAGlitchParticle()
  
# var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
var glitchParticleBurstRes = preload("res://sceneObjects/GlitchParticleBurst.tscn")
var poisonWaterCubeRes = preload("res://sceneObjects/WaterCubes/PoisonWaterCube.tscn")
func spawnAGlitchParticle():
  var particle = glitchParticleBurstRes.instance()
  level.add_child(particle)
  particle.global_transform.origin.x = self.global_transform.origin.x
  particle.global_transform.origin.y = self.global_transform.origin.y

onready var tongueAniPlayer = get_node("TongueAnimationPlayer") if has_node("TongueAnimationPlayer") else null
onready var degaussAniPlayer = get_node("DegaussAnimationPlayer") if has_node("DegaussAnimationPlayer") else null
# @override
func ouchies(broom_origin):
  is_infected = false
  if not pauseSelf:
    getSmacked(broom_origin)
  last_palette = global.tidepool_palette
  mySprite.get_material_override().set_shader_param("enable_glitch", false)
  mySprite.get_material_override().set_shader_param("target_palette", last_palette)
  if degaussAniPlayer:
    smack_timer = -10
    degaussAniPlayer.play("degauss")
  if dieSound and not dieSound.is_playing():
    dieSound.pitch_scale = rand_range(0.8, 1.2)
    dieSound.play()
  if is_fragile:
    am_i_dying = true
  global.setStaticLevelZoneLevelVar(level, self, self.global_transform.origin)

# @override
func unsmack():
  if degaussAniPlayer and degaussAniPlayer.assigned_animation == "degauss" and degaussAniPlayer.is_playing():
    pass
  else:
    .unsmack()

export var can_jump = true
# @override
func getSmacked(broom_origin = null, silently = false):
  if is_smacked or am_i_dying:
    return false

  .getSmacked(broom_origin, silently)
  if is_infected:
    ouchies(broom_origin)
  if notDieSound and not notDieSound.is_playing():
    notDieSound.pitch_scale = rand_range(0.8, 1.2)
    notDieSound.play()
  # stop the lick
  if is_licker and tongueAniPlayer != null:
    mySprite.flip_h = not mySprite.flip_h
    tongueAniPlayer.stop()
    tongueAniPlayer.clear_queue()
    if gulpin:
      if tongueController and tongueController.hookTarget and tongueController.hookTarget.get_ref() != level.player:
        tongueController.hookTarget.get_ref().getSmacked(broom_origin, silently)
      tongueAniPlayer.play("spitOut")
    else:
      if tongueController != null:
        tongueController.restorePlayer()
        tongueAniPlayer.play("RESET")
    return
  behavior_jumping = can_jump
  behavior_walking = not is_static
  jump_timer = 0
  walk_direction.x = 1
  if level.player.mySprite.flip_h:
    walk_direction.x = -1
    
  # is_static = false
  pauseSelf = true
  on_ground = true

func fallthroughCollisionActivate(friend):
  if not friend.on_ground:
    return # just landed
  # TODO(jaketrower): The downside to this if there are multiple fallthroughSolids a game_mover is "on"
  # is that multiple of them could fight for control here
  # so TODO(jaketrower): Need to make the game_mover call like "fallthroughCollisionClear"
  # if we are on another 
  # ALSO, need to make game_mover call "fallthroughCollisionClear" if we ever
  # like jump, or fall off too...
  if not who_is_standing_on_me.has(friend.name):
    # playBounce("land")
    pass

  var relativePosition = self.global_transform.origin - friend.global_transform.origin
  who_is_standing_on_me[friend.name] = [friend, 0, relativePosition]
  if friend == level.player and not is_static:
    behavior_jumping = true
    behavior_walking = true
    jump_timer = 0

func corruptMyself():
  level.player.visible = true
  is_smacked = true
  am_i_dying = true
  var newCorruptedFrog = poisonWaterCubeRes.instance()
  level.add_child(newCorruptedFrog)
  if not mySprite.flip_h:
    newCorruptedFrog.rotation_degrees.z = -180
  var tempRotationZ = newCorruptedFrog.rotation_degrees.z
  newCorruptedFrog.getSmacked()
  newCorruptedFrog.rotation_degrees.z = tempRotationZ
  newCorruptedFrog.global_transform.origin = self.global_transform.origin
  newCorruptedFrog.global_transform.origin.y += 0.1
  level.player.visible = true
  queue_free()

func fallthroughCollisionClear(exFriend):
  who_is_standing_on_me.erase(exFriend.name)

func moveMyFriends(delta):
  for friend_key in who_is_standing_on_me.keys():
    var friendArray = who_is_standing_on_me[friend_key]
    var friend = friendArray[0]
    var relativePosition = friendArray[2]
    if friend.linear_velocity.y > 0 or friend.should_magic_jump:
      continue
    friend.was_fallthrough_area_collision_triggered = true
    friend.global_transform.origin += self.global_transform.origin - lastPosition
    if not friend.on_ground or friend.global_transform.origin.x < self.global_transform.origin.x + lb or \
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

# @override
func glitchSetSpritesAndCollision():
  mySprite.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y
  if tongueSprite != null:
    tongueSprite.offset.y = sprite_offset_y
    tongueSprite2.offset.y = sprite_offset_y
    tongueSprite3.offset.y = sprite_offset_y
    tongueSprite4.offset.y = sprite_offset_y
