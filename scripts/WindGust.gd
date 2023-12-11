extends Sprite3D

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  self.visible = false
  set_process(true)

var cloud_timer = 0
var cloud_time_limit = 5
func _process(delta):
  if not is_active:
    return

  cloud_timer += (delta*22)
  if cloud_timer >= cloud_time_limit:
    cloud_timer = 0
    level.summonSmokeClouds(global_transform.origin, 1)
    

func getDirection():
  if self.frame == 0: # DOWN    
    return Vector2(0, -1)
  elif self.frame == 1: # RIGHT
    return Vector2(1, 0)
  elif self.frame == 2: # LEFT
    return Vector2(-1, 0)
  elif self.frame == 3: # UP?
    return Vector2(0, 1)

export var is_active = true
func isActive():
  return is_active

func passiveActivate(delta, is_player):
  if not is_player:
    return
    
  var mult = 6
  if level.player.vv > 4:
    mult = 2
  level.player.vv += (mult*delta*22)
  if level.player.on_ground:
    level.player.vv = 2
    level.player.global_transform.origin.y += 0.5
  level.player.on_ground = false
  level.player.truly_on_ground = false
  level.player.was_on_ground = false
  level.player.lv.y = level.player.vv
  level.player.linear_velocity.y = level.player.vv
  level.player.target_last_grounded_y = level.player.global_transform.origin.y
  level.player.should_do_fallthrough_area_collision = false
