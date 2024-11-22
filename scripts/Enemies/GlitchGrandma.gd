extends "GlitchEnemy.gd"

var summonedBroom = null
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
export var is_static = false
export var has_broom = true
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")
onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var secretAniPlayer = get_node("SecretAniPlayer")
var SWEEP_BUFFER_DIST = 4
var secretMultiBroom = null
var has_sweeped_glitch = false

enum BehaviorState {
  NORMAL,
  BROOM_WIND_UP,
  SWEEPING
}
var behavior_state = BehaviorState.NORMAL

func _ready():
  mySprite.set_material_override(mySprite.get_material_override().duplicate())

  smallInteractionArea.add_to_group("no_pushems")
  yield(TempTimer.idle_frame(self), "timeout")
  updateColor()

func _process(delta):
  if not visible or am_i_dying: return
  
  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL and global.userSettings["colorblindMode"]
  if glitch_form == global.GlitchForm.FEATHER:
    spellbookGlitchSprite.frame = 0
  elif glitch_form == global.GlitchForm.FLOOR:
    spellbookGlitchSprite.frame = 1
  elif glitch_form == global.GlitchForm.LADDER:
    spellbookGlitchSprite.frame = 2
  elif glitch_form == global.GlitchForm.INVISIBLE:
    spellbookGlitchSprite.frame = 3
  glitchSetSpritesAndCollision()
  processBroomRenderLogic(delta)
  processGrandmaBehavior(delta)

func glitchSwitchSprite(_delta):
  pass

func reallyDie():
  level.summonSmokeClouds(global_transform.origin, 3, true, true)
  queue_free()

# @override
func tryDieToOffscreenCamera(_delta):
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            setGlobalMemoryOfHasBeenDefeated()
            queue_free()

# @override
func processGlitchFormGlitchiness():
  pass

# @override
func pressingDown():
  return level.player.pressingDown()

# @override
func justPressedDown():
  return level.player.justPressedDown()

# @override
func processWallLadderWalking(delta):
  vv = walk_speed * 1.1
  behavior_walking = true
  walk_direction = Vector2(0, 1)

func processNotWallLadderWalking(delta):
  pass

# @override
func shouldIDoCollisions():
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

func processGrandmaBehavior(_delta):
  if not isActive() or global.pauseGame:
    return

  if glitch_form == global.GlitchForm.INVISIBLE:
    unenemize()

  if behavior_state == BehaviorState.NORMAL:
    if level.player.pressingMoveLeft():
      walk_direction = Vector2(1, 0)
      mySprite.flip_h = false
    elif level.player.pressingMoveRight():
      walk_direction = Vector2(-1, 0)
      mySprite.flip_h = true
    else:
      walk_direction = Vector2(0, 0)
    behavior_walking = walk_direction.x != 0
    if behavior_walking and on_ground and not "walk" in secretAniPlayer.assigned_animation:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("walk")
    elif not behavior_walking and on_ground and not "stand" in secretAniPlayer.assigned_animation:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("walk")

    if level.player.pressingJump():
      behavior_jumping = true
      if on_ground and not "jump" in secretAniPlayer.assigned_animation:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("jumpStart")
        secretAniPlayer.queue("jump")
    else:
      behavior_jumping = false
    if not on_ground and vv < 0 and not "fall" in secretAniPlayer.assigned_animation:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("fall")
    
    if Input.is_action_just_pressed("sub_action_button"):
      doBroomAttack()
      behavior_state = BehaviorState.SWEEPING
      # behavior_state = BehaviorState.BROOM_WIND_UP
      # secretAniPlayer.stop()
      # secretAniPlayer.clear_queue()
      # secretAniPlayer.play("broomWindUp")

  elif behavior_state == BehaviorState.BROOM_WIND_UP:
    behavior_walking = false
    behavior_jumping = false
    if level.player.pressingMoveRight():
      walk_direction = Vector2(-1, 0)
      mySprite.flip_h = true
    elif level.player.pressingMoveLeft():
      walk_direction = Vector2(1, 0)
      mySprite.flip_h = false
    if secretAniPlayer.assigned_animation == "broomWindUp" and not secretAniPlayer.is_playing():
      doBroomAttack()
      behavior_state = BehaviorState.SWEEPING
  elif behavior_state == BehaviorState.SWEEPING:
    behavior_walking = false
    behavior_jumping = false
    
func doBroomAttack():
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  secretAniPlayer.play("sweepAttack")
  summonedBroom = summonedBroomRes.instance()
  summonedBroom.scale = Vector3(1.5, 1.5, 1)
  summonedBroom.is_evil = true
  level.add_child(summonedBroom)
  summonedBroom.my_broom_owner = self
  adjustSummonedBroomSpritePosition()

func broomStop():
  if summonedBroom != null:
    summonedBroom.queue_free()
  summonedBroom = null
  pauseAnimation = false
  global.pauseMoveInput = false
  if linear_velocity.y < 0:
    linear_velocity.y = 0
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  if on_ground:
    secretAniPlayer.queue("stand")
  else:
    secretAniPlayer.queue("fall")
  behavior_state = BehaviorState.NORMAL

# @override ?
func isActive(_debug=false):
  return visible and summonedBroom == null # and glitch_form == level.player.glitch_form

# @override ?
func passiveActivate(_delta, is_player):
  if not is_player:
    # TODO(jaketrower): clone GlitchEnemies too
    return

  # level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
  # queue_free()

# var broom_flip_h = false
func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.translation.y += 0.2
  broomSpriteVisible.scale = broomSpriteAnimated.scale
  broomSpriteVisible.flip_h = false
  broomSpriteVisible.material_override.set_shader_param("target_palette", global.player_red_palette)
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1
  if physics_state == PhysicsState.OCCUPIED:
    broomSpriteVisible.visible = false
  elif summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif has_broom:
    broomSpriteVisible.visible = true
  else:
    broomSpriteVisible.visible = false

func adjustSummonedBroomSpritePosition():
  var xAddition = .875
  var yAddition = 0.625

  broomSpriteVisible.visible = false
  if mySprite.flip_h:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x - xAddition
    summonedBroom.rotation_degrees = Vector3(0, 180, 0)
  else:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x + xAddition
    summonedBroom.rotation_degrees = Vector3(0, 0, 0)

  if self.grav < 0:
    summonedBroom.rotation_degrees.x = 180
    yAddition *= -1
    # yAddition -= 3.146
  else:
    summonedBroom.rotation_degrees.x = 0

  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + yAddition
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func isHoldingMultiBroom():
  return false

func updateColor():
  var sprite_palette = global.grey_player_palette
  if glitch_form == global.GlitchForm.FLOOR:
    sprite_palette = global.player_red_palette
  elif glitch_form == global.GlitchForm.LADDER:
    sprite_palette = global.yellow_player_palette
  elif glitch_form == global.GlitchForm.FEATHER:
    sprite_palette = global.green_dungeon_palette
  elif glitch_form == global.GlitchForm.INVISIBLE:
    sprite_palette = global.black_player_palette
  elif glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    sprite_palette = global.white_player_palette
  mySprite.material_override.set_shader_param("target_palette", sprite_palette)

func glitchTickle():
  return

        
# @override
func ouchies(broom_origin):
  .ouchies_base(broom_origin)
  if am_i_dying or not visible: return
  unenemize()
      
  am_i_dying = true
  grav = 0
  if summonedBroom:
    broomStop()
  summonFallenBroom(broom_origin)
  secretAniPlayer.stop()
  secretAniPlayer.play("die")
  
var teleport_to = null
var teleport_to_origin = null
func summonFallenBroom(_broom_origin):
  has_broom = false
  broomSpriteVisible.visible = false
  var fallenBroom = fallenBroomRes.instance()
  level.add_child(fallenBroom)
  fallenBroom.should_die_on_land = true
  fallenBroom.should_return = false
  fallenBroom.global_transform.origin = self.global_transform.origin
  fallenBroom.global_transform.origin.x += -1 if mySprite.flip_h else 1

  var which_direction = 1
  if level.player.global_transform.origin.x > global_transform.origin.x:
    which_direction = -1
  fallenBroom.walk_direction = Vector2(which_direction, 0)

  if fallenBroom.walk_direction.x < 0:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
  else:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")

# @override
func iJustPressedDown():
  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground:
    .iJustPressedDown() # super
    return

  on_ground = false
  should_do_fallthrough_area_collision = false
  tryClearFallthroughCollisionSolid()

# @override
func unenemize():
  if smallInteractionArea.is_in_group("enemies"):
    smallInteractionArea.remove_from_group("enemies")