extends "../../../scripts/levelScript.gd"

onready var NPC = self.get_node("NPC")

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass


var has_done_my_power = false
# @override
func _process(_delta):
    if not has_done_my_power and global.memory.has("roomPath") and "001RedGlitch" in global.memory["roomPath"]:
      NPC.textBoxContainer.bbText = "to get back up\nyou must die."
      NPC.textBoxContainer.setVars()
      has_done_my_power = true