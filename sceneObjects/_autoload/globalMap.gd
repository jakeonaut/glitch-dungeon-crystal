extends Spatial

var mapGrid = {}

func _ready():
  visible = false

var has_grid_been_constructed = false
func constructMapGrid():
  if global.memory["demo_mode"] > 0:
    var children = get_children()
    for i in range(len(children) - 1, -1, -1):
      var child_name = children[i].name
      if child_name != "PastoralScene" and child_name != "TutorialDungeon" and child_name != "FishingVillage" and child_name != "BubblegloopSwamp": # and child_name != "ToxicJungle" and child_name != "CricketCaves":
        var more_children = children[i].get_children()
        for j in range(len(more_children)):
          more_children[j].remove_from_group("LevelSprite")
        # children[i].queue_free()

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
  # print("THIS LEVEL AIN'T IN THE MAP YET")
  return null

func getRoomPathAtCoords(coords):
  var room = getRoomAtCoords(coords)
  if room != null:
    return room.path
  return null

func getRoomAtCoords(coords):
  if not has_grid_been_constructed:
    constructMapGrid()

  # print("new coords: " + str(coords) + ", " + str(int(coords.y)) + ", " + str(int(coords.x)))
  # annoying but these int casts are necessary. 
  if mapGrid.has(int(coords.y)):
    if mapGrid[int(coords.y)].has(int(coords.x)):
      # print(mapGrid[int(coords.y)][int(coords.x)])
      # print(mapGrid[int(coords.y)][int(coords.x)].path)
      return mapGrid[int(coords.y)][int(coords.x)]
  # print("printing mapGrid")
  # print(mapGrid)

  return null

# this supports blocking traversal in the map
func getRelativeRoomPath(coords, addendum):
  if addendum.x == 0 and addendum.y == 0: # why are you doing this func then
    return getRoomAtCoords(coords)

  var currRoom = getRoomAtCoords(coords)
  # putting the blockers here
  if addendum.x > 0 and not currRoom.can_nav_right:
    return null
  if addendum.x < 0 and not currRoom.can_nav_left:
    return null
  if addendum.y > 0 and not currRoom.can_nav_up:
    return null
  if addendum.y < 0 and not currRoom.can_nav_down:
    return null
  return getRoomPathAtCoords(coords + addendum)