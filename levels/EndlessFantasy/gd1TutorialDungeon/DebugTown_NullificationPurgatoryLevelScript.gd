extends "../../../scripts/levelScript.gd"

onready var npcTutorial = get_node("NPCTutorial")

var has_activated_npc = false
# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    yield(get_tree().create_timer(1.0), "timeout")
    activateNPC()
  
func activateNPC():
  has_activated_npc = true
  self.summonSmokeClouds(npcTutorial.global_transform.origin, 2, true, true)
  npcTutorial.visible = true
  npcTutorial.can_activate = true
  npcTutorial.is_active = true

  var finalText = "with the GRIMOIRE:\npress " + global.getInputText("alt_action_button") + " to switch\nbetween spells"
  var is_controller_connected = Input.get_connected_joypads().size() > 0
  if is_controller_connected:
    finalText += "\nor use " + global.getInputText("left_button") + " and " + global.getInputText("right_button")
  npcTutorial.textBox.text_final = finalText
  npcTutorial.textBox.textNode.bbcode_text = finalText
