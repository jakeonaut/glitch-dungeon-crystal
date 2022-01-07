extends "LevelTiles.gd"

# IFNDEF levelScript.gd
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD") var tileset_type 

func _ready():
    pass # Replace with function body.

# @override
func ready_impl():
    buildRandomTiles()
    
    # IFNDEF levelScript.gd
    if tileset_type == global.TilesetType.HOUSE:
        self.set_mesh_library(self.red_tiles)
        self.grey_palette = global.grey_palette_town
        self.green_palette = global.green_palette_town
        self.properlySetTiles()
    elif tileset_type == global.TilesetType.FOREST:
        self.set_mesh_library(self.green_tiles)
        self.properlySetTiles()
