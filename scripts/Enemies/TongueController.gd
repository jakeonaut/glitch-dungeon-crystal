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
      return
    elif hookTarget.get_ref() == level.player:
      pass

    hookTarget.get_ref().should_do_fallthrough_area_collision = false
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
  if not hookTarget or not hookTarget.get_ref():
    return
  hooked = false
  hookTarget.get_ref().should_collide_floor = true
  hookTarget.get_ref().can_collide_with_floor = true
  hookTarget.get_ref().pauseAnimation = false
  level.player.on_ground = false
  level.player.vv = 0
  level.player.linear_velocity.y = 0
  level.player.lv.y = 0
  
  var jump_val = 5
  level.player.vv = jump_val
  level.player.linear_velocity.y = jump_val
  level.player.lv.y = jump_val
  hookTarget = null
  if level.player.physics_state == level.player.PhysicsState.GLITCH_DYING:
    level.player.hv = Vector3(0, 0, 0)
    level.player.dir = Vector3(0.0, 0.0, 0.0)
    level.player.linear_velocity.x = 0
    level.player.lv.x = 0

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
    
  if hookTarget.get_ref() == level.player:
    level.player.on_ground = false
    level.player.vv = 0
    level.player.linear_velocity.y = 0
    level.player.lv.y = 0
    level.player.hv = Vector3(0, 0, 0)
    level.player.dir = Vector3(0.0, 0.0, 0.0)
    level.player.linear_velocity.x = 0
    level.player.lv.x = 0

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
    level.player.should_do_fallthrough_area_collision = false
    level.player.tryClearFallthroughCollisionSolid()

    frog.queueGulpAnimation()
  
