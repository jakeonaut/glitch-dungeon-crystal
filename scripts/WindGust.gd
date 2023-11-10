extends Sprite3D

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  self.visible = false
  set_process(true)

var cloud_timer = 0
var cloud_time_limit = 5
func _process(delta):
  cloud_timer += (delta*22)
  if cloud_timer >= cloud_time_limit:
    cloud_timer = 0
    summonSmokeClouds(1)

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
func summonSmokeClouds(num_clouds):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_x = newSmokeCloud.global_transform.origin.x + rand_range(-2, 2)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(2, 4)
        # newSmokeCloud.get_material_override().set_shader_param("opacity", 0.2)
        newSmokeCloud.get_material_override().set_shader_param("target_palette", global.bog_water_palette)
        newSmokeCloud.automatically_change_color = false
    

func getDirection():
  if self.frame == 0: # DOWN    
    return Vector2(0, -1)
  elif self.frame == 1: # RIGHT
    return Vector2(1, 0)
  elif self.frame == 2: # LEFT
    return Vector2(-1, 0)
  elif self.frame == 3: # UP?
    return Vector2(0, 1)

func isActive():
  return true

func passiveActivate(delta, is_player):
  if not is_player:
    return
    
  var mult = 5
  if level.player.vv > 4:
    mult = 1
  level.player.vv += (mult*delta*22)
  if level.player.on_ground:
    level.player.vv = 2
    level.player.global_transform.origin.y += 0.5
  level.player.on_ground = false
  level.player.truly_on_ground = false
  level.player.was_on_ground = false
  level.player.was_just_on_ground_timer = -4
  level.player.lv.y = level.player.vv
  level.player.linear_velocity.y = level.player.vv
  level.player.target_last_grounded_y = level.player.global_transform.origin.y
  level.player.should_do_fallthrough_area_collision = false
