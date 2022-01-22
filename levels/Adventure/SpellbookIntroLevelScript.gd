extends "../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
    # IFNDEF SpellbookPageAbortSound.gd
    if global.memory.has("spellbookPage"):
        var spellbookPage = get_node("SpellbookPage")
        spellbookPage.is_active = false
        spellbookPage.visible = false

        get_node("NPC5").textBox.text_final = "use [Z] to cast\ncollected spells!"
        get_node("NPC5").textBox.has_been_shown = false
        
        get_node("NPC").visible = false
        get_node("NPC").can_activate = false
        get_node("NPC").is_active = false
