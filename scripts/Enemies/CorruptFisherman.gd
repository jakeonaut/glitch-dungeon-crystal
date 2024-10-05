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

  if not i_caught_player and was_player_caught:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("digest")

  was_player_caught = i_caught_player

  
func swallowPlayer():
  pass

