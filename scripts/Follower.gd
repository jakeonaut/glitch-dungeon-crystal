extends "Enemies/GlitchEnemy.gd"

var gameMoverTarget = null
func _ready():
  # super._ready()
  pass

# @override
func tryDieToOffscreenCamera():
  pass
  
func moveMyFriends(_delta):
  pass

var is_returning = false
func _process(delta):
  # super._process(delta) implicit?
  if gameMoverTarget == null or gameMoverTarget.get_ref() == null:
    return
  var targetOrigin = gameMoverTarget.get_ref().global_transform.origin
  var targetSprite = gameMoverTarget.get_ref().mySprite

  var dist = self.global_transform.origin.distance_to(targetOrigin)
  if dist > 8:
    is_returning = true
    behavior_walking = false
    behavior_jumping = false
  
  if is_returning:
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
      behavior_walking = true
      behavior_jumping = true
      if self.global_transform.origin.x > targetOrigin.x:
        walk_direction.x = -1
      else:
        walk_direction.x = 1
    elif dist < 0.1:
      behavior_walking = true
      behavior_jumping = true
      if not targetSprite.flip_h:
        walk_direction.x = -1
      else:
        walk_direction.x = 1
    else:
      behavior_walking = false
      behavior_jumping = false
  
  ignorePhysics = is_returning
  if level.player.glitch_form == global.GlitchForm.FLOOR and not level.player.truly_on_ground and level.player.on_ground and global_transform.origin.y < targetOrigin.y:
    if dist < 1:
      true_terminal_vel = 1
    else:
      true_terminal_vel = 0
  else:
    true_terminal_vel = 32

# @override
func shouldIDoCollisions():
  if gameMoverTarget == null or gameMoverTarget.get_ref() == null:
    return
  var targetOrigin = gameMoverTarget.get_ref().global_transform.origin
  should_collide_ceil = false
  should_collide_horizontally = false
  should_collide_floor = targetOrigin.y >= self.global_transform.origin.y

# @override
func glitchSetSpritesAndCollision():
  pass

# @override 
func getSmacked(_broom_origin):
  pass
