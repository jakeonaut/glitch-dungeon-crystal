extends "NPC.gd"

onready var bounceSound = get_node("BounceSound")
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
    # if level.player.nesting_doll_state == global.NestingDoll.BABY:
    if possible_game_mover != null and possible_game_mover == level.player and not level.player.pressingDown():
      getPlayer().camera_target_y_pos = getPlayer().global_transform.origin.y
      var jump_val = 7

      is_smacked = true
      if getPlayer().pressingJump():
        jump_val *= 1.5
        mySprite.material_override.set_shader_param("time_influence", 35)
        mySprite.material_override.set_shader_param("y_div", 2.3)
        mySprite.material_override.set_shader_param("normal_offset", .15)
        smack_timer = smack_time_limit / 4
      else:
        mySprite.material_override.set_shader_param("time_influence", 20)
        mySprite.material_override.set_shader_param("y_div", 1.5)
        mySprite.material_override.set_shader_param("normal_offset", .1)
        smack_timer = smack_time_limit / 3
      if getPlayer().nesting_doll_state == global.NestingDoll.BABY:
        jump_val *= 2
      possible_game_mover.magicJump()
      getPlayer().linear_velocity.y = jump_val
      getPlayer().lv.y = jump_val
      getPlayer().vv = getPlayer().up.dot(getPlayer().lv)
      # getPlayer().physics_vars.applyHalfGrav = true
      # getPlayer().physics_vars.applyHalfGravTimer = 3
      bounceSound.pitch_scale = rand_range(1.5, 2.0)
      bounceSound.play()
      getPlayer().camera_target_y_pos = getPlayer().global_transform.origin.y
