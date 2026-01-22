extends "GlitchEnemy.gd"

onready var hatSprite = get_node("SpriteContainer/InnerSpriteContainer/HatSprite")
onready var cawSound = get_node("Sounds/CawSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
export var can_cast_spells = false

enum CrowState {
  IDLE,
  FLY_AWAY,
  NOTICED_PLAYER,
  WIND_UP,
  CAST_GLITCH,
  COOLDOWN,
  SCATTER,
  SWOOP_DIVE,
}
var crow_state = CrowState.IDLE
var caw_timer = 0
var caw_time_limit = 999
var caw_time_max = 30
var caw_time_min = 10
var attackStateTimer = 0
var attackStateNoticePlayerTimeLimit = 10
var attackStateWindUpTimeLimit = 10
var attackStateCastGlitchTimeLimit = 20
var attackStateRecoveryTimeLimit = 50
onready var castGlitchSound = get_node("Sounds/CastGlitchSound")
onready var windUpSound = get_node("Sounds/WindUpSound")
const GlitchEnemyResource = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var MAX_SQUARED_DIST = 225
var should_fly_away = false
var fly_away_from_where = Vector3(0, 0, 0)
var should_scatter = false

func _ready():
  set_process(true)
  hatSprite.material_override = hatSprite.material_override.duplicate()
  caw_time_limit = rand_range(caw_time_min, caw_time_max)
  if not can_cast_spells:
    hatSprite.pixel_size = 0.0001

var opacity = 1.0
func _process(delta):
  if should_fly_away and not crow_state == CrowState.FLY_AWAY:
    startFlyAway(fly_away_from_where)
    return
  
  if should_scatter and crow_state != CrowState.SCATTER:
    crow_state = CrowState.SCATTER
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("flyAway")
    randomizeTargetPos()
    should_scatter = false

  if crow_state == CrowState.SCATTER:
    moveAbout(delta)
    mySprite.flip_h = target_pos.x < self.global_transform.origin.x
    hatSprite.flip_h = mySprite.flip_h
  elif crow_state == CrowState.SWOOP_DIVE:
    pass
  elif crow_state == CrowState.IDLE:
    mySprite.flip_h = level.player.global_transform.origin.x < self.global_transform.origin.x
    hatSprite.flip_h = mySprite.flip_h
    if secretAniPlayer.assigned_animation != "startCaw":
      if can_cast_spells and getSquaredDistToPlayer() <= MAX_SQUARED_DIST:
        crow_state = CrowState.NOTICED_PLAYER
        caw_timer = 0
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("chanting")
      else:
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
      level.levelTiles.tryToSayTidy()
      queue_free()
  elif crow_state == CrowState.NOTICED_PLAYER:
    mySprite.flip_h = level.player.global_transform.origin.x < self.global_transform.origin.x
    hatSprite.flip_h = mySprite.flip_h
    attackStateTimer += (delta*22)
    if attackStateTimer >= attackStateNoticePlayerTimeLimit:
        windUpSound.play()
        attackStateTimer = 0
        crow_state = CrowState.WIND_UP
        mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  elif crow_state == CrowState.WIND_UP:
    # this state should be handled in the process event instead of passiveActivate
    # because if the player leaves the detection radius while we're casting a glitch
    # we still want to cast it and start "recovery"
      attackStateTimer += (delta*22)
      if attackStateTimer >= attackStateWindUpTimeLimit:
          attackStateTimer = 0
          crow_state = CrowState.CAST_GLITCH
          var my_material = mySprite.get_material_override().duplicate()
          if my_material is ShaderMaterial:
              my_material.set_shader_param("enable_glitch", true)
              my_material.set_shader_param("enable_palette_cycle", false)
          mySprite.set_material_override(my_material)

          castGlitchSound.play()
          # spawn a baby glitch that will evolve to a normal one that should fizzle out
          var newGlitchEnemy = GlitchEnemyResource.instance()
          newGlitchEnemy.visible = true
          newGlitchEnemy.grav = Vector2(0, 0)
          newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
          newGlitchEnemy.behavior_evolve = true
          newGlitchEnemy.behavior_fizzle_out_after_evolve = true
          self.add_child(newGlitchEnemy)
          newGlitchEnemy.global_transform.origin = getPlayer().global_transform.origin
          var newGlitchMaterial = newGlitchEnemy.mySprite.get_material_override().duplicate()
          if newGlitchEnemy.is_in_group("sprite"):
              newGlitchEnemy.mySprite.remove_from_group("sprite")
          if newGlitchMaterial is ShaderMaterial:
              newGlitchMaterial.set_shader_param("target_palette", global.weird_base_palette)
          newGlitchEnemy.mySprite.set_material_override(newGlitchMaterial)

          var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
          add_child(newSpawnGlitchEffect)
          newSpawnGlitchEffect.global_transform.origin = newGlitchEnemy.global_transform.origin
  elif crow_state == CrowState.CAST_GLITCH:
      attackStateTimer += (delta*22)
      if attackStateTimer >= attackStateCastGlitchTimeLimit:
          mySprite.frame_delay = 0.8
          attackStateTimer = 0
          crow_state = CrowState.COOLDOWN
          mySprite.material_override.set_shader_param("enable_glitch", false)
  elif crow_state == CrowState.COOLDOWN:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("stopCaw")
      attackStateTimer += (delta*22)
      if attackStateTimer >= attackStateRecoveryTimeLimit:
          crow_state = CrowState.IDLE
          attackStateTimer = 0
          mySprite.frame_delay = 1.4
          mySprite.should_randomize_frame_delay = true

func getSquaredDistToPlayer():
  var distVector = self.global_transform.origin - level.player.global_transform.origin
  distVector.z = 0
  return distVector.length_squared()

func isActive(_debug = false):
  return crow_state != CrowState.FLY_AWAY

func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
  .getSmacked(broom_origin, silently, is_local_broom)
  startFlyAway(level.player.global_transform.origin)

func playerActivationAreaPassiveActivate():
  if crow_state == CrowState.SCATTER or crow_state == CrowState.SWOOP_DIVE:
    return
  startFlyAway(level.player.global_transform.origin)

func startFlyAway(from_where):
  if crow_state != CrowState.FLY_AWAY:
    mySprite.material_override.set_shader_param("enable_glitch", false)
    mySprite.material_override.set_shader_param("enable_palette_cycle", false)
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

func startSwoopAttack():
  reenemize(true)
  crow_state = CrowState.SWOOP_DIVE
  behavior_directional_bullet = true
  behavior_phase_through_walls = false
  mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  var CROW_SPEED = 20
  bullet_direction_vector = (level.player.global_transform.origin - self.global_transform.origin).normalized() * CROW_SPEED

func glitchSwitchSprite(_delta):
  pass

var original_pos = null
var target_pos = null
func moveAbout(delta):
  var step = 3
  global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
  
  if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
      stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
      randomizeTargetPos()

func randomizeTargetPos():
  target_pos = Vector3(
      original_pos.x + rand_range(-9, 9),
      original_pos.y + rand_range(-5, 6),
      original_pos.z
  )