extends "GlitchEnemy.gd"

onready var screamSound = get_node("Sounds/ScreamSound")
onready var thudSound = get_node("Sounds/ThudSound")
onready var digSound = get_node("Sounds/DigSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var windGust = get_node("WindGust")
enum ZombieState {
  IDLE,
  SLIME_WALK,
  LURCH_START,
  LURCH_ATTACK,
  LURCH_END,
  DYING,
  REVIVING,
  CONSUMING,
  GRANDMA_FORM,
  BONK,
}
var zombie_state = ZombieState.DYING
var ZOMBIE_MAX_HP = 2
var fast_walk_speed = 6
var slow_walk_speed = 4
var death_timer = 0
var death_time_limit = 40
var spawn_point = null
var ghostEnemyRes = preload("res://sceneObjects/Enemies/GhostEnemy.tscn")
# var cherryCarcassRes = preload("res://sceneObjects/CherryCarcass.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    should_collide_ceil = false
    only_activate_in_range = false
    should_reset_slime_timer_on_flip = false
    slime_idle_time_limit = 30
    can_spawn_mini_crystal = false
    hp_enemy = ZOMBIE_MAX_HP
    kill_invis = false
    kill_immediately = true
    death_timer = death_time_limit / 2
    yield(get_tree().create_timer(0.1), "timeout")
    spawn_point = global_transform.origin

func _process(delta):
  # ._process(delta) implicit
  if not visible: return
  
  delta = delta * global.time_dilation_multiplier
  # self.glitch_form = level.player.glitch_form
  # should_collide_ceil = self.glitch_form == global.GlitchForm.LADDER

  # if screamSound.is_playing() and am_i_really_in_range_of_player:
  #   player.getCurseInfected()

  if zombie_state == ZombieState.IDLE:
    reenemize()
    windGust.is_active = false
    grav = 60
    zombie_state = ZombieState.SLIME_WALK
  elif zombie_state == ZombieState.SLIME_WALK:
    windGust.is_active = false
    grav = 60
    walk_speed = slow_walk_speed
    behavior_jumping = false
    if am_i_really_in_range_of_player and level.player.nesting_doll_state == global.NestingDoll.GRANDMA:
      zombie_state = ZombieState.LURCH_START
      behavior_intermittent_walking = false
    else:
      behavior_walk_flip = true
      if not behavior_intermittent_walking:
        behavior_intermittent_walking = true
        slime_state_timer = 0
        slime_state = SlimeState.WALK
      if slime_state == SlimeState.WALK:
        if slime_state_timer == 0:
          if secretAniPlayer.assigned_animation == "walk2":
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("walk1")
          else:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("walk2")
      elif slime_state == SlimeState.IDLE:
        pass
  elif zombie_state == ZombieState.LURCH_START:
    windGust.is_active = true
    behavior_intermittent_walking = false
    behavior_walking = false
    slime_state = SlimeState.NULL
    if secretAniPlayer.assigned_animation != "lurchStart":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchStart")
    elif secretAniPlayer.assigned_animation == "lurchStart" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.LURCH_ATTACK
    if getPlayer().global_transform.origin.x > self.global_transform.origin.x + 0.2:
      walk_direction.x = 1
      mySprite.flip_h = false
    elif getPlayer().global_transform.origin.x < self.global_transform.origin.x - 0.2:
      walk_direction.x = -1
      mySprite.flip_h = true
  elif zombie_state == ZombieState.LURCH_ATTACK:
    windGust.is_active = false
    behavior_walking = true
    behavior_walk_flip = false
    walk_speed = fast_walk_speed
    var buffer = 0.5
    if secretAniPlayer.assigned_animation != "lurchAttack":
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchAttack")
      # behavior_jumping = true
      # see stopJumping, called by lurchAttack
      screamSound.pitch_scale = rand_range(0.4, 0.6)
      screamSound.play()
    elif secretAniPlayer.assigned_animation == "lurchAttack" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.LURCH_END
      return
    if level.player.glitch_form == global.GlitchForm.LADDER:
      digTiles(getTilesAbove(getLevelTiles()))
    else:
      if walk_direction.x > 0:
        digTiles(getTilesRightOf(getLevelTiles(), buffer))
      elif walk_direction.x < 0:
        digTiles(getTilesLeftOf(getLevelTiles(), buffer))
  elif zombie_state == ZombieState.LURCH_END:
    windGust.is_active = false
    if secretAniPlayer.assigned_animation != "lurchEnd":
      behavior_walking = false
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("lurchEnd")
    elif secretAniPlayer.assigned_animation == "lurchEnd" and not secretAniPlayer.is_playing():
      zombie_state = ZombieState.IDLE
  elif zombie_state == ZombieState.BONK:
    if not secretAniPlayer.is_playing():
      zombie_state = ZombieState.IDLE
  elif zombie_state == ZombieState.DYING:
    unenemize()
    # see ouchies()
    death_timer += (delta*11)
    if death_timer >= death_time_limit:
      global_transform.origin = spawn_point
      zombie_state = ZombieState.REVIVING
      death_timer = 0
      unsmack()
    if secretAniPlayer.assigned_animation == "die" and not secretAniPlayer.is_playing():
      grav = 60
  elif zombie_state == ZombieState.REVIVING:
    unenemize()
    behavior_jumping = false
    if secretAniPlayer.assigned_animation != "revive":
      am_i_dying = false
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("revive")
      # if my_carcass != null and my_carcass.get_ref() != null:
      #   my_carcass.get_ref().queue_free()
      #   my_carcass = null
      windGust.is_active = true
      hp_enemy = ZOMBIE_MAX_HP
      # global_transform.origin = spawn_point
    else:
      if not secretAniPlayer.is_playing():
        unsmack()
        zombie_state = ZombieState.IDLE
        grav = 60
  elif zombie_state == ZombieState.CONSUMING:
    behavior_jumping = false
    behavior_walking = false
    grav = 0
    vv = 0
    hv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    lv = Vector3(0, 0, 0)
    linear_velocity = Vector3(0, 0, 0)

    if not secretAniPlayer.is_playing():
      unsmack()
      zombie_state = ZombieState.IDLE
      grav = 60
  elif zombie_state == ZombieState.GRANDMA_FORM:
    grav = 30

# @override
func unsmack():
  .unsmack()
  mySprite.material_override.set_shader_param("shake_power", 0.002)

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func passiveActivate(_delta, _is_player):
    if am_i_dying or not visible or not mySprite.visible: return # or is_smacked: return
        
    # var aniPlayer = get_node("HeartSprite/AnimationPlayer")
    # if level.player.glitch_form == global.GlitchForm.INVISIBLE and not aniPlayer.is_playing():
    #     heartSound.play()
    #     aniPlayer.stop()
    #     aniPlayer.queue("heartWiggle")
    #     aniPlayer.queue("noHeart")

func processDeath():
    pass

func stopJumping():
  behavior_jumping = false

func getSmacked(broom_origin = null, silently = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently)
  if not am_i_dying and zombie_state != ZombieState.CONSUMING:
    ouchies(broom_origin)
        
# @override
func ouchies(broom_origin):
    if zombie_state == ZombieState.CONSUMING:
      return
    .ouchies_base(broom_origin)
    if am_i_dying or not visible:
      return # or am_i_hurt: return

    # if zombie_state == ZombieState.REVIVING:
    #   notDieSound.play()
    #   return
        
    hp_enemy -= ZOMBIE_MAX_HP
    # am_i_hurt = true
    if true: # hp_enemy <= 0:
      windGust.is_active = false
      behavior_walking = false
      behavior_intermittent_walking = false
      behavior_jumping = false
      lv = Vector3(0, 0, 0)
      linear_velocity = Vector3(0, 0, 0)
      vv = 0
      grav = 0
      hv = Vector3(0, 0, 0)
      slime_state = SlimeState.NULL
      # yield(get_tree().create_timer(0.5), "timeout")
      am_i_dying = true
      zombie_state = ZombieState.DYING
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("die")
      # spawnACarcass()
      death_timer = 0
      var newGhostEnemy = ghostEnemyRes.instance()
      var rand_x_speed = rand_range(-4, 4)
      var rand_y_speed = rand_range(2, 4)
      newGhostEnemy.x_speed = rand_x_speed
      newGhostEnemy.y_speed = rand_y_speed
      newGhostEnemy.just_a_figment = true
      level.add_child(newGhostEnemy)
      newGhostEnemy.global_transform.origin = self.global_transform.origin

func isActive(debug=false):
  if not level.player.visible:
    return false
  return .isActive(debug)

# func doSomethingElseToPlayer(player):
#   if level.player.nesting_doll_state == global.NestingDoll.BABY:
#     return
#   # player.nullify()
#   # player.tryDieToEnemy(0, true, kill_invis, kill_immediately)

#   # this is good and normal actually
#   if player.nesting_doll_state == global.NestingDoll.GRANDMA and player.visible:
#     player.visible = false
#     player.pauseInput = true
#     player.pauseSelf = true
#     secretAniPlayer.stop()
#     secretAniPlayer.clear_queue()
#     secretAniPlayer.play("consumeMemory")
#     dieSound.play()
#     zombie_state = ZombieState.CONSUMING
#     getSmacked()

func popOutPlayer():
  level.player.global_transform.origin = self.global_transform.origin
  level.player.doubleJump()
  level.player.nesting_doll_state = global.NestingDoll.BABY
  level.player.updateNestingDoll(global.NestingDoll.GRANDMA, false)
  level.player.glitchTickle()
  level.player.visible = true
  level.player.pauseInput = false
  level.player.pauseSelf = false

# @override
func addJumpSmokeCloud(flip_flip_h = false):
  if zombie_state == ZombieState.DYING or zombie_state == ZombieState.REVIVING:
    return
  .addJumpSmokeCloud(flip_flip_h)

# var my_carcass = null
# func spawnACarcass():
#   if my_carcass != null and my_carcass.get_ref() != null:
#     my_carcass.get_ref().queue_free()
#     my_carcass = null

#   var carcass = cherryCarcassRes.instance()
#   level.add_child(carcass)
#   carcass.broomSprite.visible = false
#   carcass.mushroomSprite.visible = false
#   carcass.global_transform.origin = self.global_transform.origin
#   carcass.mySprite.flip_h = mySprite.flip_h
#   carcass.mySprite.material_override.set_shader_param(
#     "target_palette", mySprite.material_override.get_shader_param("target_palette"))
#   my_carcass = weakref(carcass)

# @override
func processGlitchFormGlitchiness():
  pass

export var permanently_alter_tiles = false
func digTiles(solidTiles):
  var tiles_dug = 0
  for i in solidTiles.size():
    var coords = solidTiles[i]
    if coords == null: continue
    var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
    if getLevelTiles().isTileFragileSolid(tile_type):
      thudSound.play()
      if screamSound.is_playing():
        screamSound.stop()
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("bonk")
      zombie_state = ZombieState.BONK
      if walk_direction.x > 0:
        global_transform.origin.x -= 0.5
      elif walk_direction.x < 0:
        global_transform.origin.x += 0.5
      behavior_walking = false
      return false
    levelTiles.removeTile(Vector3(coords.x, coords.y, coords.z), permanently_alter_tiles)
    tiles_dug += 1

  if tiles_dug > 0:
    level.summonSmokeClouds(global_transform.origin, 2)
    digSound.play()
              
  return tiles_dug > 0

func actuallyDieToOffscreenCamera(_delta):
  mySprite.visible = false
  global_transform.origin = spawn_point
  am_i_dying = true
  zombie_state = ZombieState.DYING
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  secretAniPlayer.play("startDead")
  # spawnACarcass()
  death_timer = 0
  behavior_walking = false