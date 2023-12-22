extends "../../../scripts/levelScript.gd"

onready var npcTutorial = get_node("NPC")
onready var door = get_node("Door2")

var has_changed_door = false
var has_activated_npc = false
# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    activateNPC()
    changeDoor(false)
  
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

  if not has_changed_door and global.memory.has("spellbookPage") and global.activeInteractor == null:
    changeDoor()

  if not has_activated_npc and global.memory.has("spellbookPage") and global.memory["spellbookPage"].size() >= 2:
    activateNPC()


func changeDoor(should_lock = true):
  has_changed_door = true
  self.summonSmokeClouds(npcTutorial.global_transform.origin, 2, true, true)
  door.path = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_1Haven.tscn"
  yield(get_tree().create_timer(0.5), "timeout")
  if should_lock:
    door.lockMeUp(2)
