extends "../../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
  global.pauseMoveInput = true
  global.shouldRenderAsCinematic = true

var glitch_death_timer_fake = 0
var has_activated = false
var has_level_started = false
func _process(delta):
  levelTiles.randomize_num = 999
  # ._process(delta) implicit
  player.fall_timer = 0
  global.canChangeSongPitch = false
  # if not has_activated and player.global_transform.origin.y < -39:
  #   has_activated = true
  #   player.global_transform.origin.z = -10
  #   player.tryDieToEnemy(delta, true, true, true)
  #   player.global_transform.origin.z = 0
    # player.grav = 0
    # player.vv = 0
    # player.linear_velocity.y = 0
    # player.lv.y = 0


onready var door = get_node("Door")

# @override
func overrideLevelRespawnEvent():
  if has_level_started:
    door.goThroughDoor()
  has_level_started = true