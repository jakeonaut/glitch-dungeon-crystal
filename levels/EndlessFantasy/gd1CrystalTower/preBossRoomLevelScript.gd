extends "../../../scripts/levelScript.gd"


onready var door2 = get_node("Door2")
onready var babushkaCat = weakref(get_node("BabushkaCat"))

onready var npc3 = weakref(get_node("NPC3"))
onready var npc4 = weakref(get_node("NPC4"))
onready var npc5 = weakref(get_node("NPC5"))
onready var npc7 = weakref(get_node("NPC7"))
onready var npc8 = weakref(get_node("NPC8"))
onready var npc9 = weakref(get_node("NPC9"))
onready var croneTeleportKeyTreasure = get_node("CroneTeleportKeyTreasure")
onready var timeKeeper = get_node("TimeKeeper") if has_node("TimeKeeper") else null

# @override
func setUpRoomInitializationOverride():
  if global.memory["priestess"] >= 1 and global.memory["priestess"] < 3 and global.memory["hard_mode"] == 0 and timeKeeper and not global.memory["secret_bauble"]:
    timeKeeper.visible = false
    yield(get_tree().create_timer(1.0), "timeout")
    self.summonSmokeClouds(timeKeeper.global_transform.origin, 3, true, true)
    timeKeeper.visible = true
  elif timeKeeper:
    timeKeeper.queue_free()

  if global.memory["has_beat_the_game"] > 0:
    croneTeleportKeyTreasure.visible = true

  if global.memory["world_of_ruin"] > 0 and babushkaCat.get_ref() != null:
    door2.lockMeUp(999)
    babushkaCat.get_ref().global_transform.origin.x = -1.035
    babushkaCat.get_ref().global_transform.origin.y = 7.041

    yield(get_tree().create_timer(0.5), "timeout")
    glitchOutRef(npc3)
    yield(get_tree().create_timer(0.5), "timeout")
    glitchOutRef(npc4)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc5)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc7)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc8)
    yield(get_tree().create_timer(0.5), "timeout")
    glitchOutRef(npc9)

func glitchOutRef(npc):
  if npc.get_ref() != null:
    npc.get_ref().glitchOut()