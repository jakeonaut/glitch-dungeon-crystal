extends "../FishingRod.gd"

onready var anglerFish = get_node("..")

# @override
func restorePlayer(got_to_top):
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
  if got_to_top and gameMover.has_method("tumbleFall"):
    gameMover.tumbleFall(Vector2(-1 if anglerFish.mySprite.flip_h else 1, 0))
