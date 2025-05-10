extends "../../../scripts/levelScript.gd"
onready var shortcutDoor = get_node("ShortcutDoor")
onready var normalDoor = get_node("NormalDoor")

# @override
func setUpRoomInitializationOverride():
  if global.memory.has("roomPath"):
    overrideRoomPath = global.memory["roomPath"]
    shortcutDoor.path = overrideRoomPath
  global.memory["has_teleported"] = true

