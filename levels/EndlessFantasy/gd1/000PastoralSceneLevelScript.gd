extends "../../../scripts/levelScript.gd"

onready var NPC = get_node("NPC") if has_node("NPC") else null
onready var NPC5 = get_node("NPC5") if has_node("NPC5") else null
onready var fallenBroom = weakref(get_node("FallenBroom"))

var has_updated = false

# @override
func _process(_delta):
  if global.memory["broom"] and not has_updated:
    if fallenBroom.get_ref():
      fallenBroom.get_ref().visible = false
    if NPC5 != null:
      NPC5.textBox.hideTextbox()
    has_updated = true
