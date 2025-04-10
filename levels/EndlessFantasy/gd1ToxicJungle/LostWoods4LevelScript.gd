extends "../../../scripts/levelScript.gd"

onready var eldestMonkeyNPC = get_node("EldestMonkeyNPC")

# @override
func setUpRoomInitializationOverride():
  if global.memory["baba_yaga_boss"] >= 2:
    eldestMonkeyNPC.queue_free()
