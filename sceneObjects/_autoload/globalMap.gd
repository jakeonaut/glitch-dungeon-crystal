extends Spatial

var mapGrid = {}

func _ready():
  visible = false

var has_grid_been_constructed = false
func constructMapGrid():
  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")

  for levelSprite in levelSprites:
    var i = int(levelSprite.global_transform.origin.y)
    var j = int(levelSprite.global_transform.origin.x)
    if not mapGrid.has(i):
      mapGrid[i] = {}
    mapGrid[i][j] = levelSprite
  has_grid_been_constructed = true
  
func getCoords(of_path):
  if not has_grid_been_constructed:
    constructMapGrid()

  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")
  for levelSprite in levelSprites:
    if levelSprite.path == of_path:
      print(levelSprite.path + ", " + of_path)
      var o = levelSprite.global_transform.origin
      return Vector3(int(o.x), int(o.y), int(o.z))
  return Vector3(0, 0, 0)

func getRoomPathAtCoords(coords):
  if not has_grid_been_constructed:
    constructMapGrid()

  # annoying but these int casts are necessary. 
  if mapGrid.has(int(coords.y)):
    if mapGrid[int(coords.y)].has(int(coords.x)):
      return mapGrid[int(coords.y)][int(coords.x)].path
  # hopefully we have Haven2 sitting smack dab at 0_0 or else this will fail
  return mapGrid[0][0].path
