extends Spatial


onready var hookInteractionArea = get_node("HookInteractionArea")
onready var lineSprite = get_node("LineSprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
var is_reeled_in = false
export(NodePath) var hookTargetPath = null
var hookTarget = null

var depth = 0
var vv = 0
var acc = 30
var max_speed = 12
var low_speed = 4

func _ready():
  depth = self.global_transform.origin.y - hookInteractionArea.global_transform.origin.y
  if hookTargetPath != null and has_node(hookTargetPath):
    hookTarget = weakref(get_node(hookTargetPath))
    hooked = true
  set_process(true)

func _process(delta):
  var diff = self.global_transform.origin.y - hookInteractionArea.global_transform.origin.y + 1
  lineSprite.global_transform.origin.y = self.global_transform.origin.y - (diff) / 2
  lineSprite.scale.y = (diff - .75) / 2

  if hooked:
    if hookTarget == null or not hookTarget.get_ref() or hookTarget.get_ref().physics_state == level.player.PhysicsState.GLITCH_DYING or hookTarget.get_ref().glitch_form == global.GlitchForm.INVISIBLE:
      hooked = false
      restorePlayer(false)
      hookTarget = null
      is_reeled_in = true
      return

    hookTarget.get_ref().was_fallthrough_area_collision_triggered = false
    hookTarget.get_ref().should_collide_floor = false
    hookTarget.get_ref().can_collide_with_floor = false
    hookTarget.get_ref().fall_timer = 0
    hookTarget.get_ref().on_ground = true
    hookTarget.get_ref().vv = 0
    hookTarget.get_ref().lv.y = 0
    hookTarget.get_ref().linear_velocity.y = 0
    moveTargetToHook(delta)
    if not is_reeled_in:
      reelItIn(delta)

  elif is_reeled_in:
    reelItOut(delta)

func restorePlayer(_got_to_top):
  if hookTarget == null or hookTarget.get_ref() == null:
    return
  var gameMover = hookTarget.get_ref()
  gameMover.should_collide_floor = true # look at me pretending to be safe
  gameMover.can_collide_with_floor = true
  gameMover.pauseAnimation = false
  gameMover.hv = Vector3(0, 0, 0)
  gameMover.dir = Vector3(0.0, 0.0, 0.0)
  gameMover.linear_velocity.x = 0
  gameMover.lv.x = 0
  gameMover.pauseAnimation = false
  if gameMover.physics_state == gameMover.PhysicsState.GLITCH_DYING:
    gameMover.vv = 0
    gameMover.linear_velocity.y = 0
    gameMover.lv.y = 0
    return
  gameMover.physics_state = gameMover.PhysicsState.NORMAL

func moveTargetToHook(delta):
  if hookTarget == null or hookTarget.get_ref() == null:
    return

  var gameMover = hookTarget.get_ref()
  var fishPos = gameMover.global_transform.origin
  var hookPos = hookInteractionArea.global_transform.origin
  gameMover.global_transform.origin = global.moveToward2D(fishPos, hookPos, delta * 15)
  # hookInteractionArea.global_transform.origin.z = fishPos.z - 1

  if gameMover.has_method("ladderUpdateTargetLastGroundedY"):
    gameMover.ladderUpdateTargetLastGroundedY()

func reelItIn(delta):
  if hookTarget == null or hookTarget.get_ref() == null:
    return
  var gameMover = hookTarget.get_ref()
  vv += acc * delta
  if vv >= max_speed:
    vv = max_speed
  hookInteractionArea.global_transform.origin.y += vv * delta
  var jump_val = 10
  gameMover.on_ground = false
  gameMover.linear_velocity.y = jump_val
  gameMover.lv.y = jump_val
  gameMover.vv = gameMover.up.dot(gameMover.lv)
  gameMover.hv = Vector3(0, 0, 0)
  gameMover.linear_velocity.x = 0
  gameMover.lv.x = 0
  if not level.player.reelSound.is_playing():
    level.player.reelSound.play()

  if hookInteractionArea.global_transform.origin.y > self.global_transform.origin.y:
    hookInteractionArea.global_transform.origin.y = self.global_transform.origin.y
    is_reeled_in = true      
    restorePlayer(true)
    level.player.sporeSound.play()

    hooked = false
    hookTarget = null

func reelItOut(delta):
  hookInteractionArea.global_transform.origin.y -= low_speed * delta
  if hookInteractionArea.global_transform.origin.y < self.global_transform.origin.y - depth:
    hookInteractionArea.global_transform.origin.y = self.global_transform.origin.y - depth
    is_reeled_in = false

func isActive(_debug=false):
  return true

func passiveActivate(_delta, is_player):
  if not hooked and not is_reeled_in and is_player and level.player.canIGetCaught():
    level.clearOtherGrabbers(level.player)
    hooked = true
    hookTarget = weakref(level.player)
    level.player.hookSound.play()
    if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
      level.player.aniPlayer.play("hookCaught")
    level.player.pauseAnimation = true
    level.player.was_fallthrough_area_collision_triggered = false
    level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)
  
func otherPassiveActivate(_delta, gameMover):
  if not hooked and not is_reeled_in:
    level.clearOtherGrabbers(gameMover)
    hooked = true
    hookTarget = weakref(gameMover)
    level.player.hookSound.play()
    # if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
    #   level.player.aniPlayer.play("hookCaught")
    gameMover.behavior_walking = false
    gameMover.behavior_was_thrown = false
    gameMover.pauseAnimation = true
    gameMover.physics_state = gameMover.PhysicsState.NORMAL
    gameMover.was_fallthrough_area_collision_triggered = false
    gameMover.tryClearFallthroughCollisionSolid(self.global_transform.origin)
