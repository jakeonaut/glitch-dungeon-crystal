extends "GlitchEnemy.gd"

onready var hatSprite = get_node("SpriteContainer/InnerSpriteContainer/HatSprite")
onready var cawSound = get_node("Sounds/CawSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
export var can_cast_spells = false

enum CrowState {
  IDLE,
  FLY_AWAY
}
var crow_state = CrowState.IDLE
var caw_timer = 0
var caw_time_limit = 999
var caw_time_max = 30
var caw_time_min = 10

func _ready():
  set_process(true)
  hatSprite.material_override = hatSprite.material_override.duplicate()
  caw_time_limit = rand_range(caw_time_min, caw_time_max)

var opacity = 1.0
func _process(delta):
  if crow_state == CrowState.IDLE:
    mySprite.flip_h = level.player.global_transform.origin.x < self.global_transform.origin.x
    hatSprite.flip_h = mySprite.flip_h
    if secretAniPlayer.assigned_animation != "startCaw":
      caw_timer += (delta*11)
      if caw_timer >= caw_time_limit:
        caw_time_limit = rand_range(caw_time_min, caw_time_max)
        caw_timer = 0
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("startCaw")
        cawSound.pitch_scale = rand_range(0.8, 1.2)
        cawSound.play()
    elif secretAniPlayer.assigned_animation == "startCaw":
      if not cawSound.is_playing():
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("stopCaw")
        caw_timer = 0
  elif crow_state == CrowState.FLY_AWAY:
    opacity -= (delta*2)
    mySprite.material_override.set_shader_param("opacity", opacity)
    hatSprite.material_override.set_shader_param("opacity", opacity)
    if opacity < 0:
      queue_free()

func isActive(_debug = false):
  return crow_state != CrowState.FLY_AWAY

func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  .getSmacked(broom_origin, silently)
  startFlyAway(level.player.global_transform.origin)

func playerActivationAreaPassiveActivate():
  startFlyAway(level.player.global_transform.origin)

func startFlyAway(from_where):
  if crow_state == CrowState.IDLE:
    on_ground = false
    mySprite.flip_h = from_where.x > self.global_transform.origin.x
    hatSprite.flip_h = mySprite.flip_h
    behavior_walking = true
    walk_direction = Vector2(-1 if mySprite.flip_h else 1, 0)
    grav = -20
    crow_state = CrowState.FLY_AWAY
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("flyAway")

func glitchSwitchSprite(_delta):
  pass