extends "../FishingRod.gd"

# @override
func restorePlayer(got_to_top):
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