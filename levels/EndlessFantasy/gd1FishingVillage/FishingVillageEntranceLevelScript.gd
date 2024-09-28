extends "../../../scripts/levelScript.gd"

onready var fishingRodShortcut = get_node("FishingRodShortcut")

# @override
func setUpRoomInitializationOverride():
  if global.memory["fishing_rod_shortcut"] > 0:
    fishingRodShortcut.depth = 16
    fishingRodShortcut.low_speed = 8
    fishingRodShortcut.is_reeled_in = true
