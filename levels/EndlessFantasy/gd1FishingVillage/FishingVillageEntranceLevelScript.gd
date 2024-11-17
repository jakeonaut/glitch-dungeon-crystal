extends "../../../scripts/levelScript.gd"

onready var fishingRodShortcut = get_node("FishingRodShortcut")
onready var dialogPosition = get_node("DialogPosition")

# @override
func setUpRoomInitializationOverride():
  dialogPosition.visible = false
  if global.memory["fishing_rod_shortcut"] > 0:
    fishingRodShortcut.depth = 16
    fishingRodShortcut.low_speed = 8
    fishingRodShortcut.is_reeled_in = true
  # elif not global.haveIBeenToThisLevel(self):
  #   player.textBox.override_target_origin = dialogPosition.global_transform.origin
  #   player.sayThis("hm, cellar is looking\n a little waterlogged..", 4.0)
