extends GridMap

# resources is loaded at compile time with preload
var grey_tiles = preload("res://sceneObjects/tiles/grey_tiles.tres") 
var grey_palette = preload("res://assets/palettes/grey_palette.png")
var grey_purple_palette = preload("res://assets/palettes/grey_purple_palette.png")
var grey_palette_alt = preload("res://assets/palettes/grey_palette_alt.png")

var red_tiles = preload("res://sceneObjects/tiles/red_tiles.tres")
var red_palette = preload("res://assets/palettes/red_palette.png")

var green_tiles = preload("res://sceneObjects/tiles/green_tiles.tres")
var green_palette = preload("res://assets/palettes/green_palette.png")
var green_palette_alt = preload("res://assets/palettes/green_palette_alt.png")

var black_tiles = preload("res://sceneObjects/tiles/black_tiles.tres")
var black_palette = preload("res://assets/palettes/black_palette.png")

var yellow_tiles = preload("res://sceneObjects/tiles/yellow_tiles.tres")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")

var white_tiles = preload("res://sceneObjects/tiles/white_tiles.tres")
var white_palette = preload("res://assets/palettes/white_palette.png")

onready var cosmeticLevelTiles = get_node("CosmeticLevelTiles")

var tile_index_array = []
var tile_name_array = []

func setRandomTileNameOfType(newName, num_rand, cell_index, offset = 0):
    setTileNameNum(newName, (randi() % num_rand) + offset, cell_index)

func setTileNameNum(newName, num, cell_index):
    if num != 0:
        newName = newName + str(num+1) # 0 index, so add one
    var new_tile_type = mesh_library.find_item_by_name(newName)
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, new_tile_type)

func _ready():
    var cell_indices = get_used_cells()
    for i in range(len(cell_indices)):
        var cell_index = cell_indices[i]
        var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
        var tile_name = mesh_library.get_item_name(tile_type)
        if tile_name == "BrickSolidCeil":
            var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
            var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
            if bottom_neighbor_tile_type != -1: # we have a bottom neighbor!!!
                if top_neighbor_tile_type == -1: # we have no top neighbor...
                    setRandomTileNameOfType("BrickSolidRoof", 7, Vector3(cell_index.x, cell_index.y+1, cell_index.z))
                    tile_index_array.push_back(Vector3(cell_index.x, cell_index.y+1, cell_index.z))
                    tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)))
                setRandomTileNameOfType("BrickSolid", 8, cell_index)
            else:
                setRandomTileNameOfType("BrickSolidCeil", 6, cell_index)
        elif tile_name == "BrickSolid":
            var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
            var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
            if top_neighbor_tile_type == -1: # no top neighbor
                var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
                var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
                if left_neighbor_tile_type == -1: # no left neighbor
                    setRandomTileNameOfType("BrickSolidTopLeft", 2, cell_index)
                elif right_neighbor_tile_type == -1: # no right neighbor
                    setRandomTileNameOfType("BrickSolidTopRight", 2, cell_index)
                else:
                    setRandomTileNameOfType("BrickSolidTop", 8, cell_index)
            elif bottom_neighbor_tile_type == -1: # we have a top neighbor, but no bottom neighbor
                setRandomTileNameOfType("BrickSolidBot", 9, cell_index)
            else:
                setRandomTileNameOfType("BrickSolid", 8, cell_index)
        elif tile_name == "CloudSemisolid":
            var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
            var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
            if top_neighbor_tile_type == -1: # no top neighbor
                setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index)
            else:
                setRandomTileNameOfType("CloudSemisolid", 4, cell_index)
        elif tile_name == "Spikes":
            var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
            var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
            if left_neighbor_tile_type == -1 and right_neighbor_tile_type == -1: # no left or right neighbors
                setTileNameNum("Spikes", 4, cell_index) # 5, but 0 indexed...
            elif left_neighbor_tile_type == -1: # no left neighbor
                pass 
            elif right_neighbor_tile_type == -1: # no right neighbor
                setTileNameNum("Spikes", 3, cell_index) # 4, but 0 indexed...
            else:
                setRandomTileNameOfType("Spikes", 2, cell_index, 1)
        
        tile_index_array.push_back(cell_index)
        tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y, cell_index.z)))
    
func changeColorPalette(palette, palette_alt):
    var item_list = mesh_library.get_item_list()
    for i in range(len(item_list)):
        var item_id = item_list[i]
        var mesh = mesh_library.get_item_mesh(item_id)
        var tile_name = mesh_library.get_item_name(item_id)
        var material = mesh.get_material()
        if material is ShaderMaterial:
            if "CloudSemisolid" in tile_name:
                material.set_shader_param("base_palette", palette_alt)
            else:
                material.set_shader_param("base_palette", palette)
        mesh.set_material(material)
        mesh_library.set_item_mesh(item_id, mesh)

func properlySetTiles():
    for i in range(len(tile_index_array)):
        var cell_index = tile_index_array[i]
        var tile_name = tile_name_array[i]
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name))

func normalGlitch():
    set_mesh_library(grey_tiles)
    changeColorPalette(grey_purple_palette, grey_palette_alt)
    properlySetTiles()
    cosmeticLevelTiles.normalGlitch(grey_purple_palette)

func floorGlitch():
    set_mesh_library(red_tiles)
    # changeColorPalette(red_palette, grey_palette)
    properlySetTiles()
    cosmeticLevelTiles.floorGlitch(red_palette)

func featherGlitch():
    set_mesh_library(green_tiles)
    # changeColorPalette(green_palette, green_palette_alt)
    properlySetTiles()
    cosmeticLevelTiles.featherGlitch(green_palette)

func invisibleGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(black_tiles)
    # changeColorPalette(black_palette, white_palette)
    properlySetTiles()
    cosmeticLevelTiles.normalGlitch(black_palette)
    
func ladderGlitch():
    set_mesh_library(yellow_tiles)
    # changeColorPalette(yellow_palette, black_palette)
    properlySetTiles()
    cosmeticLevelTiles.normalGlitch(yellow_palette)

func walkThroughWallsGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(white_tiles)
    # changeColorPalette(white_palette, red_palette)
    properlySetTiles()
    cosmeticLevelTiles.normalGlitch(white_palette)