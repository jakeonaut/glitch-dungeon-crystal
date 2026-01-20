extends "NPC.gd"

onready var bounceSound = get_node("BounceSound")
onready var bounceLandSound = get_node("BounceLandSound")
var had_already_been_collided = false
var is_being_collided = false
var should_wiggle = false
var wiggle_timer = 0
var wiggle_time_limit = 2
var spore_origin = Vector3(0, 0, 0)

var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

func fallthroughCollisionActivate(possible_game_mover):
  if not possible_game_mover.was_on_ground:
    if possible_game_mover == level.player and not level.player.pressingDown():
      bounceLandSound.play()
      wiggle()
      smack_timer = 3 * smack_time_limit / 4

func fallthroughCollisionClear(exFriend, was_it_a_jump = false):
  var is_mini = true
  if was_it_a_jump:
    wiggle()
    if exFriend == getPlayer():
      getPlayer().camera_target_y_pos = getPlayer().global_transform.origin.y
      if is_mini:
          exFriend.short_lived_vv_multiplier = 1.2
      else:
          exFriend.short_lived_vv_multiplier = 1.75
      exFriend.short_lived_vv_multiplier_timer = 0
      exFriend.short_lived_vv_multiplier_time_limit = 0.5
      if exFriend.glitch_form == global.GlitchForm.FEATHER:
          exFriend.short_lived_vv_multiplier_time_limit = 5.0
          exFriend.short_lived_vv_multiplier *= 0.75
      if is_mini:
          bounceSound.pitch_scale = rand_range(1.5, 2.0)
      else:
          bounceSound.pitch_scale = rand_range(0.8, 1.5)
      bounceSound.play()
      getPlayer().camera_target_y_pos = getPlayer().global_transform.origin.y

func wiggle():
  getSmacked(null, true, false)
  smack_timer = smack_time_limit / 2
