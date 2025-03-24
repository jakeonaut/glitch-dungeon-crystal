extends Spatial

onready var mimicNPC = get_node("MimicNPC")
onready var treasureSpellCollectable = get_node("TreasureSpellCollectable")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  set_process(true)
  treasureSpellCollectable.is_active = false