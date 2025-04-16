extends InterpolatedCamera

var initial_z
onready var actual_target = weakref(get_node(target))
onready var initial_target = get_node(target)
onready var realCamera = get_node("RealCamera")
onready var aniPlayer = get_node("AnimationPlayer")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var leftmost_x = 999
var rightmost_x = -999
var topmost_y = -999
var botmost_y = 999
var initial_size = 15
var zoomed_size = 7
var start_applying_parallax = false
var how_fast_to_switch_targets = 1
export var is_doing_fake_static = false
var zoom_in_on_player = false
var can_i_move = true

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = get_tree().get_root().get_node("Game/Viewport/level").levelTiles
  return levelTiles

var CAMERA_SIZE = 25
export var override_camera_size = 0
func _ready():
  if override_camera_size == 0:
    initial_size = CAMERA_SIZE
    zoomed_size = CAMERA_SIZE
  else:
    initial_size = override_camera_size
    zoomed_size = override_camera_size
  if global.memory.has("cameraSize"):
    self.size = global.memory["cameraSize"]
  initial_z = global_transform.origin.z
  
  # Wait two frames so that levelTiles on levelScript is available
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")

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

func shakeScreen():
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("screenShake")
  level.player.screenShakeSound.pitch_scale = 1.5
  level.player.screenShakeSound.play()

func miniShakeScreen():
  if aniPlayer.assigned_animation == "screenShake" and aniPlayer.is_playing():
    return
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("miniScreenShake")
  level.player.screenShakeSound.pitch_scale = 2.0
  level.player.screenShakeSound.play()
      
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

  if can_i_move:
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

    if zoom_in_on_player:
      actual_target = weakref(initial_target)
      set_target(actual_target.get_ref())      
      self.size = self.size + (zoomed_size - self.size) * (delta*5)
      if stepify(self.size, 0.1) == stepify(zoomed_size, 0.1):
        self.size = zoomed_size
      set_speed(2)
      set_interpolation_enabled(true)
    elif global.activeInteractor != null and is_instance_valid(global.activeInteractor) and global.activeInteractor.can_camera_zoom and initial_size > 12:
      actual_target = weakref(global.activeInteractor.textboxCameraTarget.get_ref())
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
      
    respectLevelTilesEdges()
  # TODO(jaketrower): This value "0.12" should actually somehow be calculated based on the camera's size
  # var pixelCameraSize = 0.125
  realCamera.size = self.size
  # realCamera.projection = 
  # realCamera.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelCameraSize)
  # realCamera.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelCameraSize)   

var x_margin = 0
var y_margin = 0
var x_edge = 0
var y_edge = 0
func respectLevelTilesEdges():
  # respect left and right, dependent on gameCamera size
  x_margin = 10 - ((15-self.size)/1.5)
  if global_transform.origin.x < leftmost_x + x_margin:
    global_transform.origin.x = leftmost_x + x_margin
    x_edge = -1
  if global_transform.origin.x > rightmost_x - x_margin:
    global_transform.origin.x = rightmost_x - x_margin
    x_edge = 1
  if global_transform.origin.x > leftmost_x + x_margin and global_transform.origin.x < rightmost_x - x_margin:
    x_edge = 0
  # if it's too small
  var x_median = (rightmost_x + leftmost_x) / 2
  # x_median = -19.5
  if rightmost_x - leftmost_x < x_margin * 2:
    global_transform.origin.x = x_median
    x_edge = 2
    
  # respect top and bottom, dependent on gameCamera size
  y_margin = 7.5 - ((15-self.size)/2)
  if global_transform.origin.y < botmost_y + y_margin:
    global_transform.origin.y = botmost_y + y_margin
    y_edge = -1
  if global_transform.origin.y > topmost_y - y_margin:
    global_transform.origin.y = topmost_y - y_margin
    y_edge = 1
  if global_transform.origin.y > botmost_y + y_margin and global_transform.origin.y < topmost_y - y_margin:
    x_edge = 0
  # if it's too small
  var y_median = (topmost_y + botmost_y) / 2
  if topmost_y - botmost_y < y_margin * 2:
    global_transform.origin.y = y_median
    y_edge = 2
