extends "../../../scripts/levelScript.gd"

onready var door3 = get_node("Door3")
onready var door5 = get_node("Door5")
onready var broomUpgradeCrone = get_node("BroomUpgradeCrone")

# @override
func setUpRoomInitializationOverride():
  if global.memory["demo_mode"] > 0:
    door3.key_type = global.KeyItem.DEMO
    if global.memory.has(self.getShortLevelName()) and global.memory[self.getShortLevelName()] != null:
      global.memory[self.getShortLevelName()].erase("Door3")
    door3.is_locked = true
    door3.animationPlayer.stop()
    door3.animationPlayer.clear_queue()
    door3.queueLockAnimation()
    door5.key_type = global.KeyItem.DEMO
    if global.memory.has(self.getShortLevelName()) and global.memory[self.getShortLevelName()] != null:
      global.memory[self.getShortLevelName()].erase("Door5")
    door5.is_locked = true
    door5.animationPlayer.stop()
    door5.animationPlayer.clear_queue()
    door5.queueLockAnimation()

  if global.memory["clean_crystals"] >= 4:
    broomUpgradeCrone.queue_free()
  if global.memory["angler_seaman_boss"] < 4:
    get_node("FishElderNPC").queue_free()
  if global.memory["baba_yaga_boss"] < 4:
    get_node("SporeElderNPC").queue_free()
  if global.memory["dogu_matryoshka_boss"] < 4:
    get_node("WormElderNPC").queue_free()