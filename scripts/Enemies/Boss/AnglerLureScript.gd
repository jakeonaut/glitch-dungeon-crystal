extends Spatial

onready var anglerFish = weakref(get_node("../.."))
onready var hookInteractionArea = get_node("HookInteractionArea")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
var hookTarget = null

# should we um just inherit from FishingRod.gd like AnglerFishingRod.gd does?
func _ready():
  set_process(true)

func _process(delta):
  if anglerFish == null or anglerFish.get_ref() == null:
    return false
    
  if hooked and hookTarget != null and hookTarget.get_ref() != null:
    var prey = hookTarget.get_ref()
    if prey == anglerFish.get_ref() or prey == anglerFish.get_ref().weakPointContainer:
      hooked = false
      hookTarget = null

  if not hooked and isActive():
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemyArea in enemies:
      var enemy = enemyArea.get_node("..")
      if enemy == anglerFish.get_ref() or enemy == anglerFish.get_ref().weakPointContainer:
        continue
      if hookInteractionArea.overlaps_area(enemyArea):
        hooked = true
        hookTarget = weakref(enemy)
        return
  else:
    if hookTarget == null or not hookTarget.get_ref() or hookTarget.get_ref().physics_state == level.player.PhysicsState.GLITCH_DYING or hookTarget.get_ref().glitch_form == global.GlitchForm.INVISIBLE:
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
  hookTarget.get_ref().global_transform.origin = global.moveToward2D(fishPos, hookPos, delta * 45)
  # hookInteractionArea.global_transform.origin.z = fishPos.z - 1

  if hookTarget.get_ref().has_method("ladderUpdateTargetLastGroundedY"):
    hookTarget.get_ref().ladderUpdateTargetLastGroundedY()

func isActive(_debug=false):
  return true

func activate(is_player):
  if anglerFish == null or anglerFish.get_ref() == null:
    return false

  if anglerFish.get_ref().boss_phase != anglerFish.get_ref().BossPhase.LYING_IN_WAIT:
    return false
  anglerFish.get_ref().startBossFight(is_player)

func passiveActivate(_delta, is_player):
  if anglerFish == null or anglerFish.get_ref() == null:
    return false

  if anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.LYING_IN_WAIT:
    anglerFish.get_ref().startBossFight(true)
    return

  if not (
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CAST_LURE or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_LEFT or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_RIGHT or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_MIDDLE
  ):
    return

  if hooked or not is_player or not level.player.canIGetCaught():
    return
  
  level.clearOtherGrabbers(level.player)
  hooked = true
  hookTarget = weakref(level.player)
  level.player.hookSound.play()
  if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
    level.player.aniPlayer.play("hookCaught")
  level.player.pauseAnimation = true
  level.player.should_do_fallthrough_area_collision = false
  level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)

func otherPassiveActivate(_delta, gameMover):
  if anglerFish == null or anglerFish.get_ref() == null:
    return false

  if anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.LYING_IN_WAIT:
    anglerFish.get_ref().startBossFight(true)
    return

  if not (
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CAST_LURE or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_LEFT or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_RIGHT or \
      anglerFish.get_ref().boss_phase == anglerFish.get_ref().BossPhase.CLAW_MACHINE_FISHING_MIDDLE
  ):
    return

  if hooked:
    return
  
  level.clearOtherGrabbers(gameMover)
  hooked = true
  hookTarget = weakref(level.player)
  level.player.hookSound.play()
  if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
    level.player.aniPlayer.play("hookCaught")
  level.player.pauseAnimation = true
  level.player.should_do_fallthrough_area_collision = false
  level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)
  

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
