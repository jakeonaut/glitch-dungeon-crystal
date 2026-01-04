extends "../scripts/NPC.gd"

func _ready():
  if global.memory["babushka_cat_story_hook"] > 2:
    queue_free()

# @override
func activate(is_player, is_local_broom = false):
  var jump_val = 10.0
  linear_velocity.y = jump_val
  lv.y = jump_val
  vv = up.dot(lv)
  return .activate(is_player, is_local_broom)