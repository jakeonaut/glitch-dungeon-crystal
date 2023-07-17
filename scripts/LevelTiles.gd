extends GridMap

var grey_palette = global.grey_palette
var red_palette = global.red_palette
var green_palette = global.green_palette
var black_palette = global.black_palette
var yellow_palette = global.yellow_palette
var white_palette = global.white_palette
var grow_tile_upward = true

var curr_palette = global.grey_palette
export(Resource) var override_palette = null

onready var cosmeticLevelTiles = get_node("CosmeticLevelTiles") if has_node("CosmeticLevelTiles") else null
onready var backgroundLevelTiles = get_node("BackgroundLevelTiles") if has_node("BackgroundLevelTiles") else null
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var tile_dict = {}
var infected_spikes = []
var spike_infection_timer = 0
var spike_infection_time_limit = 5
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var my_tileset_type = global.TilesetType.DUNGEON
var my_tileset_glitch_type = global.GlitchForm.NORMAL

func setRandomTileNameOfType(newName, num_rand, cell_index, tile_orientation, offset = 0, glitch_type = global.GlitchForm.NORMAL, debug = false):
  if debug:
    print("hey!!!: " + str(cell_index) + ", " + str(num_rand) + ", " + str(glitch_type))
  var rand_int = randi() % num_rand
  # make forest spirals and yellow holes spawn a little less often
  if newName == "BrickSolid" and rand_int == 2:
    if randi() % 3 <= 1:
      rand_int = randi() % num_rand
  setTileNameNum(newName, rand_int + offset, cell_index, tile_orientation, glitch_type, debug)

func setTileNameNum(newName, num, cell_index, tile_orientation, glitch_type = global.GlitchForm.NORMAL, debug = false):
  if num != 0:
    newName = newName + str(num+1) # 0 index, so add one

  # TODO(jaketrower): BE WARNED, this is a bit confusing, we are using glitch_type here to set the tileset type
  # and we named them "_green", etc. but it's more like "_forest" etc. 
  if glitch_type == global.GlitchForm.FEATHER:
    newName = newName + "_green"
  elif glitch_type == global.GlitchForm.FLOOR:
    newName = newName + "_red"
  elif glitch_type == global.GlitchForm.LADDER:
    newName = newName + "_yellow"
  elif glitch_type == global.GlitchForm.INVISIBLE:
    newName = newName + "_black"
  elif glitch_type == global.GlitchForm.WALK_THROUGH_WALLS: 
    newName = newName + "_white"

  var new_tile_type = mesh_library.find_item_by_name(newName)
  if debug:
    print("final name and tile_type" + str(newName) + ", " + str(new_tile_type))
  set_cell_item(cell_index.x, cell_index.y, cell_index.z, new_tile_type, tile_orientation)
  return newName

func _ready():
  set_process(true)
  ready_impl()

func ready_impl():
  pass

func removeRemovedTiles():
  var lz = global.currLevelZone
  var ln = level.getShortLevelName()
  var rt = global.removedLevelZoneTilesKey
  if not (global.memory.has(lz) and global.memory[lz].has(ln) and global.memory[lz][ln].has(rt)):
    return
  var removedLevelTiles = global.memory[lz][ln][rt]
  var num_removed_tiles = len(removedLevelTiles)
  for i in range(num_removed_tiles):
    var coords = global.normalizeMemoryPosition(removedLevelTiles[i])
    removeTile(coords, false)

func buildRandomTiles():
  var cell_indices = get_used_cells()
  for i in range(len(cell_indices)):
    var cell_index = cell_indices[i]
    buildSingleRandomTile(cell_index, my_tileset_glitch_type)

func buildSingleRandomTile(cell_index, glitch_type):
  var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
  if tile_type == INVALID_CELL_ITEM:
    return

  var tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
  var tile_name = mesh_library.get_item_name(tile_type)
  if tile_name == "BrickSolidCeil":
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
    if bottom_neighbor_tile_type != -1: # we have a bottom neighbor!!!
      if top_neighbor_tile_type == -1 and grow_tile_upward: # we have no top neighbor...
        var new_index = Vector3(cell_index.x, cell_index.y+1, cell_index.z)
        setRandomTileNameOfType("BrickSolidRoof", 7, new_index, tile_orientation, 0, glitch_type)
        var type = get_cell_item(new_index.x, new_index.y, new_index.z)
        if type != INVALID_CELL_ITEM:
          var name = mesh_library.get_item_name(type)
          tile_dict[new_index] = [name, tile_orientation]
      setRandomTileNameOfType("BrickSolid", 8, cell_index, tile_orientation, 0, glitch_type)
    else:
      setRandomTileNameOfType("BrickSolidCeil", 6, cell_index, tile_orientation, 0, glitch_type)
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
        setRandomTileNameOfType("BrickSolidTopLeft", 2, cell_index, tile_orientation, 0, glitch_type)
      elif right_neighbor_tile_type == -1: # no right neighbor
        setRandomTileNameOfType("BrickSolidTopRight", 2, cell_index, tile_orientation, 0, glitch_type)
      else:
        setRandomTileNameOfType("BrickSolidTop", 8, cell_index, tile_orientation, 0, glitch_type)
    # we have a top neighbor, but no bottom neighbor
    elif bottom_neighbor_tile_type == -1 and skip_level_bottom_neighbor_tile_type == -1: 
      setRandomTileNameOfType("BrickSolidBot", 9, cell_index, tile_orientation, 0, glitch_type)
      # DESERT MODIFICATION 
      if my_tileset_type == global.TilesetType.DESERT:
        skip_level_bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-2, cell_index.z)
        if skip_level_bottom_neighbor_tile_type != -1: # we have a skip level bottom... neighbor...
          var new_index = Vector3(cell_index.x, cell_index.y-1, cell_index.z)
          setRandomTileNameOfType("BrickSolidBot", 9, new_index, tile_orientation, 0, glitch_type)
          var type = get_cell_item(new_index.x, new_index.y, new_index.z)
          if type != INVALID_CELL_ITEM:
            var name = mesh_library.get_item_name(type)
            tile_dict[new_index] = [name, tile_orientation]
    else:
      setRandomTileNameOfType("BrickSolid", 8, cell_index, tile_orientation, 0, glitch_type)
  elif tile_name == "CloudSemisolid":
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    if top_neighbor_tile_type == -1: # no top neighbor
      setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index, tile_orientation, 0)
    else:
      setRandomTileNameOfType("CloudSemisolid", 4, cell_index, tile_orientation, 0)
  elif tile_name == "Spikes":
    # var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
    # var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
    # if left_neighbor_tile_type == -1 and right_neighbor_tile_type == -1: # no left or right neighbors
    setRandomTileNameOfType("Spikes", 5, cell_index, tile_orientation) # 5, but 0 indexed...
    # elif left_neighbor_tile_type == -1: # no left neighbor
    #   pass 
    # elif right_neighbor_tile_type == -1: # no right neighbor
    #   setTileNameNum("Spikes", 3, cell_index, tile_orientation) # 4, but 0 indexed...
    # else:
    #   setRandomTileNameOfType("Spikes", 2, cell_index, tile_orientation, 1)
  elif tile_name == "GlitchSpikes":
    # var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
    # var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
    # if left_neighbor_tile_type == -1 and right_neighbor_tile_type == -1: # no left or right neighbors
    setRandomTileNameOfType("GlitchSpikes", 5, cell_index, tile_orientation) # 5, but 0 indexed...
    # elif left_neighbor_tile_type == -1: # no left neighbor
    #   pass 
    # elif right_neighbor_tile_type == -1: # no right neighbor
    #   setTileNameNum("GlitchSpikes", 3, cell_index, tile_orientation) # 4, but 0 indexed...
    # else:
    #   setRandomTileNameOfType("GlitchSpikes", 2, cell_index, tile_orientation, 1)
  
  # maybe make it into a dictionary so that infected spikes removed can be remembered easier
  # and other "tile pushing/creating" if that happens
  var type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
  if type == INVALID_CELL_ITEM:
    return
  var name = mesh_library.get_item_name(type)
  tile_dict[cell_index] = [name, tile_orientation]

var randomize_timer = 0
var randomize_time_limit = 0.5
var randomize_num = 1
var randomize_num_counter = 0
var unrandomize_timer = 0
var unrandomize_time_limit = 0.5
var unrandomized_num = 0
var unrandomized_num_counter = 0.1
var unrandomize_cell_index = 0
var unrandomize_cell_indices = []
var is_unrandomizing = false
var is_rerandomizing = false

var rerandomize_timer = 0
var rerandomize_time_limit = 5

func getRandomGlitchType():
  var rand_int = randi() % 4
  if rand_int == 0:
    return global.GlitchForm.NORMAL
  if rand_int == 1:
    return global.GlitchForm.FEATHER
  if rand_int == 2:
    return global.GlitchForm.FLOOR
  if rand_int == 3:
    return global.GlitchForm.LADDER

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  # rerandomize_timer += (delta * 22)
  # if rerandomize_timer >= rerandomize_time_limit:
  #   rerandomizeTile(Vector3(0, 0, 0), getRandomGlitchType())
  #   rerandomize_timer = 0
  
  # TODO(jake): This Cutscene stuff is only for hitting the end of level geode
  if is_unrandomizing:
    unrandomize_timer += (delta*22)
    if unrandomize_timer >= unrandomize_time_limit:
      unrandomize_timer = 0
      unrandomized_num += unrandomized_num_counter
      if level.player.pressingDown():
        unrandomized_num += 1
      for _i in range(floor(unrandomized_num)):
        var cell_index = unrandomize_cell_indices[unrandomize_cell_index]
        unrandomizeTile(cell_index)
        unrandomize_cell_index += 1
        if unrandomize_cell_index >= unrandomize_cell_indices.size():
          unrandomize_cell_index = 0
          is_unrandomizing = false
          # getPlayer().applyGlitch(global.GlitchForm.FEATHER)
          # level.get_node("FeatherSpell").first_ever_glitch = false
          # level.uiLayer.get_node("GlitchSprite").visible = true
          # level.uiLayer.get_node("GlitchSprite").rect_scale = Vector2(1.5, 1.5)
          # level.uiLayer.get_node("GlitchSprite").rect_position = Vector2(300, 250)
          # level.uiLayer.get_node("GlitchStatusRect").visible = true
          # level.uiLayer.get_node("GlitchStatusRect").rect_scale = Vector2(1.5, 1.5)
          # level.uiLayer.get_node("GlitchStatusRect").rect_position = Vector2(300, 250)
          # level.uiLayer.statsTitleRect.visible = true
          # musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer)
          for i in range(len(unrandomize_cell_indices)):
            unrandomizeTile(unrandomize_cell_indices[i])
          is_rerandomizing = true
          break
    return
  elif is_rerandomizing:
    unrandomize_timer += (delta*22)
    if unrandomize_timer >= unrandomize_time_limit:
      unrandomize_timer = 0
      if not level.player.pressingDown():
        unrandomized_num -= unrandomized_num_counter/2
      for _i in range(ceil(unrandomized_num)):
        var cell_index = unrandomize_cell_indices[unrandomize_cell_index]
        buildSingleRandomTile(cell_index, global.GlitchForm.NORMAL)
        unrandomize_cell_index += 1
        if unrandomize_cell_index >= unrandomize_cell_indices.size():
          unrandomize_cell_index = 0
          is_rerandomizing = false
          # global.pauseGame = false
          # getPlayer().mySprite.get_material_override().set_shader_param("enable_palette_cycle", false)
          # getPlayer().mySprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)
          # getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", false)
          # break
    return

  randomize_timer += delta
  if randomize_timer >= randomize_time_limit and tile_dict.size() > 0:
    randomize_timer = 0
    for _i in range(randomize_num):
      var rand_key = tile_dict.keys()[randi() % tile_dict.size()]
      randomizeTile(rand_key, getRandomGlitchType())
    randomize_num += randomize_num_counter
  # TODO(jaketrower): if we want color palette changing to happen over time, it should happen here

  if global.pauseGame: return

  var num_infected_spikes = len(infected_spikes)
  if num_infected_spikes > 0:
    spike_infection_timer += (delta*22)
    if spike_infection_timer >= spike_infection_time_limit: 
      spike_infection_timer = 0
      global.incrementLevelZoneGlitchTiles(num_infected_spikes)
      for _i in range(num_infected_spikes):
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

func isNeighborOfInfectedSpikes(neighborCoords):
  var num_infected_spikes = len(infected_spikes)
  for i in range(num_infected_spikes):
    var infectedCoords = infected_spikes[i]
    if neighborCoords.x <= infectedCoords.x + 1 and neighborCoords.x >= infectedCoords.x - 1 and \
       neighborCoords.y <= infectedCoords.y + 1 and neighborCoords.y >= infectedCoords.y - 1:
      return true
  return false

func isTileSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tileCollisionShape = self.mesh_library.get_item_shapes(tile_type)[0]
  return tileCollisionShape is RayShape

func isTileGlitchSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "GlitchSpikes" in tile_name
  

func infectSpikes(coords):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  if isTileSpikes(tile_type):
    infected_spikes.append(coords)
    
    # TODO(jaketrower): If you want to only TEMPORARILY clear spikes, use this
    # self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
    # TODO(jaketrower): Otherwise, use this
    removeTile(coords)

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

func randomizeTile(cell_index, glitch_type = global.GlitchForm.NORMAL, debug = false):
  var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
  if debug:
    print("tile_type: " + str(tile_type))
  if tile_type == INVALID_CELL_ITEM:
    return

  var tile_name = mesh_library.get_item_name(tile_type)
  if debug:
    print("tile_name: " + str(tile_name))
  var tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
  if "BrickSolidRoof" in tile_name:
    setRandomTileNameOfType("BrickSolidRoof", 7, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolidCeil" in tile_name:
    setRandomTileNameOfType("BrickSolidCeil", 6, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolidTopLeft" in tile_name:
    setRandomTileNameOfType("BrickSolidTopLeft", 2, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolidTopRight" in tile_name:
    setRandomTileNameOfType("BrickSolidTopRight", 2, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolidTop" in tile_name:
    setRandomTileNameOfType("BrickSolidTop", 8, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolidBot" in tile_name:
    setRandomTileNameOfType("BrickSolidBot", 9, cell_index, tile_orientation, 0, glitch_type)
  elif "BrickSolid" in tile_name:
    setRandomTileNameOfType("BrickSolid", 8, cell_index, tile_orientation, 0, glitch_type, debug)
  elif "CloudSemisolidTop" in tile_name:
    setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index, tile_orientation)
  elif "CloudSemisolid" in tile_name:
    setRandomTileNameOfType("CloudSemisolid", 4, cell_index, tile_orientation)

func unrandomizeAllTiles():
  unrandomize_cell_indices = get_used_cells()
  unrandomize_cell_indices.shuffle()
  unrandomize_cell_index = 0
  is_unrandomizing = true

func unrandomizeTile(cell_index):
  var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
  #print("tile_type: " + str(tile_type))
  if tile_type == INVALID_CELL_ITEM:
    return false

  var tile_name = mesh_library.get_item_name(tile_type)
  #print("tile_name: " + str(tile_name))
  var tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
  if "BrickSolidRoof" in tile_name or "BrickSolidCeil" in tile_name:
    setTileNameNum("BrickSolidCeil", 0, cell_index, tile_orientation)
  elif "BrickSolid" in tile_name:
    setTileNameNum("BrickSolid", 0, cell_index, tile_orientation)
  elif "CloudSemisolid" in tile_name:
    setTileNameNum("CloudSemisolid", 0, cell_index, tile_orientation)
  #print("new tile_name: " + str(new_tile_name))
  #print("new tile_type: " + str(mesh_library.find_item_by_name(new_tile_name)))
  return true

func rerandomizeTile(cell_index, glitch_type):
  if unrandomizeTile(cell_index):
    randomizeTile(cell_index, glitch_type)  
  
func changeColorPalette(palette, _palette_alt = null):
  if override_palette == null:
    curr_palette = palette
  else:
    curr_palette = override_palette
    
  var item_list = mesh_library.get_item_list()
  for i in range(len(item_list)):
    var item_id = item_list[i]
    if item_id == INVALID_CELL_ITEM:
      continue
    var mesh = mesh_library.get_item_mesh(item_id)
    var tile_name = mesh_library.get_item_name(item_id)
    var material = mesh.get_material()
    var color_suffix = global.getColorSuffixFromTilesetType(my_tileset_type)
    if material is ShaderMaterial:
      if (color_suffix == "" and not "_" in tile_name) or (color_suffix in tile_name):
        material.set_shader_param("base_palette", curr_palette)
    # mesh.set_material(material)
    # mesh_library.set_item_mesh(item_id, mesh)

func removeTile(key, removeFromLevelZone = true):
  set_cell_item(key.x, key.y, key.z, -1)
  tile_dict.erase(key)
  if removeFromLevelZone:
    global.removeLevelZoneTile(level.getShortLevelName(), key)

func cloneTile(source, target):
  set_cell_item(target.x, target.y, target.z, get_cell_item(source.x, source.y, source.z))
  tile_dict[target] = tile_dict[source]
  # TODO(jaketrower): add to levelZone...

func properlySetTiles():
  var keys = tile_dict.keys()
  for i in range(len(keys)):
    var cell_index = keys[i]
    var tile_name = tile_dict[cell_index][0]
    var tile_orientation = tile_dict[cell_index][1]
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name), tile_orientation)

    if global.hasGottenLevelGeode:
      randomizeTile(cell_index, getRandomGlitchType())

func setTileset(tileset_type, properly_set_tiles = true):
  my_tileset_type = tileset_type
  level.setTorchSpriteFrame(0)
  if tileset_type == global.TilesetType.DUNGEON:
    green_palette = global.green_dungeon_palette
    red_palette = global.red_tidepool_palette
    yellow_palette = global.yellow_dungeon_palette
    black_palette = global.black_dungeon_palette
  elif tileset_type == global.TilesetType.HOUSE:
    # TODO(jaketrower): BE WARNED, this is a bit confusing, we are using glitch_type here to set the tileset type
    # and we named them "_green", etc. but it's more like "_forest" etc. 
    my_tileset_glitch_type = global.GlitchForm.FLOOR
    grey_palette = global.grey_palette_town
    green_palette = global.green_tidepool_palette
    # black_palette = global.black_palette_town
    black_palette = global.black_tidepool_palette
  elif tileset_type == global.TilesetType.FOREST:
    my_tileset_glitch_type = global.GlitchForm.FEATHER
  elif tileset_type == global.TilesetType.DESERT:
    my_tileset_glitch_type = global.GlitchForm.LADDER
    green_palette = global.green_tidepool_palette
  elif tileset_type == global.TilesetType.BEACH:
    my_tileset_glitch_type = global.GlitchForm.FEATHER
    grey_palette = global.tidepool_palette
    green_palette = global.green_tidepool_palette
    red_palette = global.red_tidepool_palette
    yellow_palette = global.yellow_tidepool_palette
    black_palette = global.black_tidepool_palette
  elif tileset_type == global.TilesetType.POISON_FOREST:
    my_tileset_glitch_type = global.GlitchForm.FEATHER
    grey_palette = global.black_palette
    green_palette = global.black_palette
    red_palette = global.black_palette
    yellow_palette = global.black_palette
    black_palette = global.black_palette
  elif tileset_type == global.TilesetType.ALIEN:
    my_tileset_glitch_type = global.GlitchForm.INVISIBLE
    black_palette = global.black_palette_alien
  elif tileset_type == global.TilesetType.GLITCH_WORLD:
    my_tileset_glitch_type = global.GlitchForm.WALK_THROUGH_WALLS
    level.setTorchSpriteFrame(3)

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
  changeColorPalette(red_palette, red_palette)
  properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.floorGlitch(red_palette)
  if backgroundLevelTiles: backgroundLevelTiles.floorGlitch(global.dark_red_palette)

func featherGlitch(_palette = null):
  changeColorPalette(green_palette, green_palette)
  properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.featherGlitch(green_palette)
  if backgroundLevelTiles: backgroundLevelTiles.featherGlitch(global.dark_green_palette)

func invisibleGlitch(_palette = null):
  changeColorPalette(black_palette, black_palette)
  properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(black_palette)
  if backgroundLevelTiles: backgroundLevelTiles.normalGlitch(global.dark_black_palette)
  
func ladderGlitch(_palette = null):
  changeColorPalette(yellow_palette, yellow_palette)
  properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.ladderGlitch(yellow_palette)
  if backgroundLevelTiles: backgroundLevelTiles.ladderGlitch(global.dark_yellow_palette)

func walkThroughWallsGlitch(_palette = null):
  changeColorPalette(white_palette, white_palette)
  properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(white_palette)
  if backgroundLevelTiles: backgroundLevelTiles.normalGlitch(global.dark_white_palette)
