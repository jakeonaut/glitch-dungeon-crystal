extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    levelTiles.set_mesh_library(levelTiles.red_tiles)
    levelTiles.changeColorPalette(levelTiles.grey_palette, levelTiles.grey_purple_palette)
    levelTiles.properlySetTiles()
    
    if global.memory.has("spellbookPage"):
        var spellbookPage = get_node("SpellbookPage")
        spellbookPage.is_active = false
        spellbookPage.visible = false
        
        player.applyGlitch(global.memory["current_glitch"])
