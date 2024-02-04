extends "../NPC.gd"

# @override
func getSmacked(broom_origin):
  mySprite.max_frames = 3
  .getSmacked(broom_origin)

# @override
func passiveActivate(delta, is_player):
  mySprite.max_frames = 3
  .passiveActivate(delta, is_player)