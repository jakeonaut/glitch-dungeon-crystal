extends "BasicFrogEnemy.gd"

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
            
    # var dist = self.global_transform.origin.distance_to(level.player.global_transform.origin)
    # if dist > 20:
    #   actuallyGoBackToPlayer()

func actuallyGoBackToPlayer():
  self.global_transform.origin = level.player.global_transform.origin
  self.lv.y = jump_force
  self.vv = jump_force
  self.linear_velocity.y = jump_force
  walk_direction.x = randi() % 2
  if walk_direction.x == 0: walk_direction.x = -1
  
func moveMyFriends(_delta):
  pass

var am_i_spinning = false
var tadpole_index = 0
var num_tadpoles = 1
var is_evolved = false
var spinTarget = null
func startSpinning(tadpole_index_, num_tadpoles_, target, immediately_evolve = false):
  spinTarget = target
  am_i_spinning = true
  stopMovement()
  self.tadpole_index = tadpole_index_
  self.num_tadpoles = num_tadpoles_
  walk_direction = Vector2(0, 0)
  aniPlayer = null
  grav = 0
  unsmack()
  mySprite.should_animate = true
  mySprite.updateBaseFrame(0, 0)
  if immediately_evolve:
    evolve_timer = evolve_time_limit
    is_evolved = true
    mySprite.visible = false
    myOtherSprite.visible = true
  else:
    evolve_time_limit = 80 + (tadpole_index_ * 5)
  
func stopMovement():
  is_smacked = true
  smack_timer = 0
  pauseSelf = true
  behavior_jumping = false
  behavior_walking = false

var evolve_timer = 0
var evolve_time_limit = 80
func _process(delta):
  # super._process(delta) implicit?
  if am_i_spinning:
    stopMovement()

    var pos = global_transform.origin
    var targetPos = spinTarget.global_transform.origin
    global_transform.origin = moveToward2D(pos, targetPos, delta * 5)

    var mySpritePos = mySprite.transform.origin
    mySprite.transform.origin.y = moveToward2D(mySpritePos, Vector3(0, 4, 0), delta * 1).y
    myOtherSprite.global_transform.origin = mySprite.global_transform.origin

    self.rotation.z -= (delta)
    mySprite.rotation.z = -self.rotation.z
    myOtherSprite.rotation.z = -self.rotation.z

    if evolve_timer < evolve_time_limit:
      evolve_timer += (delta*11)
      if evolve_timer >= evolve_time_limit:
        is_evolved = true
        dieSound.play()
        mySprite.visible = false
        myOtherSprite.visible = true

# @override
func alignMySprite():
  if am_i_spinning:
    return
  .alignMySprite()

func glitchSetSpritesAndCollision():
  pass

var can_be_smacked = true
# @override 
func getSmacked(broom_origin, silently = false):
  if not can_be_smacked:
    return
  .getSmacked(broom_origin, silently)
