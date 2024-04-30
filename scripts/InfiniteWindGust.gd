extends Sprite3D

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  self.visible = false
  set_process(true)

var cloud_timer = 0
var cloud_time_limit = 5

var player_walk_speed = null
func _process(delta):
  if not is_active:
    return

  affectPlayerMovement(delta)
  cloud_timer += (delta*22)
  if cloud_timer >= cloud_time_limit:
    cloud_timer = 0
    level.summonSmokeClouds(global_transform.origin, 1, false, false, global.grey_palette, -1)

  if player_walk_speed == null:
    player_walk_speed = level.player.walk_speed # TODO(jaketrower): Won't work when switching glitches...
    # or other mods
    

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

func affectPlayerMovement(delta):
  pass
  # if level.player.truly_on_ground:
  #   level.player.horizontal_addition = 0.5
  # else:
  #   level.player.horizontal_addition = 1.0
  #   level.player.dir.x = 0.0

