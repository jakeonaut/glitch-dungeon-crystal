extends "../../../scripts/levelScript.gd"


onready var door2 = get_node("Door2")

# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    if door2.is_locked:
      door2.animationPlayer.clear_queue()
      door2.animationPlayer.stop()
      door2.animationPlayer.play("doorOpen")
      door2.is_locked = false
  else:
    if not door2.is_locked:
      door2.animationPlayer.clear_queue()
      door2.animationPlayer.stop()
      door2.animationPlayer.play("locked")
      door2.is_locked = true
