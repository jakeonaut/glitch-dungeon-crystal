extends Spatial

onready var hookInteractionArea = get_node("HookInteractionArea")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
var hookTarget = null

func _ready():
  set_process(true)

func _process(delta):
  if not hooked:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
      if hookInteractionArea.overlaps_area(enemy):
        hooked = true
        hookTarget = weakref(enemy.get_node(".."))
        return
  else:
    if hookTarget == null or not hookTarget.get_ref() or hookTarget.get_ref().physics_state == level.player.PhysicsState.GLITCH_DYING:
      hooked = false
      restorePlayer(false)
      hookTarget = null
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

func moveTargetToHook(delta):
  if not hookTarget.get_ref():
    return

  var fishPos = hookTarget.get_ref().global_transform.origin
  var hookPos = hookInteractionArea.global_transform.origin
  hookTarget.get_ref().global_transform.origin = global.moveToward2D(fishPos, hookPos, delta * 15)
  # hookInteractionArea.global_transform.origin.z = fishPos.z - 1

  if hookTarget.get_ref().has_method("ladderUpdateTargetLastGroundedY"):
    hookTarget.get_ref().ladderUpdateTargetLastGroundedY()

func isActive(_debug=false):
  return true

func passiveActivate(_delta, is_player):
  if not hooked and is_player and level.player.canIGetCaught():
    level.clearOtherGrabbers()
    hooked = true
    hookTarget = weakref(level.player)
    level.player.hookSound.play()
    if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
      level.player.aniPlayer.play("hookCaught")
    level.player.pauseAnimation = true
    level.player.should_do_fallthrough_area_collision = false
    level.player.tryClearFallthroughCollisionSolid()
  

func restorePlayer(_got_to_top):
  if hookTarget == null or hookTarget.get_ref() != level.player:
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