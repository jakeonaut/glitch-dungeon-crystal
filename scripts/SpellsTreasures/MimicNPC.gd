extends "../NPC.gd"

export var num_gems_needed = 1
onready var treasureSpellCollectable = get_node("../TreasureSpellCollectable")
func _process(_delta):
  treasureSpellCollectable.is_active = false

# @override
func getSmacked(broom_origin):
  mySprite.max_frames = 3
  .getSmacked(broom_origin)

# @override
func passiveActivate(delta, is_player):
  mySprite.max_frames = 3
  .passiveActivate(delta, is_player)
