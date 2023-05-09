extends InterpolatedCamera

var initial_z
onready var actual_target = weakref(get_node(target))
onready var initial_target = get_node(target)
onready var realCamera = get_node("RealCamera")

var leftmost_x = 999
var rightmost_x = -999
var topmost_y = -999
var botmost_y = 999
var initial_size = 15
var start_applying_parallax = false
var how_fast_to_switch_targets = 1
export var is_doing_fake_static = false

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = get_tree().get_root().get_node("Game/Viewport/level").levelTiles
  return levelTiles

func _ready():
  initial_size = self.size
  if global.memory.has("cameraSize"):
    self.size = global.memory["cameraSize"]
  initial_z = global_transform.origin.z
  
  # Wait two frames so that levelTiles on levelScript is available
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")

  is_doing_fake_static = false

  if initial_target != null:
    if initial_target.has_node("CameraTarget"):
      initial_target = initial_target.get_node("CameraTarget")
    setCameraPositionNow()
  start_applying_parallax = true

  
  var tile_coords = getLevelTiles().get_used_cells()
  
  for i in range(len(tile_coords)):
    var coords = tile_coords[i]
    var TILE_WIDTH = getLevelTiles().cell_size.x
    var TILE_HEIGHT = getLevelTiles().cell_size.y
    var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
    var tile_x = tile_pos.x - TILE_WIDTH/2
    var tile_y = tile_pos.y - TILE_HEIGHT/2

    if tile_x < leftmost_x:
      leftmost_x = tile_x
    if tile_x + TILE_WIDTH > rightmost_x:
      rightmost_x = tile_x + TILE_WIDTH
    if tile_y < botmost_y:
      botmost_y = tile_y
    if tile_y + TILE_HEIGHT > topmost_y:
      topmost_y = tile_y + TILE_HEIGHT
      
func setCameraPositionNow():
  global_transform.origin.x = initial_target.global_transform.origin.x
  global_transform.origin.y = initial_target.global_transform.origin.y

func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if not actual_target.get_ref():
    actual_target = weakref(initial_target)
    set_target(actual_target.get_ref())   

  global_transform.origin.z = initial_z
  # d=√((x_2-x_1)²+(y_2-y_1)²)
  var distance = global_transform.origin.distance_to(actual_target.get_ref().global_transform.origin)

  var speed_multiplier = 1
  if how_fast_to_switch_targets > 0:
    speed_multiplier = how_fast_to_switch_targets
    how_fast_to_switch_targets = how_fast_to_switch_targets + (1 - how_fast_to_switch_targets) * (delta * 0.1)
    if stepify(how_fast_to_switch_targets, 0.1) == 1.0:
      how_fast_to_switch_targets = 0
    
    
  if distance > 19.8:
    set_interpolation_enabled(true)
    set_speed(7 * speed_multiplier)
  elif distance > 19.7:
    set_interpolation_enabled(true)
    set_speed(5 * speed_multiplier)
  elif distance > 19.6:
    set_interpolation_enabled(true)
    set_speed(4 * speed_multiplier)
  elif distance > 19.5:
    set_interpolation_enabled(true)
    set_speed(3 * speed_multiplier)
  elif distance > 19.4:
    set_interpolation_enabled(true)
    set_speed(2 * speed_multiplier)
    if actual_target.get_ref() == initial_target: how_fast_to_switch_targets = 0
  elif distance < 19.33 and global.activeInteractor == null:
    set_interpolation_enabled(false)
    if actual_target.get_ref() == initial_target: how_fast_to_switch_targets = 0

  var zoomed_size = (initial_size-8)
  var npcTextBox = global.activeInteractor
  if npcTextBox != null and npcTextBox.can_camera_zoom and initial_size > 12:
    actual_target = weakref(global.activeInteractor.get_node("../.."))
    set_target(actual_target.get_ref())
    # interpolation = A + (B - A) * t
    self.size = self.size + (zoomed_size - self.size) * (delta*5)
    if stepify(self.size, 0.1) == stepify(zoomed_size, 0.1):
      self.size = zoomed_size
    set_speed(2)
    set_interpolation_enabled(true)
  else:
    actual_target = weakref(initial_target)
    set_target(actual_target.get_ref())      
    self.size = self.size + (initial_size - self.size) * (delta*5)
    if stepify(self.size, 0.1) == stepify(initial_size, 0.1):
      self.size = initial_size
      
  if is_doing_fake_static:
    set_speed(0)
    set_interpolation_enabled(false)
    var target_screen_pos = unproject_position(actual_target.get_ref().global_transform.origin)

    # self.global_transform.origin.x = x_step * floor(x / x_step) + x_step

    var SCREEN_WIDTH = 1280.0
    var SCREEN_HEIGHT = 1024.0
    # self.global_transform.origin.x = fmod(target_screen_pos.x, SCREEN_WIDTH) # doesn't work...
    # self.global_transform.origin.y = fmod(target_screen_pos.y, SCREEN_HEIGHT)
    
    var w = 0
    var position_x_2D = Vector2(SCREEN_WIDTH * floor(target_screen_pos.x / SCREEN_WIDTH) + SCREEN_WIDTH/2 + w, 0)
    self.global_transform.origin.x = project_position(position_x_2D, 0).x
    var position_y_2D = Vector2(0, SCREEN_HEIGHT * floor(target_screen_pos.y / SCREEN_HEIGHT) + SCREEN_HEIGHT/2 + w)
    self.global_transform.origin.y = project_position(position_y_2D, 0).y
    print(position_x_2D, self.global_transform.origin.x)
    
  respectLevelTilesEdges()
  
  # TODO(jaketrower): This value "0.12" should actually somehow be calculated based on the camera's size
  # var pixelCameraSize = 0.125
  realCamera.size = self.size
  # realCamera.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelCameraSize)
  # realCamera.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelCameraSize)   
  
  if start_applying_parallax and getLevelTiles().backgroundLevelTiles:
    getLevelTiles().backgroundLevelTiles.applyParallax(realCamera.global_transform.origin.x)

func respectLevelTilesEdges():
  # respect left and right, dependent on gameCamera size
  var x_margin = 10 - ((15-self.size)/1.5)
  if global_transform.origin.x < leftmost_x + x_margin:
    global_transform.origin.x = leftmost_x + x_margin
  if global_transform.origin.x > rightmost_x - x_margin:
    global_transform.origin.x = rightmost_x - x_margin
    
  # respect top and bottom, dependent on gameCamera size
  var y_margin = 7.5 - ((15-self.size)/2)
  if global_transform.origin.y < botmost_y + y_margin:
    global_transform.origin.y = botmost_y + y_margin
  if global_transform.origin.y > topmost_y - y_margin:
    global_transform.origin.y = topmost_y - y_margin
    
func isNearBottom():
  # print("is near bottom?: " + str(global_transform.origin.y) + " < " + str(botmost_y + 8) + " : " + str(global_transform.origin.y < botmost_y + 8))
  return global_transform.origin.y < botmost_y + 8
  
func isInitialTargetNearBottom():
  if initial_target == null:
    return false
  # print("is near bottom?: " + str(initial_target.global_transform.origin.y) + " < " + str(botmost_y + 5) + " : " + str(initial_target.global_transform.origin.y < botmost_y + 4))
  return initial_target.global_transform.origin.y < botmost_y + 4
