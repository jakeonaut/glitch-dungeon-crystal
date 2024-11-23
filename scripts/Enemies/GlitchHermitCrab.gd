extends "GlitchEnemy.gd"

onready var thudSound = get_node("Sounds/ThudSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
enum CrabState {
    RESPAWN_PREPARE,
    IDLE,
    PREPARE_THROW,
    THROW,
    SCURRY_AWAY,
}
var crab_state = CrabState.IDLE
var opacity = 1.0
var myHermitCrabShell = null
onready var myManager = get_node("..")

func _ready():
    if getMyStaticLevelZoneVar():
        visible = false
        queue_free()
        return

    set_process(true)
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2
    behavior_walking = false

var idle_timer = 0
var idle_time_limit = 5
var MAX_DIST = 2
func _process(delta):
    # ._process(delta) implicit
    if spawn_origin == null:
      spawn_origin = global_transform.origin

    if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
      if not visible:
        myHermitCrabShell = null
      else:
        updateMyHermitCrabShellPos()
    if not visible or is_smacked:
      updateFallthroughSolids()
      return

    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    match crab_state:
      CrabState.RESPAWN_PREPARE:
        behavior_walking = false
        idle_timer = 0
        setAnimationAndChangeStateWhenItEnds("prepare", CrabState.IDLE)
      CrabState.IDLE:
        walk_speed = 1
        setAnimationAndChangeStateWhenItEnds("walk", null)
        myOtherSprite.flip_h = walk_direction.x < 0

        if behavior_walking and (
          global_transform.origin.x >= spawn_origin.x + MAX_DIST or
          global_transform.origin.x <= spawn_origin.x - MAX_DIST):
            if global_transform.origin.x >= spawn_origin.x:
              walk_direction.x = -1
            else:
              walk_direction.x = 1

        idle_timer += (delta*11)
        if idle_timer >= idle_time_limit:
          idle_timer = 0
          idle_time_limit = rand_range(5, 10)
          behavior_walking = not behavior_walking

          var i = randi() % 2
          match i:
            0:
              walk_direction = Vector2(1, 0)
            1:
              walk_direction = Vector2(-1, 0)

      CrabState.PREPARE_THROW:
        setAnimationAndChangeStateWhenItEnds("prepareToThrow", CrabState.THROW)
        behavior_walking = false
      CrabState.THROW:
        setAnimationAndChangeStateWhenItEnds("throwShell", CrabState.SCURRY_AWAY)
        behavior_walking = false
      CrabState.SCURRY_AWAY:
        myOtherSprite.flip_h = level.player.global_transform.origin.x > global_transform.origin.x
        walk_direction.x = 1 if not myOtherSprite.flip_h else -1
        setAnimationAndChangeStateWhenItEnds("walkNaked", null)
        behavior_walking = true
        walk_speed = 8

        opacity = opacity + (0.0 - opacity) * (delta * 5)
        myOtherSprite.material_override.set_shader_param("opacity", opacity)
        if stepify(opacity, 0.1) == 0:
            visible = false
            opacity = 1.0
            myOtherSprite.material_override.set_shader_param("opacity", opacity)

    moveMyFriends(delta)
    lastPosition = self.global_transform.origin

func landed():
  spawn_origin = self.global_transform.origin
  .landed()

func setAnimationAndChangeStateWhenItEnds(aniName, next_state):
  if secretAniPlayer.assigned_animation != aniName:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play(aniName)
  elif not secretAniPlayer.is_playing():
    if next_state != null:
      crab_state = next_state

func getSmacked(broom_origin = null, silently = false):
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  if (broom_origin != null and broom_origin.x <= self.global_transform.origin.x) or (broom_origin == null and not level.player.mySprite.flip_h):
    myOtherSprite.flip_h = false
  elif (broom_origin != null and broom_origin.x > self.global_transform.origin.x) or (broom_origin == null and level.player.mySprite.flip_h):
    myOtherSprite.flip_h = true
  summonHermitCrabShell()
  var hermitCrabShell = myHermitCrabShell.get_ref()
  hermitCrabShell.global_transform.origin.y -= 1
  hermitCrabShell.getSmacked(broom_origin, silently)
  myHermitCrabShell = null
  visible = false
  opacity = 1.0
  myOtherSprite.material_override.set_shader_param("opacity", opacity)
  crab_state = CrabState.SCURRY_AWAY
  return false

func summonHermitCrabShell():
  if myHermitCrabShell != null:
    return
  if myManager.hermitCrabShell.get_ref() != null:
    myHermitCrabShell = weakref(myManager.hermitCrabShell.get_ref())
    myHermitCrabShell.get_ref().visible = true
    myHermitCrabShell.get_ref().secretAniPlayer.stop()
    myHermitCrabShell.get_ref().secretAniPlayer.clear_queue()
    myHermitCrabShell.get_ref().secretAniPlayer.play("RESET")
    updateMyHermitCrabShellPos()

func throwPreparedShell():
  if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
    var direction_vector = Vector2(1 if not myOtherSprite.flip_h else -1, 0)
    myHermitCrabShell.get_ref().tumbleFall(direction_vector, false)
    myHermitCrabShell = null

func updateMyHermitCrabShellPos():
  if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
    myHermitCrabShell.get_ref().global_transform.origin = self.global_transform.origin
    myHermitCrabShell.get_ref().global_transform.origin.y += 1
    myHermitCrabShell.get_ref().myOtherSprite.flip_h = self.myOtherSprite.flip_h

# @override
func actuallyDieToOffscreenCamera(_delta):
  # if is_static_in_level:
  #   setGlobalMemoryOfHasBeenDefeated()
  #   trySpawnACrystal()
  myManager.dieOffscreen()

func tumbleFall(direction_vector, is_corrupted = false):
  if physics_state == PhysicsState.GLITCH_DYING:
    return

  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  summonHermitCrabShell()
  var hermitCrabShell = myHermitCrabShell.get_ref()
  hermitCrabShell.tumbleFall(direction_vector, is_corrupted)
  myHermitCrabShell = null
  visible = false
  opacity = 1.0
  myOtherSprite.material_override.set_shader_param("opacity", opacity)
  crab_state = CrabState.SCURRY_AWAY
  return false

var who_is_standing_on_me = {}
var move_my_friends_time_limit = 10
var lastPosition = Vector3(0, 0, 0)
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