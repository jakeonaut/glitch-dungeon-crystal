extends "../../../scripts/levelScript.gd"

onready var door6 = get_node("Door6")

# @override
func setUpRoomInitializationOverride():
  # original_granny_text = npcGranny.textBox.text_final
  if (global.memory.has("roomPath") and "Pastoral" in global.memory["roomPath"]):
    door6.greyMeOut()