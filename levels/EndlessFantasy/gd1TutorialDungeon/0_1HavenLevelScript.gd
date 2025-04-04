extends "../../../scripts/levelScript.gd"

onready var door3 = get_node("Door3")
onready var door5 = get_node("Door5")
onready var broomUpgradeCrone = get_node("BroomUpgradeCrone")
onready var fishElderNPC = get_node("FishElderNPC")
onready var sporeElderNPC = get_node("SporeElderNPC")
onready var wormElderNPC = get_node("WormElderNPC")

onready var anglerShortcut = get_node("AnglerShortcutDoor")
onready var babaShortcut = get_node("BabaShortcutDoor")
onready var claydolShortcut = get_node("ClaydolShortcutDoor")

# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("anglerShortcut") or not global.memory["anglerShortcut"]:
    anglerShortcut.visible = false
  else:
    anglerShortcut.visible = true
  if not global.memory.has("babaShortcut") or not global.memory["babaShortcut"]:
    babaShortcut.visible = false
  else:
    babaShortcut.visible = true
  if not global.memory.has("claydolShortcut") or not global.memory["claydolShortcut"]:
    claydolShortcut.visible = false
  else:
    claydolShortcut.visible = true

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
  var hasEnteredTower = false # global.memory.has("gd1CrystalTower")
  if global.memory["angler_seaman_boss"] < 3 or hasEnteredTower:
    fishElderNPC.queue_free()
  if global.memory["baba_yaga_boss"] < 3 or hasEnteredTower:
    sporeElderNPC.queue_free()
  if global.memory["dogu_matryoshka_boss"] < 3 or hasEnteredTower:
    wormElderNPC.queue_free()