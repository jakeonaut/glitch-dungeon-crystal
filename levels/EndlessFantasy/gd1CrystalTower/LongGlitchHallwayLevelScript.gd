extends "../../../scripts/levelScript.gd"

onready var door2 = get_node("Door2")

# @override
func setUpRoomInitializationOverride():
  pass
  # if global.memory["demo_mode"] > 0:
  #   door2.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"