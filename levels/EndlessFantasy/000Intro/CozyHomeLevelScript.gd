extends "../../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
  pass

func _process(delta):
  # ._process(delta) implicit
  player.fall_timer = 0
  global.pauseMoveInput = true