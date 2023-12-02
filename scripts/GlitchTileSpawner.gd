extends "GeodeSpawner.gd"

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

func isConditionActive():
    return not amITouchingGlitchTile(getLevelTiles())

# @override
func spawn(with_flare = true):
  .spawn(false)
  if (with_flare):
    spawnSound.play()
    spawnSound2.play()
    level.summonSmokeClouds(global_transform.origin, 10, false, true)



func amITouchingGlitchTile(currLevelTiles):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = 0
  
  var coords = currLevelTiles.world_to_map(Vector3(x, y, z))
  var tile_type = currLevelTiles.get_cell_item(coords.x, coords.y, coords.z)

  if currLevelTiles.isTileSpikes(tile_type):
    return true

  return false
