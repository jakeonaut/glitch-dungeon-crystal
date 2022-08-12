extends "LevelTiles.gd"

# IFNDEF levelScript.gd
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH", "POISON_FOREST") var tileset_type 

# @override
func buildRandomTiles():
    grow_tile_upward = false
    .buildRandomTiles()

# @override
func ready_impl():
    buildRandomTiles()

    setTileset(tileset_type)
