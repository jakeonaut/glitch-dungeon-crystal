extends "../../../scripts/levelScript.gd"

onready var NPC = get_node("NPC")

var has_updated = false

# @override
func _process(_delta):
  if global.memory["broom"] and not has_updated:
    NPC.textBoxContainer.bbText = "what is this strange\ndust... could ya\nsweep up with [X]?"
    NPC.textBoxContainer.setVars()
    NPC.textBox.has_been_shown = false
    has_updated = true
