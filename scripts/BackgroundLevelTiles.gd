extends "LevelTiles.gd"

var grey_background_tiles = preload("res://sceneObjects/tiles/grey_background_tiles.tres") 
var red_background_tiles = preload("res://sceneObjects/tiles/red_background_tiles.tres")
var green_background_tiles = preload("res://sceneObjects/tiles/green_background_tiles.tres")
var black_background_tiles = preload("res://sceneObjects/tiles/black_tiles.tres")
var yellow_background_tiles = preload("res://sceneObjects/tiles/yellow_background_tiles.tres")
var white_background_tiles = preload("res://sceneObjects/tiles/white_tiles.tres")

var has_set_camera_x_pos = false
var camera_x_pos_origin = 0

func _ready():
    # ._ready() implicit
    pass # Replace with function body.
    
func applyParallax(real_camera_x_pos):
    if not has_set_camera_x_pos:
        camera_x_pos_origin = real_camera_x_pos
        has_set_camera_x_pos = true
        
    global_transform.origin.x = (camera_x_pos_origin - real_camera_x_pos) / 10
    
# @override
func buildRandomTiles():
    var cell_indices = get_used_cells()
    for i in range(len(cell_indices)):
        var cell_index = cell_indices[i]
        setRandomTileNameOfType("BrickSolidBot", 9, cell_index)
        
        tile_index_array.push_back(cell_index)
        tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y, cell_index.z)))
    
# @override
func setTileset(tileset_type, properly_set_tiles = true):
    if tileset_type == global.TilesetType.HOUSE:
        set_mesh_library(red_background_tiles)
    elif tileset_type == global.TilesetType.FOREST:
        set_mesh_library(green_background_tiles)
    elif tileset_type == global.TilesetType.DESERT:
        set_mesh_library(yellow_background_tiles)

    if properly_set_tiles:
        properlySetTiles()

# @override
func normalGlitch(palette = null):
    properlySetTiles()
    changeColorPalette(palette )
        
# @override
func featherGlitch(palette = null):
    properlySetTiles()
    changeColorPalette(palette)
    
# @override
func floorGlitch(palette = null):
    properlySetTiles()
    changeColorPalette(palette)

# @override
func ladderGlitch(palette = null):
    properlySetTiles()
    changeColorPalette(palette)
    
# @override
func invisibleGlitch(palette = null):
    properlySetTiles()
    changeColorPalette(palette)
    
# @override
func walkThroughWallsGlitch(palette = null):
    set_mesh_library(white_background_tiles)
    properlySetTiles()
    changeColorPalette(palette)
