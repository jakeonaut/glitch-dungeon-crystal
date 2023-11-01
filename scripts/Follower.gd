extends "Enemies/GlitchEnemy.gd"

func _ready():
  # super._ready()
  pass

# @override
func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            actuallyGoBackToPlayer()
            
    var dist = self.global_transform.origin.distance_to(level.player.global_transform.origin)
    if dist > 20:
      actuallyGoBackToPlayer()

func actuallyGoBackToPlayer():
  self.global_transform.origin = level.player.global_transform.origin
  self.lv.y = jump_force
  self.vv = jump_force
  self.linear_velocity.y = jump_force
  walk_direction.x = randi() % 2
  if walk_direction.x == 0: walk_direction.x = -1
  
func moveMyFriends(_delta):
  pass

func _process(_delta):
  # super._process(delta) implicit?
  var dist = self.global_transform.origin.distance_to(level.player.global_transform.origin)
  if dist > 2:
    behavior_walking = true
    behavior_jumping = true
    if self.global_transform.origin.x > level.player.global_transform.origin.x:
      walk_direction.x = -1
    else:
      walk_direction.x = 1
  elif dist < 1:
    behavior_walking = true
    behavior_jumping = true
    if not level.player.mySprite.flip_h:
      walk_direction.x = -1
    else:
      walk_direction.x = 1
  else:
    behavior_walking = false
    behavior_walking = false

func glitchSetSpritesAndCollision():
  pass

# @override 
func getSmacked(broom_origin):
  pass
