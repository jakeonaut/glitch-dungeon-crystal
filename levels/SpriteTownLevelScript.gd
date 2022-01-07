extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    # IFNDEF SpellbookPageAbortSound.gd
    if global.memory.has("spellbookPage"):
        var spellbookPage = get_node("SpellbookPage")
        spellbookPage.is_active = false
        spellbookPage.visible = false
        
        get_node("NPC").textBox.text_final = "well, that might not\nactually explain anything huh......\n..\nthese SPRITES here\nsay that CRYSTAL ELDERS\nknow much more\nif you explore more of\nthe dungeon you can\nfind them i think\nbut i'm too scared.."
        get_node("NPC").textBox.is_important = false
        
        get_node("NPC5").textBox.text_final = "use [Z] to cast\ncollected spells!"
