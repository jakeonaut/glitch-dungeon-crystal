extends Spatial

var mapGrid = {}
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  visible = false

var has_grid_been_constructed = false
func constructMapGrid():
  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")

  # print("constructing Map Grid")
  for levelSprite in levelSprites:
    var i = int(levelSprite.global_transform.origin.y)
    var j = int(levelSprite.global_transform.origin.x)
    if not mapGrid.has(i):
      mapGrid[i] = {}
    # print("[" + str(i) + "][" + str(j) + "] = " + str(levelSprite.path))
    mapGrid[i][j] = levelSprite
  has_grid_been_constructed = true
  
func getCoords(of_path):
  if not has_grid_been_constructed:
    constructMapGrid()

  var levelSprites = get_tree().get_nodes_in_group("LevelSprite")
  for levelSprite in levelSprites:
    if levelSprite.path == of_path:
      var o = levelSprite.global_transform.origin
      return Vector3(int(o.x), int(o.y), int(o.z))
  print("THIS LEVEL AIN'T IN THE MAP YET")
  return null

func getRoomPathAtCoords(coords):
  if not has_grid_been_constructed:
    constructMapGrid()

  # print("new coords: " + str(coords) + ", " + str(int(coords.y)) + ", " + str(int(coords.x)))
  # annoying but these int casts are necessary. 
  if mapGrid.has(int(coords.y)):
    if mapGrid[int(coords.y)].has(int(coords.x)):
      # print(mapGrid[int(coords.y)][int(coords.x)])
      # print(mapGrid[int(coords.y)][int(coords.x)].path)
      return mapGrid[int(coords.y)][int(coords.x)].path
  # print("printing mapGrid")
  # print(mapGrid)

  return null

  # this allows each "area" to set its own default room.
  # var currPath = level.getLevelName()
  # var levelSprites = get_tree().get_nodes_in_group("LevelSprite")
  # for levelSprite in levelSprites:
  #   if levelSprite.path == currPath:
  #     var levelSpriteParent = levelSprite.get_node("..")
  #     if levelSpriteParent != self and levelSpriteParent.has_node("DefaultLevel"):
  #       return levelSpriteParent.get_node("DefaultLevel").path

  # # hopefully we have Haven2 sitting smack dab at 0_0 or else this will fail
  # return mapGrid[0][0].path
