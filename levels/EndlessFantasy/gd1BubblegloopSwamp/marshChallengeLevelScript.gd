extends "../../../scripts/levelScript.gd"

onready var door2 = get_node("Door2")

# @override
func setUpRoomInitializationOverride():
  if global.memory["demo_mode"] > 0:
    door2.num_keys_unlock = 999
    door2.is_locked = true
    door2.key_type = global.KeyItem.DEMO
    door2.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"
    door2.animationPlayer.stop()
    door2.animationPlayer.clear_queue()
    door2.queueLockAnimation()