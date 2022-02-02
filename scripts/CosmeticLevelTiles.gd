extends GridMap

# resources is loaded at compile time with preload
var grey_cosmetic_tiles = preload("res://sceneObjects/tiles/grey_cosmetic_tiles.tres")
var green_cosmetic_tiles = preload("res://sceneObjects/tiles/green_cosmetic_tiles.tres")
var red_cosmetic_tiles = preload("res://sceneObjects/tiles/red_cosmetic_tiles.tres")
var yellow_cosmetic_tiles = preload("res://sceneObjects/tiles/yellow_cosmetic_tiles.tres")

var tile_name_dict = {}

func setTileNameNum(newName, num, cell_index):
    if num != 0:
        newName = newName + str(num+1) # 0 index, so add one
    var new_tile_type = mesh_library.find_item_by_name(newName)
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, new_tile_type)

func setTileset(tileset_type):
    if tileset_type == global.TilesetType.HOUSE:
        set_mesh_library(red_cosmetic_tiles)
        properlySetTiles()
    elif tileset_type == global.TilesetType.FOREST:
        set_mesh_library(green_cosmetic_tiles)
        properlySetTiles()
    elif tileset_type == global.TilesetType.DESERT:
        set_mesh_library(yellow_cosmetic_tiles)
        properlySetTiles()

func _ready():
    var cell_indices = get_used_cells()
    for i in range(len(cell_indices)):
        var cell_index = cell_indices[i]
        var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
        var tile_name = mesh_library.get_item_name(tile_type)
        if tile_name == "Column":
            setTileNameNum("Column", 0, cell_index)
            tile_name_dict[cell_index] = "Column"
            setTileNameNum("ColumnTopRight", 0, Vector3(cell_index.x+1, cell_index.y, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y, cell_index.z)] = "ColumnTopRight"
            setTileNameNum("ColumnMidTopLeft", 0, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-1, cell_index.z)] = "ColumnMidTopLeft"
            setTileNameNum("ColumnMidTopRight", 0, Vector3(cell_index.x+1, cell_index.y-1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-1, cell_index.z)] = "ColumnMidTopRight"
            setTileNameNum("ColumnMidLeft", 0, Vector3(cell_index.x, cell_index.y-2, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-2, cell_index.z)] = "ColumnMidLeft"
            setTileNameNum("ColumnMidRight", 0, Vector3(cell_index.x+1, cell_index.y-2, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-2, cell_index.z)] = "ColumnMidRight"
            setTileNameNum("ColumnMidBotLeft", 0, Vector3(cell_index.x, cell_index.y-3, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-3, cell_index.z)] = "ColumnMidBotLeft"
            setTileNameNum("ColumnMidBotRight", 0, Vector3(cell_index.x+1, cell_index.y-3, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-3, cell_index.z)] = "ColumnMidBotRight"
            setTileNameNum("ColumnBotLeft", 0, Vector3(cell_index.x, cell_index.y-4, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-4, cell_index.z)] = "ColumnBotLeft"
            setTileNameNum("ColumnBotRight", 0, Vector3(cell_index.x+1, cell_index.y-4, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-4, cell_index.z)] = "ColumnBotRight"
            
        if tile_name == "Chandelier":
            setTileNameNum("Chandelier", 0, cell_index)
            tile_name_dict[cell_index] = "Chandelier"
            setTileNameNum("ChandelierMid", 0, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-1, cell_index.z)] = "ChandelierMid"
            setTileNameNum("ChandelierMidRight", 0, Vector3(cell_index.x+1, cell_index.y-1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-1, cell_index.z)] = "ChandelierMidRight"
            setTileNameNum("ChandelierBot", 0, Vector3(cell_index.x, cell_index.y-2, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y-2, cell_index.z)] = "ChandelierBot"
            setTileNameNum("ChandelierBotLeft", 0, Vector3(cell_index.x-1, cell_index.y-2, cell_index.z))
            tile_name_dict[Vector3(cell_index.x-1, cell_index.y-2, cell_index.z)] = "ChandelierBotLeft"
            setTileNameNum("ChandelierBotRight", 0, Vector3(cell_index.x+1, cell_index.y-2, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y-2, cell_index.z)] = "ChandelierBotRight"
            
        if tile_name == "FloorDecor":
            setTileNameNum("FloorDecor", 0, cell_index)
            tile_name_dict[cell_index] = "FloorDecor"
            setTileNameNum("FloorDecorRight", 0, Vector3(cell_index.x+1, cell_index.y, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y, cell_index.z)] = "FloorDecorRight"

        if tile_name == "FloorDecor2":
            setTileNameNum("FloorDecor2", 0, cell_index)
            tile_name_dict[cell_index] = "FloorDecor2"
            setTileNameNum("FloorDecor2Right", 0, Vector3(cell_index.x+1, cell_index.y, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y, cell_index.z)] = "FloorDecor2Right"
            setTileNameNum("FloorDecor2Top", 0, Vector3(cell_index.x, cell_index.y+1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x, cell_index.y+1, cell_index.z)] = "FloorDecor2Top"
            setTileNameNum("FloorDecor2TopRight", 0, Vector3(cell_index.x+1, cell_index.y+1, cell_index.z))
            tile_name_dict[Vector3(cell_index.x+1, cell_index.y+1, cell_index.z)] = "FloorDecor2TopRight"

func properlySetTiles():
    var tile_cell_indices = tile_name_dict.keys()
    for i in range(len(tile_cell_indices)):
        var cell_index = tile_cell_indices[i]
        var tile_name = tile_name_dict[cell_index]
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
        var tile_name = mesh_library.get_item_name(item_id)
        var material = mesh.get_material()
        if material is ShaderMaterial:
            material.set_shader_param("base_palette", palette)
        mesh.set_material(material)
        mesh_library.set_item_mesh(item_id, mesh)