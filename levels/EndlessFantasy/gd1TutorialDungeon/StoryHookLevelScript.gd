extends "../../../scripts/levelScript.gd"

onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  has_decided = true
  # see 000NPC3AbortSound.gd
  
  
func _process(_delta):
  # ._process(delta) implicit
  if not has_decided:
    return