extends "../../../scripts/levelScript.gd"


onready var door2 = get_node("Door2")
onready var babushkaCat = weakref(get_node("BabushkaCat"))

onready var npc3 = weakref(get_node("NPC3"))
onready var npc4 = weakref(get_node("NPC4"))
onready var npc5 = weakref(get_node("NPC5"))
onready var npc6 = weakref(get_node("NPC6"))
onready var npc7 = weakref(get_node("NPC7"))
onready var npc8 = weakref(get_node("NPC8"))
onready var npc9 = weakref(get_node("NPC9"))
onready var ladderSpell = get_node("LadderSpell")
onready var floorSpell = get_node("FloorSpell")
onready var featherSpell = get_node("FeatherSpell")

# @override
func setUpRoomInitializationOverride():
  if global.memory["glitched_grimoire"]:
    ladderSpell.visible = true
    floorSpell.visible = true
    featherSpell.visible = true
  # if global.memory.has("spellbookPage"):
  #   if door2.is_locked:
  #     door2.animationPlayer.clear_queue()
  #     door2.animationPlayer.stop()
  #     door2.animationPlayer.play("doorOpen")
  #     door2.is_locked = false
  # else:
  #   if not door2.is_locked:
  #     door2.animationPlayer.clear_queue()
  #     door2.animationPlayer.stop()
  #     door2.animationPlayer.play("locked")
  #     door2.is_locked = true
  if global.memory["glitch_world"] > 0 and babushkaCat.get_ref() != null:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 999
    player.on_ground = false
    player.was_on_ground = false
    door2.lockMeUp(999)
    # babushkaCat.get_ref().global_transform.origin.x = -1.035
    # babushkaCat.get_ref().global_transform.origin.y = 7.041

    yield(get_tree().create_timer(2.0), "timeout")
    glitchOutRef(npc3)
    yield(get_tree().create_timer(0.5), "timeout")
    glitchOutRef(npc4)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc5)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc6)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc7)
    yield(get_tree().create_timer(0.2), "timeout")
    glitchOutRef(npc8)
    yield(get_tree().create_timer(0.5), "timeout")
    glitchOutRef(npc9)

func _process(_delta):
  if global.pauseMoveInput and global.shouldRenderAsCinematic:
    player.fall_timer = 999

  if player.physics_state == player.PhysicsState.COLLAPSED or \
     player.physics_state == player.PhysicsState.CAN_WAKE_UP:
    global.pauseMoveInput = false
    global.shouldRenderAsCinematic = false
  elif player.physics_state == player.PhysicsState.WAKING_UP:
    global.pauseMoveInput = true
  elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
    global.pauseMoveInput = false
    global.shouldRenderAsCinematic = false

func glitchOutRef(npc):
  if npc.get_ref() != null:
    npc.get_ref().glitchOut()