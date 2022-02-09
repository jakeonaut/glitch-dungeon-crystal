extends GridMap

# resources is loaded at compile time with preload
# TODO(jaketrower): Probably best to load this once in the levelScript and reference from there
var grey_tiles = preload("res://sceneObjects/tiles/grey_tiles.tres") 
var red_tiles = preload("res://sceneObjects/tiles/red_tiles.tres")
var green_tiles = preload("res://sceneObjects/tiles/green_tiles.tres")
var black_tiles = preload("res://sceneObjects/tiles/black_tiles.tres")
var yellow_tiles = preload("res://sceneObjects/tiles/yellow_tiles.tres")
var white_tiles = preload("res://sceneObjects/tiles/white_tiles.tres")

var grey_palette = global.grey_palette
var red_palette = global.red_palette
var green_palette = global.green_palette
var black_palette = global.black_palette
var yellow_palette = global.yellow_palette
var white_palette = global.white_palette

onready var cosmeticLevelTiles = get_node("CosmeticLevelTiles") if has_node("CosmeticLevelTiles") else null
onready var backgroundLevelTiles = get_node("BackgroundLevelTiles") if has_node("BackgroundLevelTiles") else null
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var tile_index_array = []
var tile_name_array = []
var infected_spikes = []
var spike_infection_timer = 0
var spike_infection_time_limit = 5
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var my_tileset_type = global.TilesetType.DUNGEON

func setRandomTileNameOfType(newName, num_rand, cell_index, offset = 0):
    var rand_int = randi() % num_rand
    # make forest spirals and yellow holes spawn a little less often
    if newName == "BrickSolid" and rand_int == 2:
        if randi() % 3 <= 1:
            rand_int = randi() % num_rand
    setTileNameNum(newName, rand_int + offset, cell_index)

func setTileNameNum(newName, num, cell_index):
    if num != 0:
        newName = newName + str(num+1) # 0 index, so add one
    var new_tile_type = mesh_library.find_item_by_name(newName)
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, new_tile_type)

func _ready():
    set_process(true)

func buildRandomTiles():
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
            var skip_level_top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+2, cell_index.z)
            var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
            var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
            var skip_level_bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-2, cell_index.z)
            # DESERT MODIFICATION
            if my_tileset_type == global.TilesetType.DESERT:
                skip_level_top_neighbor_tile_type = top_neighbor_tile_type
                skip_level_bottom_neighbor_tile_type = bottom_neighbor_tile_type

            if top_neighbor_tile_type == -1 and skip_level_top_neighbor_tile_type == -1: # no top neighbor
                var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
                var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
                if left_neighbor_tile_type == -1: # no left neighbor
                    setRandomTileNameOfType("BrickSolidTopLeft", 2, cell_index)
                elif right_neighbor_tile_type == -1: # no right neighbor
                    setRandomTileNameOfType("BrickSolidTopRight", 2, cell_index)
                else:
                    setRandomTileNameOfType("BrickSolidTop", 8, cell_index)
            # we have a top neighbor, but no bottom neighbor
            elif bottom_neighbor_tile_type == -1 and skip_level_bottom_neighbor_tile_type == -1: 
                setRandomTileNameOfType("BrickSolidBot", 9, cell_index)
                # DESERT MODIFICATION 
                if my_tileset_type == global.TilesetType.DESERT:
                    skip_level_bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-2, cell_index.z)
                    if skip_level_bottom_neighbor_tile_type != -1: # we have a skip level bottom... neighbor...
                        setRandomTileNameOfType("BrickSolidBot", 9, Vector3(cell_index.x, cell_index.y-1, cell_index.z))
                        tile_index_array.push_back(Vector3(cell_index.x, cell_index.y-1, cell_index.z))
                        tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)))
            else:
                setRandomTileNameOfType("BrickSolid", 8, cell_index)
        elif tile_name == "CloudSemisolid":
            var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
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
        
        # maybe make it into a dictionary so that infected spikes removed can be remembered easier
        # and other "tile pushing/creating" if that happens
        tile_index_array.push_back(cell_index)
        tile_name_array.push_back(mesh_library.get_item_name(get_cell_item(cell_index.x, cell_index.y, cell_index.z)))

var randomize_timer = 0
var randomize_time_limit = 0.5
func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    randomize_timer += delta
    if randomize_timer >= randomize_time_limit and tile_index_array.size() > 0:
        randomize_timer = 0
        randomizeTile(tile_index_array[randi() % tile_index_array.size()])
    # TODO(jaketrower): if we want color palette changing to happen over time, it should happen here

    if global.pauseGame: return

    if len(infected_spikes) > 0:
        spike_infection_timer += (delta*22)
        if spike_infection_timer >= spike_infection_time_limit: 
            spike_infection_timer = 0
            for i in range(len(infected_spikes)):
                var coords = infected_spikes.pop_front()
                var top_neighbor_coords = Vector3(coords.x, coords.y + 1, coords.z)
                var bottom_neighbor_coords = Vector3(coords.x, coords.y - 1, coords.z)
                var left_neighbor_coords = Vector3(coords.x - 1, coords.y, coords.z)
                var right_neighbor_coords = Vector3(coords.x + 1, coords.y, coords.z)
                infectSpikes(top_neighbor_coords)
                infectSpikes(bottom_neighbor_coords)
                infectSpikes(left_neighbor_coords)
                infectSpikes(right_neighbor_coords)
                var top_left_neighbor_coords = Vector3(coords.x - 1, coords.y + 1, coords.z)
                var bottom_right_neighbor_coords = Vector3(coords.x + 1, coords.y - 1, coords.z)
                var bottom_left_neighbor_coords = Vector3(coords.x - 1, coords.y - 1, coords.z)
                var top_right_neighbor_coords = Vector3(coords.x + 1, coords.y + 1, coords.z)
                infectSpikes(top_left_neighbor_coords)
                infectSpikes(bottom_right_neighbor_coords)
                infectSpikes(bottom_left_neighbor_coords)
                infectSpikes(top_right_neighbor_coords)

func isTileSpikes(tile_type):
    if tile_type == GridMap.INVALID_CELL_ITEM:
        return false
    var tileCollisionShape = self.mesh_library.get_item_shapes(tile_type)[0]
    return tileCollisionShape is RayShape

func infectSpikes(coords):
    var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
    if isTileSpikes(tile_type):
        infected_spikes.append(coords)
        self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
        summonSmokeClouds(coords, 2)
    spike_infection_timer = 0

func summonSmokeClouds(coords, num_clouds):
    var play_sound = true
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
        newSmokeCloud.global_transform.origin.x = tile_pos.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = tile_pos.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        
        if play_sound:
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        
        var new_material = newSmokeCloud.get_material_override().duplicate()
        new_material.set_shader_param("enable_glitch", "true")
        new_material.set_shader_param("target_palette", global.weird_base_palette)
        newSmokeCloud.set_material_override(new_material.duplicate())

func randomizeTile(cell_index):
    var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
    var tile_name = mesh_library.get_item_name(tile_type)
    if "BrickSolidRoof" in tile_name:
        setRandomTileNameOfType("BrickSolidRoof", 7, cell_index)
    elif "BrickSolidCeil" in tile_name:
        setRandomTileNameOfType("BrickSolidCeil", 6, cell_index)
    elif "BrickSolidTopLeft" in tile_name:
        setRandomTileNameOfType("BrickSolidTopLeft", 2, cell_index)
    elif "BrickSolidTopRight" in tile_name:
        setRandomTileNameOfType("BrickSolidTopRight", 2, cell_index)
    elif "BrickSolidTop" in tile_name:
        setRandomTileNameOfType("BrickSolidTop", 8, cell_index)
    elif "BrickSolidBot" in tile_name:
        setRandomTileNameOfType("BrickSolidBot", 9, cell_index)
    elif "BrickSolid" in tile_name:
        setRandomTileNameOfType("BrickSolid", 8, cell_index)
    elif "CloudSemisolidTop" in tile_name:
        setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index)
    elif "CloudSemisolid" in tile_name:
        setRandomTileNameOfType("CloudSemisolid", 4, cell_index)
    
func changeColorPalette(palette, _palette_alt = null):
    var item_list = mesh_library.get_item_list()
    for i in range(len(item_list)):
        var item_id = item_list[i]
        var mesh = mesh_library.get_item_mesh(item_id)
        var tile_name = mesh_library.get_item_name(item_id)
        var material = mesh.get_material()
        if material is ShaderMaterial:
            if "CloudSemisolid" in tile_name:
                material.set_shader_param("base_palette", palette)
            else:
                material.set_shader_param("base_palette", palette)
        # mesh.set_material(material)
        # mesh_library.set_item_mesh(item_id, mesh)

func properlySetTiles():
    for i in range(len(tile_index_array)):
        var cell_index = tile_index_array[i]
        var tile_name = tile_name_array[i]
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name))

func setTileset(tileset_type, properly_set_tiles = true):
    my_tileset_type = tileset_type
    if tileset_type == global.TilesetType.DUNGEON:
        green_palette = global.green_dungeon_palette
        red_palette = global.red_dungeon_palette
        yellow_palette = global.yellow_dungeon_palette
        black_palette = global.black_dungeon_palette
    elif tileset_type == global.TilesetType.HOUSE:
        set_mesh_library(red_tiles)
        grey_palette = global.grey_palette_town
        green_palette = global.green_palette_town
        black_palette = global.black_palette_town
    elif tileset_type == global.TilesetType.FOREST:
        set_mesh_library(green_tiles)
    elif tileset_type == global.TilesetType.DESERT:
        set_mesh_library(yellow_tiles)

    if properly_set_tiles:
        properlySetTiles()
        
    if cosmeticLevelTiles:
        cosmeticLevelTiles.setTileset(tileset_type, properly_set_tiles)
    if backgroundLevelTiles:
        backgroundLevelTiles.setTileset(tileset_type, properly_set_tiles)

func normalGlitch(_palette = null):
    # set_mesh_library(grey_tiles)
    changeColorPalette(grey_palette, grey_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(grey_palette)
    if backgroundLevelTiles: backgroundLevelTiles.normalGlitch(global.dark_grey_palette)

func floorGlitch(_palette = null):
    # set_mesh_library(red_tiles)
    changeColorPalette(red_palette, red_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.floorGlitch(red_palette)
    if backgroundLevelTiles: backgroundLevelTiles.floorGlitch(global.dark_red_palette)

func featherGlitch(_palette = null):
    # set_mesh_library(green_tiles)
    changeColorPalette(green_palette, green_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.featherGlitch(green_palette)
    if backgroundLevelTiles: backgroundLevelTiles.featherGlitch(global.dark_green_palette)

func invisibleGlitch(_palette = null):
    # set_mesh_library(grey_tiles) # set_mesh_library(black_tiles)
    changeColorPalette(black_palette, black_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(black_palette)
    if backgroundLevelTiles: backgroundLevelTiles.normalGlitch(global.dark_black_palette)
    
func ladderGlitch(_palette = null):
    # set_mesh_library(yellow_tiles)
    changeColorPalette(yellow_palette, yellow_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.ladderGlitch(yellow_palette)
    if backgroundLevelTiles: backgroundLevelTiles.ladderGlitch(global.dark_yellow_palette)

func walkThroughWallsGlitch(_palette = null):
    # set_mesh_library(white_tiles)
    changeColorPalette(white_palette, white_palette)
    properlySetTiles()
    if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(white_palette)
    if backgroundLevelTiles: backgroundLevelTiles.normalGlitch(global.dark_white_palette)
