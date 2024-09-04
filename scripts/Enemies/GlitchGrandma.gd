extends "GlitchEnemy.gd"

var summonedBroom = null
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
export var is_static = false
export var has_broom = true
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")
onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var secretAniPlayer = get_node("SecretAniPlayer")
var SWEEP_BUFFER_DIST = 4
var secretMultiBroom = null

enum BehaviorState {
  NORMAL,
  BROOM_WIND_UP,
  SWEEPING
}
var behavior_state = BehaviorState.NORMAL

func _ready():
  mySprite.set_material_override(mySprite.get_material_override().duplicate())

  smallInteractionArea.add_to_group("no_pushems")

func _process(delta):
  if not visible: return

  sprite_offset_y = 0
  spriteYAlignment = 0
  
  glitchSetSpritesAndCollision()
  processBroomRenderLogic(delta)
  processGrandmaBehavior(delta)

func glitchSwitchSprite(_delta):
  pass

# @override
func tryDieToOffscreenCamera():
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

func processGrandmaBehavior(_delta):
  if not isActive():
    return
  
  var x = global_transform.origin.x
  var px = level.player.global_transform.origin.x
  if behavior_state == BehaviorState.NORMAL:
    if glitch_form == GlitchForm.FLOOR:
      if not "walk" in secretAniPlayer.assigned_animation:
        secretAniPlayer.stop()
        secretAniPlayer.play("walk")
        behavior_walking = true
      if px < x + SWEEP_BUFFER_DIST and px > x - SWEEP_BUFFER_DIST:
        behavior_state = BehaviorState.BROOM_WIND_UP
        secretAniPlayer.stop()
        secretAniPlayer.play("broomWindUp")
      elif px > x:
        walk_direction = Vector2(1, 0)
        mySprite.flip_h = false
      elif px < x:
        walk_direction = Vector2(-1, 0)
        mySprite.flip_h = true
  elif behavior_state == BehaviorState.BROOM_WIND_UP:
    behavior_walking = false
    if px > x:
      walk_direction = Vector2(1, 0)
      mySprite.flip_h = false
    elif px < x:
      walk_direction = Vector2(-1, 0)
      mySprite.flip_h = true
    if secretAniPlayer.assigned_animation == "broomWindUp" and not secretAniPlayer.is_playing():
      doBroomAttack()
      behavior_state = BehaviorState.SWEEPING
  elif behavior_state == BehaviorState.SWEEPING:
    behavior_walking = false
    
func doBroomAttack():
  secretAniPlayer.stop()
  secretAniPlayer.play("sweepAttack")
  summonedBroom = summonedBroomRes.instance()
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
  return visible and glitch_form == level.player.glitch_form

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
  var yAddition = .625

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
