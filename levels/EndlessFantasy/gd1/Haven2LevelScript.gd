extends "../../../scripts/levelScript.gd"

# onready var npcGranny = get_node("NPC") if has_node("NPC") else null
# onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
onready var door3 = get_node("Door3")
onready var door4 = get_node("Door4")
onready var door5 = get_node("Door5")

# @override
func setUpRoomInitializationOverride():
  # original_granny_text = npcGranny.textBox.text_final
  if global.memory["crone"] > 0:
    door3.visible = true
    door4.visible = true
    door5.visible = true

  
func _process(_delta):
  # ._process(delta) implicit
  pass