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
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var tile_dict = {}
var infected_spikes = []
var reappearing_spikes = []
var infected_soft_sand = []
var dissolving_stones = []
var transient_tiles = []
var transient_time_limit = 20
var soft_sand_infection_timer = 0
var soft_sand_infection_time_limit = 10
var spike_infection_timer = 0
var spike_infection_time_limit = 5
var reappear_spike_infection_timer = 0
var reappear_spike_infection_time_limit = 5
var stone_corrosion_timer = 0
var stone_corrosion_time_limit = 5
var my_tileset_type = global.TilesetType.DUNGEON
var my_tileset_glitch_type = global.GlitchForm.NORMAL

func setRandomTileNameOfType(newName, num_rand, cell_index, tile_orientation, offset = 0, glitch_type = global.GlitchForm.NORMAL, debug = false):
  if "Cloud" in newName or "cloud" in newName:
    return
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

  if not "FragileBrickSolid" in newName and not "TransparentGlitchTile" in newName:
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

func arrayDifference(arr1, arr2):
    var only_in_arr1 = []
    for v in arr1:
        if not (v in arr2):
            only_in_arr1.append(v)
    return only_in_arr1

var sausage_fading_timer = 0
var sausage_fading_time_limit = 1
var sausage_fading_away_indices = []
var fading_in_sausage_indices = []
var sausageNewLevelTiles = null
func queueSausageDreamFadeAwayDifference(newLevelTiles, should_fade_away = true, newLevelTiles_usedCells = null):
  if newLevelTiles_usedCells == null:
    newLevelTiles_usedCells = newLevelTiles.get_used_cells()
  # TODO(jaketrower): Should randomize the order of each of these arrays
  if should_fade_away:
    sausage_fading_away_indices = arrayDifference(
      self.get_used_cells(), newLevelTiles.get_used_cells()
    )
    sausage_fading_away_indices.shuffle()
  fading_in_sausage_indices = arrayDifference(
    newLevelTiles.get_used_cells(), self.get_used_cells()
  )
  fading_in_sausage_indices.shuffle()
  sausageNewLevelTiles = newLevelTiles

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
  elif tile_name == "FragileBrickSolid":
    setRandomTileNameOfType("FragileBrickSolid", 8, cell_index, tile_orientation, 0)
  elif tile_name == "BrickSolid":
    var skip_level_top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+2, cell_index.z)
    var skip_top_name = mesh_library.get_item_name(skip_level_top_neighbor_tile_type) if skip_level_top_neighbor_tile_type != -1 else ""
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    var top_name = mesh_library.get_item_name(top_neighbor_tile_type) if top_neighbor_tile_type != -1 else ""
    var bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-1, cell_index.z)
    var _bottom_name = mesh_library.get_item_name(bottom_neighbor_tile_type) if bottom_neighbor_tile_type != -1 else ""
    var skip_level_bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-2, cell_index.z)
    
    # DESERT MODIFICATION
    # if my_tileset_type == global.TilesetType.DESERT:
    #   skip_level_top_neighbor_tile_type = top_neighbor_tile_type
    #   skip_top_name = top_name
    #   skip_level_bottom_neighbor_tile_type = bottom_neighbor_tile_type

    # no top neighbor
    if (top_neighbor_tile_type == -1 or "Cloud" in top_name or "Spike" in top_name) and (skip_level_top_neighbor_tile_type == -1 or "Cloud" in skip_top_name or "Spike" in skip_top_name):
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
      # if my_tileset_type == global.TilesetType.DESERT:
      #   skip_level_bottom_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y-2, cell_index.z)
      #   if skip_level_bottom_neighbor_tile_type != -1: # we have a skip level bottom... neighbor...
      #     var new_index = Vector3(cell_index.x, cell_index.y-1, cell_index.z)
      #     setRandomTileNameOfType("BrickSolidBot", 9, new_index, tile_orientation, 0, glitch_type)
      #     var type = get_cell_item(new_index.x, new_index.y, new_index.z)
      #     if type != INVALID_CELL_ITEM:
      #       var name = mesh_library.get_item_name(type)
      #       tile_dict[new_index] = [name, tile_orientation]
    else:
      setRandomTileNameOfType("BrickSolid", 8, cell_index, tile_orientation, 0, glitch_type)
  elif tile_name == "CloudSemisolid":
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    if top_neighbor_tile_type == -1: # no top neighbor
      setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index, tile_orientation, 0)
    else:
      setRandomTileNameOfType("CloudSemisolid", 4, cell_index, tile_orientation, 0)
  elif tile_name == "PinkCloudSemisolid":
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    if top_neighbor_tile_type == -1: # no top neighbor
      setRandomTileNameOfType("PinkCloudSemisolid", 1, cell_index, tile_orientation, 0)
      setRandomTileNameOfType("PinkCloudSemisolidTop", 1, Vector3(cell_index.x, cell_index.y+1, cell_index.z), tile_orientation, 0)
      
  elif tile_name == "Spikes":
    var top_neighbor_tile_type = get_cell_item(cell_index.x, cell_index.y+1, cell_index.z)
    if top_neighbor_tile_type == -1: # no top neighbor
      setRandomTileNameOfType("CloudSemisolidTop", 4, cell_index, tile_orientation, 0)
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
    pass
    # var left_neighbor_tile_type = get_cell_item(cell_index.x-1, cell_index.y, cell_index.z)
    # var right_neighbor_tile_type = get_cell_item(cell_index.x+1, cell_index.y, cell_index.z)
    # if left_neighbor_tile_type == -1 and right_neighbor_tile_type == -1: # no left or right neighbors
    # setRandomTileNameOfType("GlitchSpikes", 5, cell_index, tile_orientation) # 5, but 0 indexed...
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
var DISSOLVING_STONE1 = 325
var DISSOLVING_STONE2 = 326
var DISSOLVING_STONE3 = 327

func getRandomGlitchType():
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE:
    return level.player.glitch_form if level.player.glitch_form != global.GlitchForm.FLOOR else global.GlitchForm.NORMAL
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

  if sausageNewLevelTiles != null and (sausage_fading_away_indices.size() > 0 or fading_in_sausage_indices.size() > 0):
    sausage_fading_timer += (delta*22)
    if sausage_fading_timer >= sausage_fading_time_limit:
      sausage_fading_timer = 0
      if sausage_fading_away_indices.size() > 0:
        var cell_index = sausage_fading_away_indices.pop_back()
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, -1)
      elif fading_in_sausage_indices.size() > 0:
        var cell_index = fading_in_sausage_indices.pop_back()
        var item = sausageNewLevelTiles.get_cell_item(cell_index.x, cell_index.y, cell_index.z)
        set_cell_item(cell_index.x, cell_index.y, cell_index.z, item)
        randomizeTile(cell_index, getRandomGlitchType())
      else:
        # TODO(jaketrower): FADE OUT GAME MOVERS, GameMovers in new scene can have .should_fade_in = true
        pass

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
  
  # if global.memory["priestess"] >= 2:
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    randomize_timer = randomize_time_limit
    randomize_num_counter = 0
    randomize_num = 1
  if randomize_timer >= randomize_time_limit and tile_dict.size() > 0:
    randomize_timer = 0
    if randomize_num > tile_dict.keys().size():
      for i in range(tile_dict.keys().size()):
          randomizeTile(tile_dict.keys()[i], getRandomGlitchType())
    else:
      for _i in range(randomize_num):
        var rand_key = tile_dict.keys()[randi() % tile_dict.size()]
        randomizeTile(rand_key, getRandomGlitchType())
      randomize_num += randomize_num_counter
  # TODO(jaketrower): if we want color palette changing to happen over time, it should happen here

  if global.isPauseMenuOpen: return

  var num_dissolving_stones = len(dissolving_stones)
  if num_dissolving_stones > 0:
    stone_corrosion_timer += (delta*22)
    if stone_corrosion_timer >= stone_corrosion_time_limit:
      stone_corrosion_timer = 0
      for _i in range(num_dissolving_stones):
        var coords = dissolving_stones.pop_front()
        var tile_type = get_cell_item(coords.x, coords.y, coords.z)
        var tile_name = mesh_library.get_item_name(tile_type)
        if tile_name == "DissolvingStone1":
          set_cell_item(coords.x, coords.y, coords.z, DISSOLVING_STONE2)
        elif tile_name == "DissolvingStone2":
          set_cell_item(coords.x, coords.y, coords.z, DISSOLVING_STONE3)
        elif tile_name == "DissolvingStone3":
          set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)

  # process infected tiles, and spread infection.
  var num_infected_spikes = len(infected_spikes)
  if num_infected_spikes > 0:
    spike_infection_timer += (delta*22)
    if spike_infection_timer >= spike_infection_time_limit: 
      spike_infection_timer = 0
      global.incrementLevelZoneGlitchTiles(num_infected_spikes) # hm...
      if global.memory["glitch_world"] == 0:
        tryToSayTidy()
      for _i in range(num_infected_spikes):
        var coords = infected_spikes.pop_front()
        if global.memory["glitch_world"] > 0:
          reappearing_spikes.push_back(coords)
        else:
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

  var num_reappearing_spikes = len(reappearing_spikes)
  if num_reappearing_spikes > 0:
    reappear_spike_infection_timer += (delta*22)
    if reappear_spike_infection_timer >= reappear_spike_infection_time_limit:
      reappear_spike_infection_timer = 0
      for _i in range(num_reappearing_spikes):
        var coords = reappearing_spikes.pop_front()
        reappearSpikes(coords)

  
  var num_infected_soft_sand = len(infected_soft_sand)
  if num_infected_soft_sand > 0:
    soft_sand_infection_timer += (delta*22)
    if soft_sand_infection_timer >= soft_sand_infection_time_limit: 
      soft_sand_infection_timer = 0
      # global.incrementLevelZoneGlitchTiles(num_infected_soft_sand)
      # tryToSayTidy()
      for _i in range(num_infected_soft_sand):
        var coords = infected_soft_sand.pop_front()
        var top_neighbor_coords = Vector3(coords.x, coords.y + 1, coords.z)
        var bottom_neighbor_coords = Vector3(coords.x, coords.y - 1, coords.z)
        var left_neighbor_coords = Vector3(coords.x - 1, coords.y, coords.z)
        var right_neighbor_coords = Vector3(coords.x + 1, coords.y, coords.z)
        infectSoftSand(top_neighbor_coords)
        infectSoftSand(bottom_neighbor_coords)
        infectSoftSand(left_neighbor_coords)
        infectSoftSand(right_neighbor_coords)
        var top_left_neighbor_coords = Vector3(coords.x - 1, coords.y + 1, coords.z)
        var bottom_right_neighbor_coords = Vector3(coords.x + 1, coords.y - 1, coords.z)
        var bottom_left_neighbor_coords = Vector3(coords.x - 1, coords.y - 1, coords.z)
        var top_right_neighbor_coords = Vector3(coords.x + 1, coords.y + 1, coords.z)
        infectSoftSand(top_left_neighbor_coords)
        infectSoftSand(bottom_right_neighbor_coords)
        infectSoftSand(bottom_left_neighbor_coords)
        infectSoftSand(top_right_neighbor_coords)

  # process transient tiles. no spread.
  for i in range(len(transient_tiles)-1, -1, -1):
    var coords = transient_tiles[i][0]
    var transient_tile_time = transient_tiles[i][1]
    transient_tile_time += (delta*11)
    transient_tiles[i][1] = transient_tile_time
    if transient_tile_time >= transient_time_limit:
      # TODO(jaketrower): If you want to only TEMPORARILY clear spikes, use this
      # self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
      # TODO(jaketrower): Otherwise, use this
      removeTile(coords)
      var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
      level.summonSmokeClouds(tile_pos, 1, false, false)
      musicPlayer.leavesSound.play()
      transient_tiles.pop_at(i)


func isNeighborOfInfectedSpikes(neighborCoords):
  var num_infected_spikes = len(infected_spikes)
  for i in range(num_infected_spikes):
    var infectedCoords = infected_spikes[i]
    if neighborCoords.x <= infectedCoords.x + 1 and neighborCoords.x >= infectedCoords.x - 1 and \
       neighborCoords.y <= infectedCoords.y + 1 and neighborCoords.y >= infectedCoords.y - 1:
      return true
  return false

func tryToSayTidy():
  var spike_id_array = [51, 52, 53, 54, 55]
  for spike_id in spike_id_array:
    if get_used_cells_by_item(spike_id).size() > 0:
      return

  if level.get_tree().get_nodes_in_group("weak_enemies").size() > 0:
    return
  if level.get_tree().get_nodes_in_group("enemies").size() > 0:
    return
  
  level.displayMessageText(tr("UI.Alert.2"))

func isTileSolid(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tileShape = mesh_library.get_item_shapes(tile_type)
  if tileShape == null or tileShape.size() == 0:
    return false
  var tileCollisionShape = tileShape[0]
  var tile_name = mesh_library.get_item_name(tile_type)
  return tileCollisionShape is BoxShape and not "Spikes" in tile_name

func isTileFragileSolid(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "Fragile" in tile_name

func isTileDissolvingStone(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "DissolvingStone" in tile_name

func isTileSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "Spikes" in tile_name and not "GlitchSpikes" in tile_name

func isTileGlitchSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "GlitchSpikes" in tile_name

func isTileSoftSand(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "SoftSand" in tile_name

func isTileCloud(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return "PinkCloud" in tile_name
  
func infectSpikes(coords, play_sound = true):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  var did_infect_spikes = false
  if isTileSpikes(tile_type):
    infected_spikes.append(coords)
    
    # TODO(jaketrower): If you want to only TEMPORARILY clear spikes, use this
    if global.memory["glitch_world"] > 0:
      self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
    else:
      removeTile(coords)

    var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
    level.summonSmokeClouds(tile_pos, 2, play_sound, true)
    did_infect_spikes = true
  spike_infection_timer = 0
  return did_infect_spikes

func reappearSpikes(coords, play_sound = true):
  setRandomTileNameOfType("Spikes", 5, coords, 0)
  var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
  level.summonSmokeClouds(tile_pos, 1, play_sound, true)


func infectSoftSand(coords, play_sound = true):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  var did_infect_spikes = false
  if isTileSoftSand(tile_type):
    infected_soft_sand.append(coords)
    
    # clear it only for this instance of the room, as this will likely only be used for ClaydolBoss... ??
    self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)

    var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
    level.summonSmokeClouds(tile_pos, 2, play_sound, true)
    did_infect_spikes = true
  soft_sand_infection_timer = 0
  return did_infect_spikes

func corrode(coords):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  if isTileDissolvingStone(tile_type) and not coords in dissolving_stones:
    dissolving_stones.append(coords)

# probably a more efficient way to do this rather than polling all used cells... see infect spikes check somewhere above
func purifyAllSpikes():
  var cell_indices = get_used_cells()
  for i in range(len(cell_indices)):
    var cell_index = cell_indices[i]
    var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
    if isTileSpikes(tile_type):
      removeTile(cell_index)
      var tile_pos = self.map_to_world(cell_index.x, cell_index.y, cell_index.z)
      level.summonSmokeClouds(tile_pos, 2, false, true)
func purifyAllFragileBrickSolids(summon_smoke_clouds = true):
  var cell_indices = get_used_cells()
  for i in range(len(cell_indices)):
    var cell_index = cell_indices[i]
    var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
    var tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
    if isTileFragileSolid(tile_type):
      # removeTile(cell_index)
      setTileNameNum("TransparentGlitchTile", 0, cell_index, tile_orientation, global.GlitchForm.NORMAL)
      var tile_pos = self.map_to_world(cell_index.x, cell_index.y, cell_index.z)
      if summon_smoke_clouds:
        level.summonSmokeClouds(tile_pos, 2, false, true)
func purifyAllSoftSandSolids(summon_smoke_clouds = true):
  var cell_indices = get_used_cells()
  for i in range(len(cell_indices)):
    var cell_index = cell_indices[i]
    var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
    if isTileSoftSand(tile_type):
      removeTile(cell_index)
      var tile_pos = self.map_to_world(cell_index.x, cell_index.y, cell_index.z)
      if summon_smoke_clouds:
        level.summonSmokeClouds(tile_pos, 2, false, true)

func breakFragile(coords, play_sound = true):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  if isTileFragileSolid(tile_type):
    # TODO(jaketrower): If you want to only TEMPORARILY clear spikes, use this
    # self.set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
    # TODO(jaketrower): Otherwise, use this
    removeTile(coords)

    var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
    level.summonSmokeClouds(tile_pos, 2, play_sound, true)
    return true

func sweepUpSand(coords):
  var tile_type = self.get_cell_item(coords.x, coords.y, coords.z)
  if isTileSoftSand(tile_type):
    removeTile(coords, false)

    var tile_pos = self.map_to_world(coords.x, coords.y, coords.z)
    level.summonSmokeClouds(tile_pos, 2, false, false, global.yellow_palette)
  spike_infection_timer = 0

func addTile(tile_id, target, _addToLevelZone = true, is_transient = false, transient_time_start = 0):
  set_cell_item(target.x, target.y, target.z, tile_id)
  randomizeTile(target, my_tileset_glitch_type)
  var name = mesh_library.get_item_name(tile_id)
  tile_dict[target] = [name, 0]
  if is_transient:
    transient_tiles.append([target, transient_time_start])
  else:
    # TODO(jaketrower): add to levelZone...
    pass

func removeTile(key, removeFromLevelZone = true):
  set_cell_item(key.x, key.y, key.z, -1)
  tile_dict.erase(key)
  if removeFromLevelZone:
    global.removeLevelZoneTile(level.getShortLevelName(), key)

func cloneTile(source, target, is_transient = false, transient_time_start = 0):
  set_cell_item(target.x, target.y, target.z, get_cell_item(source.x, source.y, source.z))
  randomizeTile(target, my_tileset_glitch_type)
  tile_dict[target] = tile_dict[source]
  if is_transient:
    transient_tiles.append([target, transient_time_start])
  else:
    # TODO(jaketrower): add to levelZone...
    pass

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
  if "FragileBrickSolid" in tile_name:
    setRandomTileNameOfType("FragileBrickSolid", 8, cell_index, tile_orientation, 0)
  elif "BrickSolidRoof" in tile_name:
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
  elif "PinkCloudSemisolid" in tile_name:
    setRandomTileNameOfType("PinkCloudSemisolid", 1, cell_index, tile_orientation)
  elif "PinkCloudSemisolidTop" in tile_name:
    setRandomTileNameOfType("PinkCloudSemisolidTop", 1, cell_index, tile_orientation) 
  elif "SoftSandTop" in tile_name:
    setRandomTileNameOfType("SoftSandTop", 2, cell_index, tile_orientation) 

func unrandomizeAllTiles():
  unrandomize_cell_indices = get_used_cells()
  unrandomize_cell_indices.shuffle()
  unrandomize_cell_index = 0
  is_unrandomizing = true

func unrandomizeTile(cell_index):
  var tile_type = get_cell_item(cell_index.x, cell_index.y, cell_index.z)
  if tile_type == INVALID_CELL_ITEM:
    return false

  var tile_name = mesh_library.get_item_name(tile_type)
  var tile_orientation = get_cell_item_orientation(cell_index.x, cell_index.y, cell_index.z)
  if "FragileBrickSolid" in tile_name:
    setTileNameNum("FragileBrickSolid", 0, cell_index, tile_orientation)
  elif "BrickSolidRoof" in tile_name or "BrickSolidCeil" in tile_name:
    setTileNameNum("BrickSolidCeil", 0, cell_index, tile_orientation)
  elif "BrickSolid" in tile_name:
    setTileNameNum("BrickSolid", 0, cell_index, tile_orientation)
  elif "CloudSemisolid" in tile_name:
    setTileNameNum("CloudSemisolid", 0, cell_index, tile_orientation)
  return true

var rand_tile_timers = []
func clearRandomTileTimers():
  while len(rand_tile_timers) > 0:
    var randTileTimerRef = rand_tile_timers.pop_back()
    if randTileTimerRef and randTileTimerRef.get_ref():
      randTileTimerRef.get_ref().queue_free()

func rerandomizeTile(cell_index, glitch_type, rand_timer = false):
  if rand_timer: 
    var timer = Timer.new() # get_tree().create_timer(rand_range(0, 1))
    add_child(timer)
    timer.wait_time = rand_range(0, 1)
    timer.one_shot = true
    timer.start()
    timer.connect("timeout", self, "rerandomizeTile", [ cell_index, glitch_type, false ])
    rand_tile_timers.push_back(weakref(timer))
    return
  if unrandomizeTile(cell_index):
    randomizeTile(cell_index, glitch_type)
  
export var can_change_color = true
func changeColorPalette(palette, _palette_alt = null):
  if (
     my_tileset_type == global.TilesetType.DUNGEON or
     my_tileset_type == global.TilesetType.BEACH or
     my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or
     global.memory["glitch_world"] > 0
  ):
    if not can_change_color:
      curr_palette = override_palette if override_palette != null else grey_palette
    elif override_palette == null or palette != grey_palette:
      curr_palette = palette
    else:
      curr_palette = override_palette
  elif my_tileset_type == global.TilesetType.FOREST:
    curr_palette = global.green_tidepool_palette
  elif my_tileset_type == global.TilesetType.AUTUMN_FOREST:
    curr_palette = global.red_palette
  elif my_tileset_type == global.TilesetType.DESERT:
    curr_palette = global.yellow_palette
  elif my_tileset_type == global.TilesetType.POISON_FOREST:
    curr_palette = global.grey_black_palette
  elif my_tileset_type == global.TilesetType.ALIEN:
    curr_palette = global.red_palette
    
  var item_list = mesh_library.get_item_list()
  for i in range(len(item_list)):
    var item_id = item_list[i]
    if item_id == INVALID_CELL_ITEM:
      continue
    if isTileFragileSolid(item_id):
      continue
    var mesh = mesh_library.get_item_mesh(item_id)
    var tile_name = mesh_library.get_item_name(item_id)
    if tile_name == "GlitchSpikes" or "Pink" in tile_name:
      continue
    var palette_to_use = curr_palette
    # if "Fragile" in tile_name:
    #   palette_to_use = white_palette

    var material = mesh.surface_get_material(0)
    var color_suffix = global.getColorSuffixFromTilesetType(my_tileset_type)
    if material != null and material is SpatialMaterial:
      var next_material = material.next_pass
      if next_material != null and next_material is ShaderMaterial:
        if (color_suffix == "" and not "_" in tile_name) or (color_suffix in tile_name):
          next_material.set_shader_param("base_palette", palette_to_use)
    # mesh.set_material(material)
    # mesh_library.set_item_mesh(item_id, mesh)

func properlySetTiles():
  var keys = tile_dict.keys()
  for i in range(len(keys)):
    var cell_index = keys[i]
    var tile_name = tile_dict[cell_index][0]
    var tile_orientation = tile_dict[cell_index][1]
    set_cell_item(cell_index.x, cell_index.y, cell_index.z, mesh_library.find_item_by_name(tile_name), tile_orientation)

    # if global.hasGottenLevelGeode or global.memory["priestess"] >= 2:
    if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
      randomizeTile(cell_index, getRandomGlitchType())

func setTileset(tileset_type, properly_set_tiles = true):
  my_tileset_type = tileset_type
  level.setTorchSpriteFrame(0)
  if tileset_type == global.TilesetType.DUNGEON:
    green_palette = global.green_dungeon_palette
    red_palette = global.red_tidepool_palette
    yellow_palette = global.yellow_dungeon_palette
    black_palette = global.black_dungeon_palette
  elif tileset_type == global.TilesetType.PRIMORDIAL_OOZE:
    my_tileset_glitch_type = level.player.glitch_form
  elif tileset_type == global.TilesetType.HOUSE:
    # TODO(jaketrower): BE WARNED, this is a bit confusing, we are using glitch_type here to set the tileset type
    # and we named them "_green", etc. but it's more like "_forest" etc. 
    my_tileset_glitch_type = global.GlitchForm.FLOOR
    grey_palette = global.grey_palette_town
    green_palette = global.green_tidepool_palette
    # black_palette = global.black_palette_town
    black_palette = global.black_tidepool_palette
  elif tileset_type == global.TilesetType.POISON_HOUSE:
    my_tileset_glitch_type = global.GlitchForm.FLOOR
    grey_palette = global.grey_black_palette
    green_palette = global.green_black_palette
    red_palette = global.red_black_palette
    yellow_palette = global.yellow_black_palette
    black_palette = global.black_palette
  elif tileset_type == global.TilesetType.FOREST or tileset_type == global.TilesetType.AUTUMN_FOREST:
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
    grey_palette = global.grey_black_palette
    green_palette = global.green_black_palette
    red_palette = global.red_black_palette
    yellow_palette = global.yellow_black_palette
    black_palette = global.black_palette
  elif tileset_type == global.TilesetType.ALIEN:
    my_tileset_glitch_type = global.GlitchForm.INVISIBLE
    # black_palette = global.black_palette_alien
  elif tileset_type == global.TilesetType.GLITCH_WORLD:
    my_tileset_glitch_type = global.GlitchForm.WALK_THROUGH_WALLS
    level.setTorchSpriteFrame(3)

  if properly_set_tiles:
    properlySetTiles()
    
  if cosmeticLevelTiles:
    cosmeticLevelTiles.setTileset(tileset_type, properly_set_tiles)

func normalGlitch(_palette = null):
  return
  # set_mesh_library(grey_tiles)
  changeColorPalette(grey_palette, grey_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(global.dark_grey_palette)

func floorGlitch(_palette = null):
  return
  changeColorPalette(red_palette, red_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.floorGlitch(global.dark_red_palette)

func featherGlitch(_palette = null):
  return
  changeColorPalette(green_palette, green_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.featherGlitch(global.dark_green_palette)

func invisibleGlitch(_palette = null):
  return
  changeColorPalette(black_palette, black_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(global.dark_black_palette)
  
func ladderGlitch(_palette = null):
  return
  changeColorPalette(yellow_palette, yellow_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.ladderGlitch(global.dark_yellow_palette)

func walkThroughWallsGlitch(_palette = null):
  return
  changeColorPalette(white_palette, white_palette)
  if my_tileset_type == global.TilesetType.PRIMORDIAL_OOZE or global.memory["glitch_world"] > 0:
    properlySetTiles()
  if cosmeticLevelTiles: cosmeticLevelTiles.normalGlitch(global.dark_white_palette)
