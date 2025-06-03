extends "../../../scripts/levelScript.gd"

onready var babushkaCatNpc = weakref(get_node("GlitchTileSpawner"))
onready var spellbookPage = weakref(get_node("SpellbookPage"))

# @override
func setUpRoomInitializationOverride():
  if global.memory["babushka_cat_story_hook"] > 0 and babushkaCatNpc.get_ref() != null:
    babushkaCatNpc.get_ref().queue_free()

  if global.memory["hard_mode"] > 0 and spellbookPage.get_ref() != null:
    spellbookPage.get_ref().queue_free()
