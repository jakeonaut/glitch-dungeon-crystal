extends "../../../scripts/levelScript.gd"

onready var NPC = get_node("NPC")

var has_updated = false

# @override
func setUpRoomInitializationOverride():
  if global.memory["broom"] and not has_updated:
    NPC.textBoxContainer.bbText = "thank ye dearie.\nsweep up with [X]"
    NPC.textBoxContainer.setVars()
    NPC.textBox.has_been_shown = false
    has_updated = true
