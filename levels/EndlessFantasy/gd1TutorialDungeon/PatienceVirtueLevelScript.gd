extends "../../../scripts/levelScript.gd"

onready var npcTutorial = get_node("NPC")
onready var door = get_node("Door2")

var has_activated_npc = false
# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    activateNPC()
  
func activateNPC():
  has_activated_npc = true
  self.summonSmokeClouds(npcTutorial.global_transform.origin, 2, true, true)
  npcTutorial.visible = true
  npcTutorial.can_activate = true
  npcTutorial.is_active = true

var snarkyCommentTimer = 0
var snarkyCommentTimeLimit = 10
func _process(_delta):
  # ._process(delta) implicit

  if not has_activated_npc and global.memory.has("spellbookPage") and global.memory["spellbookPage"].size() >= 2:
    activateNPC()
