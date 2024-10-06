extends "../../../scripts/levelScript.gd"

onready var door2 = get_node("Door2")
onready var broomUpgradeCrone = get_node("BroomUpgradeCrone")

# @override
func setUpRoomInitializationOverride():
  if global.memory["demo_mode"] > 0:
    # door2.num_keys_unlock = 2
    door2.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"

  if global.memory["priestess"] > 0:
    broomUpgradeCrone.queue_free()