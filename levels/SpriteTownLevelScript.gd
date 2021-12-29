extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    levelTiles.set_mesh_library(levelTiles.green_tiles)
    levelTiles.changeColorPalette(levelTiles.grey_palette, levelTiles.grey_purple_palette)
    levelTiles.properlySetTiles()
