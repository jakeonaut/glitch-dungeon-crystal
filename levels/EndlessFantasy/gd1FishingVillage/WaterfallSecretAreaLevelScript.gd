extends "../../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
  if global.memory["fishing_rod_shortcut"] <= 0:
    global.memory["fishing_rod_shortcut"] = 1