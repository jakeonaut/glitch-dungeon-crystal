extends GridMap

# resources is loaded at compile time with preload
var grey_tiles = preload("res://sceneObjects/tiles/grey_tiles.tres") 
var red_tiles = preload("res://sceneObjects/tiles/red_tiles.tres")
var green_tiles = preload("res://sceneObjects/tiles/green_tiles.tres")
var yellow_tiles = preload("res://sceneObjects/tiles/yellow_tiles.tres")
var black_tiles = preload("res://sceneObjects/tiles/black_tiles.tres")
var white_tiles = preload("res://sceneObjects/tiles/white_tiles.tres")

var tile_index_array = []
var tile_name_array = []

func setRandomTileNameOfType(newName, num_rand, cell_index):
    var new_tile_num = randi() % num_rand
    if new_tile_num != 0:
        newName = newName + str(new_tile_num+1) # 0 index, so add one
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
        
        tile_index_array.push_back(cell_index)
        tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y, cell_index.z)))
    # for every tile:
    #   if solid:
    #      # detect neighboring tiles
    #      if has_neighbor_top and has_neighbor_bottom: # center tile
    #           if has_neighbor_left and has_neighor_right:
    #               pass # pick random solid tile from set
    #           elif has_neighbor_left:
    #               pass
    #           else:
    #               pass
    #       elif has_neighbor_top and not has_neighbor_bottom: # ceiling or bottom of floor
    #           # TODO(jaketrower): How do we decide between ceiling or bottom of floor?
    #           if has_neighbor_left and has_neighbor_right:
    #               pass
    #           elif has_neighbor_left:
    #               pass
    #           else:
    #               pass
    #       elif has_neighbor_bottom and not has_neighbor_top: # floor
    #           if has_neighbor_left and has_neighbor_right:
    #               pass
    #           elif has_neighbor_left:
    #               pass
    #           else:
    #               pass
    # 
    #   if semisolid:
    #       pass
    #   if spikes:
    #       pass
    pass
    
func properlySetTiles():
    for i in range(len(tile_index_array)):
        var cell_index = tile_index_array[i]
        var tile_name = tile_name_array[i]
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name))

func normalGlitch():
    set_mesh_library(grey_tiles)
    properlySetTiles()

func floorGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(red_tiles)
    properlySetTiles()

func featherGlitch():
    set_mesh_library(green_tiles)
    properlySetTiles()

func ladderGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(yellow_tiles)
    properlySetTiles()

func invisibleGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(black_tiles)
    properlySetTiles()

func walkThroughWallsGlitch():
    set_mesh_library(grey_tiles) # set_mesh_library(white_tiles)
    properlySetTiles()