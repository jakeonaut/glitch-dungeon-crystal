extends Spatial

var mapGrid = {}

func _ready():
  visible = false

var has_grid_been_constructed = false
func constructMapGrid():
  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")

  print(levelSprites)
  for levelSprite in levelSprites:
    var i = floor(levelSprite.global_transform.origin.y)
    var j = floor(levelSprite.global_transform.origin.x)
    if not mapGrid.has(i):
      mapGrid[i] = {}
    mapGrid[i][j] = levelSprite
  has_grid_been_constructed = true
  
func getCoords(of_path):
  if not has_grid_been_constructed:
    constructMapGrid()

  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")
  print(levelSprites)
  for levelSprite in levelSprites:
    if levelSprite.path == of_path:
      print(of_path)
      return levelSprite.global_transform.origin.floor()
  return Vector3(0, 0, 0)

func getRoomPathAtCoords(coords):
  if not has_grid_been_constructed:
    constructMapGrid()

  if mapGrid.has(coords.y):
    if mapGrid[coords.y].has(coords.x):
      return mapGrid[coords.y][coords.x].path
  # hopefully we have Haven2 sitting smack dab at 0_0 or else this will fail
  return mapGrid[0][0].path
