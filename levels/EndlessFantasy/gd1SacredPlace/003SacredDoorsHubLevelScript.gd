extends "../../../scripts/levelScript.gd"

var has_decided = false

# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("roomPath") or not "gd1SacredPlace" in global.memory["roomPath"]:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 999
    has_decided = true
    player.normalGlitch()

func _process(_delta):
  # ._process(delta) implicit
  if not has_decided:
    return

  if global.shouldRenderAsCinematic:
    player.fall_timer = 999
  
  if player.physics_state == player.PhysicsState.COLLAPSED or \
       player.physics_state == player.PhysicsState.CAN_WAKE_UP:
    global.pauseMoveInput = false
    global.shouldRenderAsCinematic = false