extends Spatial

onready var splashSprite = get_node("SplashSprite")
onready var splashSound = get_node("SplashSound")
onready var miniSplashSound = get_node("MiniSplashSound")
onready var miniSplashSound2 = get_node("MiniSplashSound2")
onready var area = get_node("Area")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

onready var waterFilter = get_node("WaterFilter")
onready var waterFilterColorRect = get_node("WaterFilter/ColorRect")
onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")

var poisonWaterShader = preload("res://shaders/PoisonWaterCube.gdshader")

export var water_cube_width = 2.0
export var water_cube_height = 2.0
export var turn_poisonous = false
export var can_splash = true
var is_poison = false
var poisonous_timer = 0
var poisonous_time_limit = 10
var poisonous_counter = 0

# will be set as top left position
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
  waterFilterColorRect.material = waterFilterColorRect.material.duplicate()
  if turn_poisonous:
    is_poison = true
    becomePoisonous()

func _process(delta):
  if level and waterFilter.get_parent() == self:
    self.remove_child(waterFilter)
    level.uiLayer.get_node("Filters").add_child(waterFilter)

  setFilterPosition()

  if poisonous_counter > 0 and poisonous_counter < 3:
    poisonous_timer += (delta * 22)
    if poisonous_timer >= poisonous_time_limit:
      poisonous_timer = 0
      poisonous_counter += 1
      if poisonous_counter == 2:
        mySprite.material_override.set_shader_param("shake_power", 0.006)
        mySprite.material_override.set_shader_param("shake_block_size", 60)
        mySprite.material_override.set_shader_param("enable_glitch", true)
      elif poisonous_counter == 3:
        mySprite.material_override.set_shader_param("time_influence", 26.841)
        # mySprite.material_override.set_shader_param("y_div", 0.5)
        mySprite.material_override.set_shader_param("enable_glitch", false)
        #mySprite.material_override.set_shader_param("enable_palette_cycle", true)
        waterFilterColorRect.material.set_shader(poisonWaterShader)

func becomePoisonous():
  return
  # if is_poison or poisonous_counter > 0:
  #   return
  # is_poison = true
  # poisonous_counter = 1
  # mySprite.material_override.set_shader_param("target_palette", global.dream_palette)

func isActive():
  return true
  
func passiveActivate(_delta, _is_player):
  if not getPlayer().was_touching_water and can_splash:
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
  if not getPlayer().is_touching_water and can_splash:
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
  if not mySprite2.visible:
    return

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
  var width = water_cube_width
  var height = water_cube_height

  var factor = 0.5
  # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
  var top_right_corner_3D = target_origin
  var bot_right_corner_3D = target_origin + Vector3(width / factor, height / factor, 0.0)

  var top_right_corner_2D = factor * getGameCamera().unproject_position(top_right_corner_3D)
  var bot_right_corner_2D = factor * getGameCamera().unproject_position(bot_right_corner_3D)
  
  waterFilter.rect_position.x = top_right_corner_2D.x
  waterFilter.rect_position.y = top_right_corner_2D.y
  var rect_size = bot_right_corner_2D - top_right_corner_2D
  waterFilter.get_node("ColorRect").rect_size.x = rect_size.x
  # switching from 3D to 2D flips the y axis...
  waterFilter.get_node("ColorRect").rect_size.y = -rect_size.y
