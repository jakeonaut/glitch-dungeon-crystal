extends "../../../scripts/levelScript.gd"

onready var debugDoor = get_node("DebugDoor")

# @override
func setUpRoomInitializationOverride():
  pass

var hasUpdatedGrammaText = false
func _process(_delta):
  if global.memory["clean_crystals"] >= 3:
    if not debugDoor.visible:
      self.summonSmokeClouds(debugDoor.global_transform.origin, 3, true, true)
      debugDoor.visible = true