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
  
func swallowPlayer():
  level.player.tryDieToEnemy(0, true, true, true)
  gulping = false
