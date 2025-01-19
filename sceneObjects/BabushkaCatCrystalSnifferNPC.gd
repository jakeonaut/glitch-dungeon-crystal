extends "../scripts/NPC.gd"

func _ready():
  if global.memory["babushka_cat_story_hook"] > 2:
    queue_free()