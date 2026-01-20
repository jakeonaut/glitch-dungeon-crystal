extends "Enemies/GlitchEnemy.gd"

var gameMoverTarget = null
func _ready():
  # super._ready()
  pass

# @override
func tryDieToOffscreenCamera(_delta):
  pass
  
func moveMyFriends(_delta):
  pass

var is_returning = false
func _process(delta):
  # super._process(delta) implicit?
  if gameMoverTarget == null or gameMoverTarget.get_ref() == null:
    return
  grav = gameMoverTarget.get_ref().grav
  var targetOrigin = gameMoverTarget.get_ref().global_transform.origin

  var zNormalizedOrigin = Vector3(global_transform.origin.x, global_transform.origin.y, targetOrigin.z)
  var dist = zNormalizedOrigin.distance_to(targetOrigin)
  if dist > 8 and not flying_to_target:
    is_returning = true
  
  if is_returning or flying_to_target:
    behavior_walking = false
    behavior_jumping = false
    global_transform.origin = global.moveToward2D(
      global_transform.origin, 
      targetOrigin, 
      delta * 33)
    if dist < 0.1:
      is_returning = false
  else:
    jump_force = dist * 3
    if jump_force < 4:
      jump_force = 4
    walk_speed = dist * 2
    if dist > 3:
      if abs(global_transform.origin.x - targetOrigin.x) > 0.5:
        behavior_walking = true
        if self.global_transform.origin.x > targetOrigin.x:
          walk_direction.x = -1
        else:
          walk_direction.x = 1
      behavior_jumping = true

    elif dist < 0.5:
      behavior_walking = false
      behavior_jumping = false
  
  ignorePhysics = is_returning
  if level.player.glitch_form == global.GlitchForm.FLOOR and \
     (not level.player.truly_on_ground or not self.on_ground) and level.player.on_ground and \
     global_transform.origin.y < targetOrigin.y:
    if dist < 1:
      true_terminal_vel = 1
    else:
      true_terminal_vel = 0
  else:
    true_terminal_vel = level.player.terminal_vel

# @override
func shouldIDoCollisions():
  if gameMoverTarget == null or gameMoverTarget.get_ref() == null:
    should_collide_horizontally = true
    return
  var targetOrigin = gameMoverTarget.get_ref().global_transform.origin
  should_collide_ceil = false
  should_collide_horizontally = false
  should_collide_floor = targetOrigin.y >= self.global_transform.origin.y

# @override
func glitchSetSpritesAndCollision():
  pass

# @override 
func getSmacked(_broom_origin = null, _silently = false, _is_local_broom = false):
  pass

func popFromFollowers():
  var followerIndex = 0
  for i in range(level.followers.size()):
    if level.followers[i].get_ref() == self:
      followerIndex = i
      break
  level.followers.remove(followerIndex)

var flying_to_target = false
func flyToTarget(target):
  if flying_to_target and gameMoverTarget.get_ref() == target:
    return
  gameMoverTarget = weakref(target)
  flying_to_target = true
  is_returning = true
