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
    level.summonSmokeClouds(getStartingPosition(), 1, false, false, global.grey_palette, getDirection().x, getDirection().y)
    
func getStartingPosition():
  if self.frame == 0: # DOWN    
    return global_transform.origin + Vector3(0, -1, 0)
  elif self.frame == 1: # RIGHT
    return global_transform.origin + Vector3(1, 0, 0)
  elif self.frame == 2: # LEFT
    return global_transform.origin + Vector3(-1, 0, 0)
  elif self.frame == 3: # UP?
    return global_transform.origin + Vector3(0, 1, 0)

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
func isActive(_debug=false):
  return is_active

func passiveActivate(delta, is_player):
  if not is_player:
    return
  otherPassiveActivate(delta, level.player)

func otherPassiveActivate(delta, gameMover):
  if gameMover == null or gameMover.glitch_form == global.GlitchForm.LADDER:
    return
  if getDirection().y != 0:
    var v_sign = 1
    var mult = 6
    if gameMover.vv > 4:
      mult = 2
    if getDirection().y == -1:
      v_sign = -1
    gameMover.vv += (v_sign*mult*delta*22)
    if gameMover.on_ground:
      gameMover.vv = v_sign*2
      gameMover.global_transform.origin.y += v_sign*0.5
    gameMover.on_ground = false
    gameMover.truly_on_ground = false
    gameMover.was_on_ground = false
    gameMover.lv.y = gameMover.vv
    gameMover.linear_velocity.y = gameMover.vv
    if gameMover.has_method("getFishyCured"): # I'M CHEATING!!!!
      gameMover.camera_target_y_pos = gameMover.global_transform.origin.y
    gameMover.was_fallthrough_area_collision_triggered = false
  if getDirection().x != 0:
    var x_sign = 1
    var mult = 6
    if gameMover.linear_velocity.x > 4:
      mult = 2
    if getDirection().x == -1:
      x_sign = -1
    gameMover.linear_velocity.x += (x_sign*mult*delta*22)
    gameMover.lv.x = gameMover.linear_velocity.x
