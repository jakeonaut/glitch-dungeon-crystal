extends "../../../scripts/levelScript.gd"

onready var NPC = self.get_node("NPC")

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass


var has_done_my_power = false
# @override
func _process(_delta):
  if not global.memory.has("roomPath") or not "RedGlitch" in global.memory["roomPath"]:
    NPC.textBox.hideTextbox()
    # if global.memory.has("roomPath") and "001RedGlitch" in global.memory["roomPath"]:
    #   if not has_done_my_power:
    #     NPC.textBoxContainer.bbText = "to get back up\nyou must die."
    #     NPC.textBoxContainer.setVars()
    #     NPC.textBox.has_been_shown = false
    #     NPC.textBox.showTextbox()
    #     has_done_my_power = true
    # else:
    #   NPC.textBox.hideTextbox()