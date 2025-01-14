extends Spatial


onready var frog = get_node("..")
onready var tongueAniPlayer = get_node("../TongueAnimationPlayer")
onready var tongueCollisionShape = get_node("TongueArea/CollisionShape")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
export(NodePath) var hookTargetPath = null
var hookTarget = null

var depth = 0
var vv = 0
var acc = 30
var max_speed = 12
var low_speed = 4

func _ready():
  depth = self.global_transform.origin.y - tongueCollisionShape.global_transform.origin.y
  if hookTargetPath != null and has_node(hookTargetPath):
    hookTarget = weakref(get_node(hookTargetPath))
    hooked = true
  set_process(true)

func _process(delta):
  if hooked:
    if hookTarget == null or not hookTarget.get_ref() or hookTarget.get_ref().physics_state == level.player.PhysicsState.GLITCH_DYING:
      restorePlayer()
      frog.unqueueGulpAnimation()
      hooked = false
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
    reelItIn(delta)
    # let frog & gulping take care of it
    # if not tongueCollisionShape.visible:
      # restorePlayer()

func restorePlayer():
  hooked = false
  if not hookTarget or not hookTarget.get_ref():
    hookTarget = null
    return
  var gameMover = hookTarget.get_ref()
  gameMover.should_collide_floor = true
  gameMover.can_collide_with_floor = true
  gameMover.pauseAnimation = false
  gameMover.on_ground = false
  gameMover.vv = 0
  gameMover.linear_velocity.y = 0
  gameMover.lv.y = 0
  
  var jump_val = 5
  gameMover.vv = jump_val
  gameMover.linear_velocity.y = jump_val
  gameMover.lv.y = jump_val
  hookTarget = null
  if gameMover.physics_state == gameMover.PhysicsState.GLITCH_DYING:
    gameMover.hv = Vector3(0, 0, 0)
    gameMover.dir = Vector3(0.0, 0.0, 0.0)
    gameMover.linear_velocity.x = 0
    gameMover.lv.x = 0

func moveTargetToHook(delta):
  if not hookTarget or not hookTarget.get_ref():
    return

  var fishPos = hookTarget.get_ref().global_transform.origin
  var hookPos = tongueCollisionShape.global_transform.origin
  hookTarget.get_ref().global_transform.origin = global.moveToward2D(fishPos, hookPos, delta * 15)
  tongueCollisionShape.global_transform.origin.z = fishPos.z - 1

  if hookTarget.get_ref().has_method("ladderUpdateTargetLastGroundedY"):
    hookTarget.get_ref().ladderUpdateTargetLastGroundedY()

func reelItIn(_delta):
  if not hookTarget or not hookTarget.get_ref():
    return
    
  var gameMover = hookTarget.get_ref()
  gameMover.on_ground = false
  gameMover.vv = 0
  gameMover.linear_velocity.y = 0
  gameMover.lv.y = 0
  gameMover.hv = Vector3(0, 0, 0)
  gameMover.dir = Vector3(0.0, 0.0, 0.0)
  gameMover.linear_velocity.x = 0
  gameMover.lv.x = 0

func isActive(_debug=false):
  return tongueCollisionShape.visible

func passiveActivate(_delta, is_player):
  if not hooked and is_player and level.player.canIGetCaught():
    level.clearOtherGrabbers(level.player)
    hooked = true
    hookTarget = weakref(level.player)
    level.player.hookSound.play()
    level.player.aniPlayer.play("hookCaught")
    level.player.pauseAnimation = true
    level.player.was_fallthrough_area_collision_triggered = false
    level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)

    frog.queueGulpAnimation()
  
func otherPassiveActivate(_delta, gameMover):
  if gameMover.is_extra_bouncy:
    return
  if not hooked:
    level.clearOtherGrabbers(gameMover)
    hooked = true
    hookTarget = weakref(gameMover)
    level.player.hookSound.play()
    gameMover.pauseAnimation = true
    gameMover.was_fallthrough_area_collision_triggered = false
    gameMover.tryClearFallthroughCollisionSolid(self.global_transform.origin)

    frog.queueGulpAnimation()
