extends "../../scripts/levelScript.gd"

onready var NPC = self.get_node("NPC4")
enum TutorialState {
    DEFAULT,
    GREEN_TUTORIAL,
    RED_TUTORIAL,
    RAN_OUT_OF_MANA
}
var npcState = TutorialState.DEFAULT

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass

# @override
func _process(_delta):
    # ._process(delta) implicit in GdScript
    var glitchForm = player.glitch_form
    if global.memory["mp"] == 0 and npcState != TutorialState.DEFAULT and npcState != TutorialState.RAN_OUT_OF_MANA:
        NPC.textBoxContainer.bbText = "•you ran out of MP!\n•touch a GLITCH SHRINE\n to restore MP"
        NPC.textBoxContainer.setVars()
        NPC.textBoxContainer.textBox.has_been_shown = false
        npcState = TutorialState.RAN_OUT_OF_MANA
    elif global.memory["mp"] > 0:
        if glitchForm == global.GlitchForm.FEATHER and npcState != TutorialState.GREEN_TUTORIAL:
            NPC.textBoxContainer.bbText = "•oh you're green.\n•um... hold UP or X \n longer to jump higher"
            NPC.textBoxContainer.setVars()
            NPC.textBoxContainer.textBox.has_been_shown = false
            npcState = TutorialState.GREEN_TUTORIAL
        elif glitchForm == global.GlitchForm.FLOOR and npcState != TutorialState.RED_TUTORIAL:
            NPC.textBoxContainer.bbText = "•um you're red..\n•now you can walk\nwithout falling"
            NPC.textBoxContainer.setVars()
            NPC.textBoxContainer.textBox.has_been_shown = false
            npcState = TutorialState.RED_TUTORIAL
    
