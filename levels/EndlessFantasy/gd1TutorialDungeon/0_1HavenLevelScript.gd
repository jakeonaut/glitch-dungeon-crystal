extends "../../../scripts/levelScript.gd"

onready var door3 = get_node("Door3")
onready var door5 = get_node("Door5")

# @override
func setUpRoomInitializationOverride():
  if global.memory["demo_mode"] > 0:
    door3.queue_free()
    door5.queue_free()