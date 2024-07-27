extends "../../../scripts/levelScript.gd"

onready var npcTutorial = get_node("NPCTutorial")

var has_activated_npc = false
# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    yield(get_tree().create_timer(1.0), "timeout")
    activateNPC()
  
func activateNPC():
  has_activated_npc = true
  self.summonSmokeClouds(npcTutorial.global_transform.origin, 2, true, true)
  npcTutorial.visible = true
  npcTutorial.can_activate = true
  npcTutorial.is_active = true
