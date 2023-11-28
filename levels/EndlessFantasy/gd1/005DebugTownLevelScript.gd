extends "../../../scripts/levelScript.gd"

onready var grammaNPC = get_node("GranmmaNPC")

# @override
func setUpRoomInitializationOverride():
  pass

var hasUpdatedGrammaText = false
func _process(_delta):
  if not hasUpdatedGrammaText and not has_node("ChickenNPC"):
    grammaNPC.textBox.text_final = "•oh.. our chickens\nare gone."
    hasUpdatedGrammaText = true
