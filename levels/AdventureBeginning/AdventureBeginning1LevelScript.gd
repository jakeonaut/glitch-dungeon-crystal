extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    levelTiles.set_mesh_library(levelTiles.green_tiles)
    levelTiles.properlySetTiles()
