extends Spatial

onready var splashSprite = get_node("SplashSprite")
onready var splashSound = get_node("SplashSound")
onready var miniSplashSound = get_node("MiniSplashSound")
onready var miniSplashSound2 = get_node("MiniSplashSound2")
onready var area = get_node("Area")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

onready var waterFilter = get_node("WaterFilter")
onready var mySprite = get_node("Sprite3D")

export var water_cube_width = 4.0
export var water_cube_height = 4.0
export var turn_poisonous = false
var is_poison = false

var target_origin = Vector3(0, 0, 0)

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var gameCamera = null
func getGameCamera():
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

func _ready():
  set_process(true)

  target_origin = self.global_transform.origin + Vector3(-1, 2, 0)
  mySprite.material_override = mySprite.material_override.duplicate()
  if turn_poisonous:
    becomePoisonous()

func _process(_delta):
  if level and waterFilter.get_parent() == self:
    self.remove_child(waterFilter)
    level.get_node("UILayer/Filters").add_child(waterFilter)

  setFilterPosition()
  
func isActive():
  return true

func becomePoisonous():
  if is_poison:
    return
  is_poison = true
  mySprite.material_override.set_shader_param("shake_power", 0.006)
  mySprite.material_override.set_shader_param("shake_block_size", 60)
  mySprite.material_override.set_shader_param("enable_glitch", true)
  mySprite.material_override.set_shader_param("time_influence", 26.841)
  mySprite.material_override.set_shader_param("y_div", 0.5)
  mySprite.material_override.set_shader_param("target_palette", global.rgb_palette)
  waterFilter.visible = false
  
func passiveActivate(_delta):
  if not getPlayer().was_touching_water:
    if bigSplash():
      splashSound.play()
    else:
      if randi() % 2 == 0:
        miniSplashSound.play()
      else:
        miniSplashSound2.play()
    if getPlayer().global_transform.origin.y > global_transform.origin.y:
      makeNewSplashSprite(-0.418)
      makeNewSplashSprite(0.582)
      
func justStopPassiveActivate():
  if not getPlayer().is_touching_water:
    if bigSplash():
      splashSound.play()
    else:
      if randi() % 3 == 0:
        miniSplashSound.pitch_scale = rand_range(1, 1.8)
        miniSplashSound.play()
      else:
        miniSplashSound2.pitch_scale = rand_range(0.8, 1.5)
        miniSplashSound2.play()
    if getPlayer().global_transform.origin.y > global_transform.origin.y:
      makeNewSplashSprite(-0.418, true)
      makeNewSplashSprite(0.582, true)
      
func bigSplash():
  return abs(getPlayer().linear_velocity.y) > 10
    
func makeNewSplashSprite(x_offset, is_mini = false):
  var newSplashSprite = splashSprite.duplicate()
  newSplashSprite.should_fizzle_out = true
  newSplashSprite.visible = true

  # x not less than -0.498, not greater than 2.502
  var new_x = getPlayer().global_transform.origin.x - self.global_transform.origin.x + x_offset
  newSplashSprite.transform.origin.x = clamp(new_x, -0.498, water_cube_width/1.598)
  
  if is_mini:
    newSplashSprite.updateBaseFrame(4, 0)
    newSplashSprite.max_frames = 2
  elif bigSplash():
    newSplashSprite.updateBaseFrame(0, 0)
    newSplashSprite.max_frames = 5
  else:
    newSplashSprite.updateBaseFrame(3, 0)
    newSplashSprite.max_frames = 3
    newSplashSprite.frame_delay = 0.1
  add_child(newSplashSprite)

func setFilterPosition():
  # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
  var target_pos = getGameCamera().unproject_position(target_origin)
  waterFilter.rect_position.x = target_pos.x - 1
  waterFilter.rect_position.y = target_pos.y - 1

  var bot_right_corner_3D = target_origin + Vector3(water_cube_width, water_cube_height, 0.0)

  var bot_right_corner_2D = getGameCamera().unproject_position(bot_right_corner_3D)
  var rect_size = bot_right_corner_2D - target_pos + Vector2(1.0, 1.0)
  waterFilter.get_node("ColorRect").rect_size.x = rect_size.x
  # switching from 3D to 2D flips the y axis...
  waterFilter.get_node("ColorRect").rect_size.y = -rect_size.y
