extends CanvasLayer

# https://fede0d.github.io/blog/2016/02/07/Godot-Extra-Tips-2.html

# STORE THE SCENE PATH
var path = ""
var was_i_interrupted = false
var mapManagerRes = preload("res://sceneObjects/_autoload/globalMap.tscn")
var mapManager = null
onready var colorRect = get_node("ColorRect")

var time_max = 100 # msec
var current_scene = null
var adjacent_level_loaders = []
var adjacent_levels = []
enum RoomMap {
  EAST,
  WEST,
  NORTH,
  SOUTH,
}

onready var aniPlayer = get_node("AnimationPlayer")

func _ready():
  set_process(false) # no need to process when not background loading adjacent scenes...
  
  mapManager = mapManagerRes.instance()
  mapManager.visible = false
  self.add_child(mapManager)
  adjacent_level_loaders = [
    null, # RoomMap.EAST
    null, # RoomMap.WEST
    null, # RoomMap.NORTH
    null  # RoomMap.SOUTH
  ]
  adjacent_levels = [
    null, # RoomMap.EAST
    null, # RoomMap.WEST
    null, # RoomMap.NORTH
    null  # RoomMap.SOUTH
  ]

  var root = get_tree().get_root()
  current_scene = root.get_node("Game")
  self.path = current_scene.get_node("Viewport/level").getLevelName()
  startAdjacentLevelLoading()

func _process(_delta):
  # aniPlayer.playback_speed = global.time_dilation_multiplier
  var currentLoadingAdjacentLevelLoader = null
  var currentLoadingAdjacentLevelLoader_idx = null
  for i in len(adjacent_level_loaders):
    var adjacent_level_loader = adjacent_level_loaders[i]
    if adjacent_level_loader == null:
      continue
    else:
      currentLoadingAdjacentLevelLoader = adjacent_level_loader
      currentLoadingAdjacentLevelLoader_idx = i
      break
  
  if currentLoadingAdjacentLevelLoader == null:
    # no need to process anymore
    set_process(false)
    return

  var t = Time.get_ticks_msec()
  # Use "time_max" to control for how long we block this thread.
  while Time.get_ticks_msec() < t + time_max:
    # Poll your loader.
    var err = currentLoadingAdjacentLevelLoader.poll()

    if err == ERR_FILE_EOF: # Finished loading.
      # could you tell I used to be a Java programmer?
      adjacent_levels[currentLoadingAdjacentLevelLoader_idx] = currentLoadingAdjacentLevelLoader.get_resource().instance()
      adjacent_level_loaders[currentLoadingAdjacentLevelLoader_idx] = null
      break
    elif err == OK:
      pass # all good.
    else: # Error during loading.
      # show_error() # ruh roh
      adjacent_level_loaders[currentLoadingAdjacentLevelLoader_idx] = null
      break
  

func startAdjacentLevelLoading():
  if colorRect.material.get_shader_param("progress") > 0.5:
    reverse_fade()
  return

  # clear prev adjacent levels & loaders
  for i in len(adjacent_levels):
    var prev_adjacent_level = adjacent_levels[i]
    if prev_adjacent_level != null and prev_adjacent_level.get_node("Viewport/level").getLevelName() != self.path:
      prev_adjacent_level.queue_free()
    adjacent_levels[i] = null
    adjacent_level_loaders[i] = null

  # TODO, could possibly be more efficient if we see if a level that we are ABOUT to load 
  # was previously adjacent somewhere else... it could happen occasionally.

  # setup new adjacent level loaders
  var curr_coords = mapManager.getCoords(self.path)
  if curr_coords != null:
    var roomPath_east = mapManager.getRoomPathAtCoords(curr_coords + Vector3(1, 0, 0))
    if roomPath_east != null:
      adjacent_level_loaders[RoomMap.EAST] = ResourceLoader.load_interactive(roomPath_east)
    var roomPath_west = mapManager.getRoomPathAtCoords(curr_coords + Vector3(-1, 0, 0))
    if roomPath_west != null:
      adjacent_level_loaders[RoomMap.WEST] = ResourceLoader.load_interactive(roomPath_west)
    var roomPath_north = mapManager.getRoomPathAtCoords(curr_coords + Vector3(0, 1, 0))
    if roomPath_north != null:
      adjacent_level_loaders[RoomMap.NORTH] = ResourceLoader.load_interactive(roomPath_north)
    var roomPath_south = mapManager.getRoomPathAtCoords(curr_coords + Vector3(0, -1, 0))
    if roomPath_south != null:
      adjacent_level_loaders[RoomMap.SOUTH] = ResourceLoader.load_interactive(roomPath_south)
    set_process(true) # so that we can "interactively load"

# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func edge_fade_to(scn_path):
  long_fade_to(scn_path)
  return

  # aniPlayer.play("long_fade_no_change", -1, 2.0) # play the long transition animation
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  if global.roomEdgeVector != null:
    var root = get_node("/root")
    var adjacentLevelIdx = 0
    if global.roomEdgeVector.x == 1:
      adjacentLevelIdx = RoomMap.EAST
    elif global.roomEdgeVector.x == -1:
      adjacentLevelIdx = RoomMap.WEST
    elif global.roomEdgeVector.y == 1:
      adjacentLevelIdx = RoomMap.NORTH
    elif global.roomEdgeVector.y == -1:
      adjacentLevelIdx = RoomMap.SOUTH
    if adjacent_levels[adjacentLevelIdx] != null:
      root.remove_child(current_scene)
      current_scene.queue_free()
      current_scene = adjacent_levels[adjacentLevelIdx]
      root.add_child(current_scene)
      global.memory["currLevelZone"] = global.currLevelZone
      global.set_camera_position_on_respawn = true
      startAdjacentLevelLoading()
      return
  change_scene() # TODO(jaketrower): still need to update what we're doing here, by shifting one of the adjacent levels into the currently active one
           # rather than just completely change_sceneing ...??

func quick_hide():
  aniPlayer.stop()
  aniPlayer.play("quick_hide")

func die_fade_to(scn_path):
  long_fade_to(scn_path)
  # was_i_interrupted = false
  # self.path = scn_path # store the scene path
  # change_scene()

# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func granny_teleport_to(scn_path):
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  aniPlayer.stop()
  aniPlayer.play("granny_teleport", -1, 1.0)
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func fast_fade_to(scn_path):
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  aniPlayer.stop()
  aniPlayer.play("long_fade", -1, 2.0) # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func long_fade_to(scn_path):
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  aniPlayer.stop()
  aniPlayer.play("long_fade") # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func really_long_fade_to(scn_path):
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  aniPlayer.stop()
  aniPlayer.play("long_fade", -1, 0.5) # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func really_really_long_fade_to(scn_path):
  was_i_interrupted = false
  self.path = scn_path # store the scene path
  aniPlayer.stop()
  aniPlayer.play("really_long_fade")

func interrupt():
  was_i_interrupted = true
  aniPlayer.stop()
  aniPlayer.seek(0, true)

# PRIVATE FUNCTION. CALLED AT THE MIDDLE OF THE TRANSITION ANIMATION
func change_scene():
  if was_i_interrupted:
    was_i_interrupted = false
    return

  global.memory["currLevelZone"] = global.currLevelZone
  global.set_camera_position_on_respawn = true

  if self.path != "":
    var root = get_tree().get_root()
    root.remove_child(current_scene)
    current_scene.queue_free()
    var loadedRoomResource = load(self.path)
    if loadedRoomResource == null:
      # a fallback
      loadedRoomResource = load("res://levels/EndlessFantasy/gd1TutorialDungeon/0_1Haven.tscn")
    var newScene = loadedRoomResource.instance()
    root.add_child(newScene)
    current_scene = newScene
    startAdjacentLevelLoading()
  else:
    global.pauseGame = false
    
  if global.activeThrowableObject:
    global.activeThrowableObjectPath = global.activeThrowableObject.filename

func unpause():
  global.pauseGame = false

func fast_reverse_fade():
  aniPlayer.stop()
  aniPlayer.play("reverse_fade", -1, 2.0)
func reverse_fade():
  aniPlayer.stop()
  aniPlayer.play("reverse_fade")
func reverse_granny_teleport():
  aniPlayer.stop()
  aniPlayer.play("reverse_granny_teleport")
