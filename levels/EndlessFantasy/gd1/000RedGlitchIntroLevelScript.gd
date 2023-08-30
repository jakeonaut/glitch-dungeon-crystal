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