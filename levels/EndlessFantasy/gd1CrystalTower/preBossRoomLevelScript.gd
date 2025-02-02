extends "../../../scripts/levelScript.gd"


onready var door2 = get_node("Door2")
onready var babushkaCat = get_node("BabushkaCat")

# @override
func setUpRoomInitializationOverride():
  # if global.memory.has("spellbookPage"):
  #   if door2.is_locked:
  #     door2.animationPlayer.clear_queue()
  #     door2.animationPlayer.stop()
  #     door2.animationPlayer.play("doorOpen")
  #     door2.is_locked = false
  # else:
  #   if not door2.is_locked:
  #     door2.animationPlayer.clear_queue()
  #     door2.animationPlayer.stop()
  #     door2.animationPlayer.play("locked")
  #     door2.is_locked = true
  if global.memory["glitch_world"] > 0:
    babushkaCat.global_transform.origin.x = -1.035
    babushkaCat.global_transform.origin.y = 7.041