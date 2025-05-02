extends "../../../scripts/levelScript.gd"

onready var door3 = get_node("Door3")
onready var door5 = get_node("Door5")
onready var broomUpgradeCrone = get_node("BroomUpgradeCrone")
onready var fishElderNPC = get_node("FishElderNPC")
onready var sporeElderNPC = get_node("SporeElderNPC")
onready var wormElderNPC = get_node("WormElderNPC")
onready var fryingPanNPC = get_node("FryingPanNPC")
onready var featherSpell = get_node("FeatherSpell")
onready var ladderSpell = get_node("LadderSpell")
onready var invisibleSpell = get_node("InvisibleSpell")

onready var anglerShortcut = get_node("AnglerShortcutDoor")
onready var babaShortcut = get_node("BabaShortcutDoor")
onready var claydolShortcut = get_node("ClaydolShortcutDoor")

onready var glitchEnemy = get_node("GlitchEnemy")
onready var glitchEnemy2 = get_node("GlitchEnemy2")

# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("anglerShortcut") or not global.memory["anglerShortcut"]:
    anglerShortcut.visible = false
    featherSpell.visible = false
  else:
    anglerShortcut.visible = true
    featherSpell.visible = true
  if not global.memory.has("babaShortcut") or not global.memory["babaShortcut"]:
    babaShortcut.visible = false
    invisibleSpell.visible = false
  else:
    babaShortcut.visible = true
    invisibleSpell.visible = true
  if not global.memory.has("claydolShortcut") or not global.memory["claydolShortcut"]:
    claydolShortcut.visible = false
    ladderSpell.visible = false
  else:
    claydolShortcut.visible = true
    ladderSpell.visible = true

  if global.demo_mode <= 0:
    glitchEnemy.queue_free()
    glitchEnemy2.queue_free()

  if global.memory["clean_crystals"] >= 4:
    broomUpgradeCrone.queue_free()
  var hasEnteredTower = false # global.memory.has("gd1CrystalTower")
  if global.memory["angler_seaman_boss"] < 3 or hasEnteredTower:
    fishElderNPC.queue_free()
  if global.memory["baba_yaga_boss"] < 3 or hasEnteredTower:
    sporeElderNPC.queue_free()
  if global.memory["dogu_matryoshka_boss"] < 3 or hasEnteredTower:
    wormElderNPC.queue_free()