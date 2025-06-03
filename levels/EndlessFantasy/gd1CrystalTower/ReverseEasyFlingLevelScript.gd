extends "../../../scripts/levelScript.gd"

onready var glitchedGrimoire = get_node("GlitchedGrimoire")
onready var door2 = get_node("Door2")
onready var savePoint2 = get_node("SavePoint2")

onready var ladderSpell = get_node("LadderSpell")
onready var floorSpell = get_node("FloorSpell")
onready var featherSpell = get_node("FeatherSpell")

# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("spellbookPage"):
    glitchedGrimoire.queue_free()
    savePoint2.visible = true
    
  if global.memory["glitched_grimoire"] or not global.memory.has("spellbookPage"):
    ladderSpell.visible = true
    floorSpell.visible = true
    featherSpell.visible = true

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

# func glitchOutRef(npc):
#   if npc.get_ref() != null:
#     npc.get_ref().glitchOut()