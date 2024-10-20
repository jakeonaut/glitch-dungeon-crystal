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
    if hookTarget == null or not hookTarget.get_ref() or hookTarget.get_ref().physics_state == level.player.PhysicsState.GLITCH_DYING:
      hooked = false
      restorePlayer(false)
      hookTarget = null
      is_reeled_in = true
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
    if not is_reeled_in:
      reelItIn(delta)

  elif is_reeled_in:
    reelItOut(delta)

func restorePlayer(_got_to_top):
  if hookTarget == null:
    return
  hookTarget.get_ref().should_collide_floor = true # look at me pretending to be safe
  hookTarget.get_ref().can_collide_with_floor = true
  hookTarget.get_ref().pauseAnimation = false
  level.player.hv = Vector3(0, 0, 0)
  level.player.dir = Vector3(0.0, 0.0, 0.0)
  level.player.linear_velocity.x = 0
  level.player.lv.x = 0
  level.player.pauseAnimation = false
  if level.player.physics_state == level.player.PhysicsState.GLITCH_DYING:
    level.player.vv = 0
    level.player.linear_velocity.y = 0
    level.player.lv.y = 0
    return
  level.player.physics_state = level.player.PhysicsState.NORMAL

func moveTargetToHook(delta):
  if not hookTarget.get_ref():
    return

  var fishPos = hookTarget.get_ref().global_transform.origin
  var hookPos = hookInteractionArea.global_transform.origin
  hookTarget.get_ref().global_transform.origin = global.moveToward2D(fishPos, hookPos, delta * 15)
  # hookInteractionArea.global_transform.origin.z = fishPos.z - 1

  if hookTarget.get_ref().has_method("ladderUpdateTargetLastGroundedY"):
    hookTarget.get_ref().ladderUpdateTargetLastGroundedY()

func reelItIn(delta):
  vv += acc * delta
  if vv >= max_speed:
    vv = max_speed
  hookInteractionArea.global_transform.origin.y += vv * delta
  if hookTarget.get_ref() == level.player:
    var jump_val = 10
    level.player.on_ground = false
    level.player.vv = jump_val
    level.player.linear_velocity.y = jump_val
    level.player.lv.y = jump_val
    level.player.hv = Vector3(0, 0, 0)
    level.player.linear_velocity.x = 0
    level.player.lv.x = 0
    if not level.player.reelSound.is_playing():
      level.player.reelSound.play()

  if hookInteractionArea.global_transform.origin.y > self.global_transform.origin.y:
    hookInteractionArea.global_transform.origin.y = self.global_transform.origin.y
    is_reeled_in = true      
    if hookTarget.get_ref() == level.player:
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
    level.clearOtherGrabbers()
    hooked = true
    hookTarget = weakref(level.player)
    level.player.hookSound.play()
    if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
      level.player.aniPlayer.play("hookCaught")
    level.player.pauseAnimation = true
    level.player.should_do_fallthrough_area_collision = false
    level.player.tryClearFallthroughCollisionSolid()
  
