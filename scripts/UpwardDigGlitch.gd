extends Spatial

export var how_many_tiles = 4
export var my_up_vector = Vector2(0, 1)
export var should_erase = false
onready var sprite = get_node("Sprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var dig_timer = 0
var dig_time_limit = 5
var dig_counter = 0

func _ready():
  sprite.visible = false

func _process(delta):
  if not visible:
    return

  dig_timer += (delta*22)
  if dig_timer >= dig_time_limit:
    dig_timer = 0

    if my_up_vector.y == 1:
      digTiles(getTilesBelow(level.levelTiles, 0.1, true), true)
    elif my_up_vector.y == -1:
      digTiles(getTilesAbove(level.levelTiles, 0.1, true), true)
    elif my_up_vector.x == 1:
      digTiles(getTilesLeftOf(level.levelTiles, 0.5, true), true)
    elif my_up_vector.x == -1:
      digTiles(getTilesRightOf(level.levelTiles, 0.1, true), true)

    if dig_counter >= how_many_tiles:
      queue_free()

var permanently_alter_tiles = false
func digTiles(solidTiles, should_summon_clouds):
  var x_add = 0
  var y_add = 1
  if my_up_vector.y == -1:
    y_add = -1
  elif my_up_vector.x == 1:
    x_add = 1
    y_add = 0
  elif my_up_vector.x == -1:
    x_add = -1
    y_add = 0
  var tiles_dug = 0
  if solidTiles[0] != null:
    var coords_a = solidTiles[0]
    var tile_type = level.levelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)
    level.levelTiles.addTile(tile_type, Vector3(coords_a.x + x_add, coords_a.y + y_add, coords_a.z), permanently_alter_tiles, false)
    tiles_dug += 1
  if solidTiles[1] != null:
    var coords_mid = solidTiles[1]
    var tile_type = level.levelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)
    level.levelTiles.addTile(tile_type, Vector3(coords_mid.x + x_add, coords_mid.y + y_add, coords_mid.z), permanently_alter_tiles, false)
    tiles_dug += 1
  if solidTiles[2] != null:
    var coords_b = solidTiles[2]
    var tile_type = level.levelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)
    level.levelTiles.addTile(tile_type, Vector3(coords_b.x + x_add, coords_b.y + y_add, coords_b.z), permanently_alter_tiles, false)
    tiles_dug += 1

  var tileSize = 8*.125
  if level.player.checkSolidTilesOnMe():
    if my_up_vector.y == 1:
      level.player.global_transform.origin.y += tileSize
    elif my_up_vector.y == -1:
      level.player.global_transform.origin.y -= tileSize
    elif my_up_vector.x == 1:
      level.player.global_transform.origin.x += tileSize
    elif my_up_vector.x == -1:
      level.player.global_transform.origin.x -= tileSize

  if should_summon_clouds and tiles_dug > 0:
    level.summonSmokeClouds(global_transform.origin, 2)

  if tiles_dug > 0:
    dig_counter += 1
    if my_up_vector.y == 1:
      global_transform.origin.y += tileSize
    elif my_up_vector.y == -1:
      global_transform.origin.y -= tileSize
    elif my_up_vector.x == 1:
      global_transform.origin.x += tileSize
    elif my_up_vector.x == -1:
      global_transform.origin.x -= tileSize
              
  return tiles_dug > 0

export var lb = -0.72
export var rb = .72
export var tb = 1.0
export var bb = -1.0
func getTilesBelow(currLevelTiles, buffer = 0.1, ignore_just_give_me_coords = false):
  var solidTilesBelow = [null, null, null]
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  if currLevelTiles != null and lb != null and bb != null and rb != null and tb != null:
    var coords_a = currLevelTiles.world_to_map(Vector3(x + lb, y + bb - buffer, z))
    var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    var coords_b = currLevelTiles.world_to_map(Vector3(x + rb, y + bb - buffer, z))
    var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

    var coords_mid = currLevelTiles.world_to_map(Vector3(x, y + bb - buffer, z))
    var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

    if level.levelTiles.isTileSolid(tile_type_a) or ignore_just_give_me_coords:
      solidTilesBelow[0] = coords_a
    if level.levelTiles.isTileSolid(tile_type_mid) or ignore_just_give_me_coords:
      solidTilesBelow[1] = coords_mid
    if level.levelTiles.isTileSolid(tile_type_b) or ignore_just_give_me_coords:
      solidTilesBelow[2] = coords_b

  return solidTilesBelow

func getTilesAbove(currLevelTiles, buffer = 0.1, ignore_just_give_me_coords = false):
  var solidTilesAbove = [null, null, null]
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  if currLevelTiles != null and lb != null and bb != null and rb != null and tb != null:
    var coords_a = currLevelTiles.world_to_map(Vector3(x + lb, y + tb + buffer, z))
    var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    var coords_b = currLevelTiles.world_to_map(Vector3(x + rb, y + tb + buffer, z))
    var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

    var coords_mid = currLevelTiles.world_to_map(Vector3(x, y + tb + buffer, z))
    var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

    if level.levelTiles.isTileSolid(tile_type_a) or ignore_just_give_me_coords:
      solidTilesAbove[0] = coords_a
    if level.levelTiles.isTileSolid(tile_type_mid) or ignore_just_give_me_coords:
      solidTilesAbove[1] = coords_mid
    if level.levelTiles.isTileSolid(tile_type_b) or ignore_just_give_me_coords:
      solidTilesAbove[2] = coords_b

  return solidTilesAbove

func getTilesLeftOf(currLevelTiles, buffer = 0.5, ignore_just_give_me_coords = false):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  # this can be generalized...
  var coords_a = currLevelTiles.world_to_map(Vector3(x + lb - buffer, y + tb, z))
  var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

  var coords_b = currLevelTiles.world_to_map(Vector3(x + lb - buffer, y + bb, z))
  var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

  var coords_mid = currLevelTiles.world_to_map(Vector3(x + lb - buffer, y, z))
  var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

  var solidTilesLeftOf = [null, null, null]
  if level.levelTiles.isTileSolid(tile_type_a) or ignore_just_give_me_coords:
    solidTilesLeftOf[0] = coords_a
  if level.levelTiles.isTileSolid(tile_type_mid) or ignore_just_give_me_coords:
    solidTilesLeftOf[1] = coords_mid
  if level.levelTiles.isTileSolid(tile_type_b) or ignore_just_give_me_coords:
    solidTilesLeftOf[2] = coords_b

  return solidTilesLeftOf

func getTilesRightOf(currLevelTiles, buffer = 0.1, ignore_just_give_me_coords = false):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = global_transform.origin.z
  
  # this can be generalized...
  var coords_a = currLevelTiles.world_to_map(Vector3(x + rb + buffer, y + tb, z))
  var tile_type_a = currLevelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

  var coords_b = currLevelTiles.world_to_map(Vector3(x + rb + buffer, y + bb, z))
  var tile_type_b = currLevelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

  var coords_mid = currLevelTiles.world_to_map(Vector3(x + rb + buffer, y, z))
  var tile_type_mid = currLevelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

  var solidTilesRightOf = [null, null, null]
  if level.levelTiles.isTileSolid(tile_type_a) or ignore_just_give_me_coords:
    solidTilesRightOf[0] = coords_a
  if level.levelTiles.isTileSolid(tile_type_mid) or ignore_just_give_me_coords:
    solidTilesRightOf[1] = coords_mid
  if level.levelTiles.isTileSolid(tile_type_b) or ignore_just_give_me_coords:
    solidTilesRightOf[2] = coords_b

  return solidTilesRightOf
