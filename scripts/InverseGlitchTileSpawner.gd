extends Spatial

func _ready():
  set_process(true)

func _process(delta):
  if amITouchingGlitchTile(getLevelTiles()):
    for child in self.get_children():
      child.visible = true
  else:
    for child in self.get_children():
      child.visible = false

func amITouchingGlitchTile(currLevelTiles):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = 0
  
  var coords = currLevelTiles.world_to_map(Vector3(x, y, z))
  for i in [-1, 0, 1]:
    for j in [-1, 0, 1]:
      var tile_type = currLevelTiles.get_cell_item(coords.x + i, coords.y + j, coords.z)
      if currLevelTiles.isTileSpikes(tile_type):
        return true

  return false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles