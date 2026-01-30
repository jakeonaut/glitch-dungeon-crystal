extends GridMap

# resources is loaded at compile time with preload
# var test_all_cosmetic_tiles = preload("res://sceneObjects/tiles/test_all_cosmetic_tiles.tres")
var grey_cosmetic_tiles = preload("res://sceneObjects/tiles/grey_cosmetic_tiles.tres")
var green_cosmetic_tiles = preload("res://sceneObjects/tiles/green_cosmetic_tiles.tres")
var red_cosmetic_tiles = preload("res://sceneObjects/tiles/red_cosmetic_tiles.tres")
var yellow_cosmetic_tiles = preload("res://sceneObjects/tiles/yellow_cosmetic_tiles.tres")

var tileset_type_color = global.GlitchForm.NORMAL
var tile_name_dict = {}

#########################################################
#########################################################
# NOTE: DOESN'T ACTUALLY INHERIT FROM LevelTiles.gd
#########################################################
#########################################################

func setTileNameNum(newName, cell_index):
    var new_tile_type = mesh_library.find_item_by_name(newName)
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, new_tile_type)
    tile_name_dict[cell_index] = newName

func setTileset(_tileset_type, properly_set_tiles = true):
    set_mesh_library(grey_cosmetic_tiles)
    # set_mesh_library(test_all_cosmetic_tiles)
    # if tileset_type == global.TilesetType.HOUSE or tileset_type == global.TilesetType.POISON_HOUSE:
    #     set_mesh_library(red_cosmetic_tiles)
    # elif tileset_type == global.TilesetType.FOREST or tileset_type == global.TilesetType.POISON_FOREST or tileset_type == global.TilesetType.AUTUMN_FOREST:
    #     set_mesh_library(green_cosmetic_tiles)
    # elif tileset_type == global.TilesetType.DESERT:
    #     set_mesh_library(yellow_cosmetic_tiles)
    # elif tileset_type == global.TilesetType.BEACH:
    #     set_mesh_library(green_cosmetic_tiles)
    # elif tileset_type == global.TilesetType.ALIEN:
    #     set_mesh_library(yellow_cosmetic_tiles)
    
    if properly_set_tiles:
        properlySetTiles()

func buildTilesFromScratch(color_suffix_glitch):
    var cell_indices = get_used_cells()
    for i in range(len(cell_indices)):
        var cell_index = cell_indices[i]
        var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
        var tile_name = mesh_library.get_item_name(tile_type)
        if tile_name == "Column":
            setTileNameNum("Column" + color_suffix_glitch, cell_index)
            setTileNameNum("ColumnTopRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y, cell_index.z))
            setTileNameNum("ColumnMidTopLeft" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
            setTileNameNum("ColumnMidTopRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-1, cell_index.z))
            setTileNameNum("ColumnMidLeft" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-2, cell_index.z))
            setTileNameNum("ColumnMidRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-2, cell_index.z))
            setTileNameNum("ColumnMidBotLeft" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-3, cell_index.z))
            setTileNameNum("ColumnMidBotRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-3, cell_index.z))
            setTileNameNum("ColumnBotLeft" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-4, cell_index.z))
            setTileNameNum("ColumnBotRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-4, cell_index.z))
            
        if tile_name == "Chandelier":
            setTileNameNum("Chandelier" + color_suffix_glitch, cell_index)
            setTileNameNum("ChandelierMid" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
            setTileNameNum("ChandelierMidRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-1, cell_index.z))
            setTileNameNum("ChandelierBot" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-2, cell_index.z))
            setTileNameNum("ChandelierBotLeft" + color_suffix_glitch, Vector3(cell_index.x-1, cell_index.y-2, cell_index.z))
            setTileNameNum("ChandelierBotRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-2, cell_index.z))

        if tile_name == "Chandelier2":
            setTileNameNum("Chandelier2" + color_suffix_glitch, cell_index)
            setTileNameNum("ChandelierMid2" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
            setTileNameNum("ChandelierMidRight2" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-1, cell_index.z))
            setTileNameNum("ChandelierBot2" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y-2, cell_index.z))
            setTileNameNum("ChandelierBotLeft2" + color_suffix_glitch, Vector3(cell_index.x-1, cell_index.y-2, cell_index.z))
            setTileNameNum("ChandelierBotRight2" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y-2, cell_index.z))
            
        if tile_name == "FloorDecor":
            setTileNameNum("FloorDecor" + color_suffix_glitch, cell_index)
            setTileNameNum("FloorDecorRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y, cell_index.z))

        if tile_name == "FloorDecor2":
            setTileNameNum("FloorDecor2" + color_suffix_glitch, cell_index)
            setTileNameNum("FloorDecor2Right" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y, cell_index.z))
            setTileNameNum("FloorDecor2Top" + color_suffix_glitch, Vector3(cell_index.x, cell_index.y+1, cell_index.z))
            setTileNameNum("FloorDecor2TopRight" + color_suffix_glitch, Vector3(cell_index.x+1, cell_index.y+1, cell_index.z))

func properlySetTiles():
    var tile_cell_indices = tile_name_dict.keys()
    for i in range(len(tile_cell_indices)):
        var cell_index = tile_cell_indices[i]
        var tile_name = tile_name_dict[cell_index]
        var _tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name))
        
func normalGlitch(palette):
    # set_mesh_library(grey_cosmetic_tiles)
    properlySetTiles()
    changeColorPalette(palette)
        
func featherGlitch(palette):
    # set_mesh_library(green_cosmetic_tiles)
    properlySetTiles()
    changeColorPalette(palette)
    
func floorGlitch(palette):
    # set_mesh_library(red_cosmetic_tiles)
    properlySetTiles()
    changeColorPalette(palette)

func ladderGlitch(palette):
    # set_mesh_library(yellow_cosmetic_tiles)
    properlySetTiles()
    changeColorPalette(palette)

func changeColorPalette(palette):
    # now do it for cosmetic items..
    var item_list = mesh_library.get_item_list()
    for i in range(len(item_list)):
        var item_id = item_list[i]
        var mesh = mesh_library.get_item_mesh(item_id)
        var _tile_name = mesh_library.get_item_name(item_id)
        var material = mesh.get_material()
        if material is ShaderMaterial:
            material.set_shader_param("base_palette", palette)
        mesh.set_material(material)
        mesh_library.set_item_mesh(item_id, mesh)