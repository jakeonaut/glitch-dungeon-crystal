extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    levelTiles.set_mesh_library(levelTiles.red_tiles)
    levelTiles.changeColorPalette(levelTiles.grey_palette, levelTiles.grey_purple_palette)
    levelTiles.properlySetTiles()
    
    # IFNDEF SpellbookPageAbortSound.gd
    if global.memory.has("spellbookPage"):
        var spellbookPage = get_node("SpellbookPage")
        spellbookPage.is_active = false
        spellbookPage.visible = false
        
        player.applyGlitch(global.memory["current_glitch"], false)
        get_node("NPC").textBox.text_final = "well, that might not\nactually explain anything huh......\n..\nthese SPRITES here\nsay that CRYSTAL ELDERS\nknow much more\nif you explore more of\nthe dungeon you can\nfind them i think\nbut i'm too scared.."
        get_node("NPC").textBox.is_important = false
