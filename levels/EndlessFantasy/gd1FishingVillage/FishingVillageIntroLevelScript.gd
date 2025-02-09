extends "../../../scripts/levelScript.gd"

onready var bigFishNPC = get_node("BigFishNPC")

# @override
func setUpRoomInitializationOverride():
  if global.memory["angler_seaman_boss"] >= 2:
    bigFishNPC.queue_free()
