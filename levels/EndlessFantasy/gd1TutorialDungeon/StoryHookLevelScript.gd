extends "../../../scripts/levelScript.gd"

onready var babushkaCatNpc = weakref(get_node("GlitchTileSpawner"))

# @override
func setUpRoomInitializationOverride():
  if global.memory["babushka_cat_story_hook"] > 0 and babushkaCatNpc.get_ref() != null:
    babushkaCatNpc.get_ref().queue_free()