extends "GlitchEnemy.gd"

onready var fishingRod = get_node("FishingRod")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var am_revealed = false
var i_caught_player = false
var was_player_caught = false
func _ready():
  set_process(true)

func _process(_delta):
  i_caught_player = fishingRod.hookTarget != null and fishingRod.hookTarget.get_ref() == level.player
  fishingRod.max_speed = 6

  if not am_revealed:
    if i_caught_player and not was_player_caught:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("reveal")
      am_revealed = true
  else:
    if i_caught_player and not was_player_caught:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("openMouth")

  was_player_caught = i_caught_player

func fallthroughCollisionActivate(friend):
  if friend == level.player:
    passiveActivate(0, true)

var origin_before_teleportation = null
# @override
func unsmack():
  .unsmack()
  if origin_before_teleportation != null:
    origin_before_teleportation = self.global_transform.origin
  self.global_transform.origin = level.player.global_transform.origin
  .passiveActivate(0, true)

# @override
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently)

var gulping = false
func passiveActivate(_delta, is_player):
  if gulping:
    return
  if is_player and level.player.canIGetCaught():
    am_revealed = true
    gulping = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("digest")
    level.player.visible = false
    level.player.physics_state = level.player.PhysicsState.IGNORE_PHYSICS
  elif origin_before_teleportation != null:
    self.global_transform.origin = origin_before_teleportation
  
func swallowPlayer():
  if level.player.malware_infected:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("corrupt")
  else:
    level.player.tryDieToEnemy(0, true, true, true)
    gulping = false
    if origin_before_teleportation != null:
      self.global_transform.origin = origin_before_teleportation

func getCorruptedAndDie():
  fishingRod.restorePlayer(false)
  level.player.visible = true
  level.player.physics_state = level.player.PhysicsState.NORMAL
  level.player.magicJump()
  queue_free()
