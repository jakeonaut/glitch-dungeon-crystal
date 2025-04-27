extends "../../../scripts/levelScript.gd"

onready var npcTutorial = get_node("NPCTutorial")
onready var npcTutorial2 = get_node("NPCTutorial2")

var has_activated_npc = false
# @override
func setUpRoomInitializationOverride():
  if global.memory.has("spellbookPage"):
    yield(get_tree().create_timer(1.0), "timeout")
    activateNPC()
  else:
    var text = tr("NPC.Secret.4")
    npcTutorial2.textBox.text_final = text
    npcTutorial2.textBox.textNode.bbcode_text = text
    npcTutorial2.textBox.showYesNoOptions = false
  
func activateNPC():
  has_activated_npc = true
  self.summonSmokeClouds(npcTutorial.global_transform.origin, 2, true, true)
  npcTutorial.visible = true
  npcTutorial.can_activate = true
  npcTutorial.is_active = true

  # print(global.getLargeInputText("alt_action_button"))
  # print(tr("NPC.Tutorial.7"))
  # print(tr("NPC.Tutorial.7") % "hi")
  var finalText = tr("NPC.Tutorial.7") % str(global.getLargeInputText("alt_action_button"))
  npcTutorial.textBox.text_final = finalText
  npcTutorial.textBox.textNode.bbcode_text = finalText
