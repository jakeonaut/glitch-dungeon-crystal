extends "../../../scripts/levelScript.gd"


onready var croneNPC = get_node("CroneNPC")

# @override
func setUpRoomInitializationOverride():
  if global.memory["has_seen_highpriestess"]:
    croneNPC.queue_free()