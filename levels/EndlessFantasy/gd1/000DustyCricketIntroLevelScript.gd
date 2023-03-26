extends "../../../scripts/levelScript.gd"

onready var NPC = self.get_node("NPC")

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass

# @override
func _process(_delta):
    if global.memory.has("roomPath") and "001DustyCricket" in global.memory["roomPath"]:
        NPC.textBoxContainer.bbText = "to get back up\ncommune with GLITCH."
        NPC.textBoxContainer.setVars()
        NPC.textBoxContainer.textBox.has_been_shown = false
