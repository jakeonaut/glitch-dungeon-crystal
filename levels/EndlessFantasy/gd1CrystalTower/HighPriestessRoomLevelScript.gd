extends "../../../scripts/levelScript.gd"

onready var altarSprite = get_node("AltarSprite")
onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var npcPlatformContainer = get_node("npcPlatforms")
onready var croneNPC = get_node("CroneNPC")
onready var croneNPCDefeated = get_node("CroneNPCDefeated")
onready var crystalGeode = get_node("CubeCrystal")
onready var crystalGeode2 = get_node("CubeCrystal2")
onready var crystalGeode3 = get_node("CubeCrystal3")
onready var crystalGeode4 = get_node("CubeCrystal4")
onready var crystalGeode5 = get_node("CubeCrystal5")
onready var aniPlayer = get_node("AnimationPlayer")
onready var door2 = get_node("Door2")

var has_boss_started = false
var debug_start_boss_immediately = false
export var camera_size = 30
# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("roomPath"):
    debug_start_boss_immediately = true
    highPriestessBoss.MAX_NUM_HITS = 1 # nocommit
    croneNPC.textBox.get_node("AbortSound").activateScript()
  if crystalGeode.getMyStaticLevelZoneVar():
    debug_start_boss_immediately = true

  if debug_start_boss_immediately:
    gameCamera.initial_size = camera_size
    gameCamera.zoomed_size = camera_size
    aniPlayer.stop()
    aniPlayer.clear_queue()
    unhideHighPriestess()
    has_boss_started = true
  else:
    highPriestessBoss.visible = false
    highPriestessBoss.am_i_hidden = true
    highPriestessBoss.mySprite.visible = false

# @override
func playMenuMusic():
  musicPlayer.changeSongPitch(0.5)
  # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
  pass

# @override
func restartMusic():
  musicPlayer.changeSongPitch(1.0)
  # musicPlayer.conductFromScenePath(getLevelName())
  pass

# @override
func overrideLevelRespawnEvent():
  pass

var random_tiles_timer = 0
var random_tiles_time_limit = 10
func _process(delta):
  # i hate this but _process is not guaranteed to occur AFTER setUpRoomInitializationOverride
  if not has_room_initialized:
    return

  if not has_boss_started:
    if crystalGeode.getMyStaticLevelZoneVar():
      has_boss_started = true
      levelTiles.randomize_num = 1
      aniPlayer.play("appear")
      gameCamera.initial_size = camera_size
      gameCamera.zoomed_size = camera_size
      global.pauseMoveInput = true
      global.pauseGame = true
      global.shouldRenderAsCinematic = true
      musicPlayer.stopAll()

  if is_defeated and not is_really_defeated:
    player.pauseSelf = true
    player.grav = 0
    if not player.aniPlayer.assigned_animation == "fall":
        player.aniPlayer.stop()
        player.aniPlayer.clear_queue()
        player.aniPlayer.play("fall")

  # if highPriestessBoss.visible:
  #   random_tiles_timer += (delta*11)
  #   if random_tiles_timer >= random_tiles_time_limit:
  #     random_tiles_timer = 0
  #     generateRandomTiles()

func triggerCroneDialog():
  croneNPC.activate(true)

var is_defeated = false
var is_really_defeated = false
func triggerCroneDefeatedDialog():
  croneNPCDefeated.activate(true)
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("glitchTransitionStart")
  is_defeated = true
  player.pauseSelf = true
  global.shouldRenderAsCinematic = true
  musicPlayer.stopAll()

func playGlitchTransitionAnimation():
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("glitchTransition")

func enterMemoryZone():
  # global.isEnteringRoom = true
  # global.memory["roomPath"] = self.getLevelName()
  is_really_defeated = true
  aniPlayer.play("glitchTransitionEnd")
  aniPlayer.queue("croneTwitch")
  player.glitch_death_timer = 1
  player.glitchTickle()
  player.grav = 28
  glitchScreenEffect.visible = true
  # generateEyeTiles()
  player.pauseSelf = false
  player.nullify()
  global.shouldRenderAsCinematic = false
  croneNPC.grav = 20
  croneNPC.mySprite.updateBaseFrame(6, 7)
  croneNPC.is_active = true
  # transition.really_really_long_fade_to(door2.path)

func unhideHighPriestess():
  highPriestessBoss.visible = true
  highPriestessBoss.am_i_hidden = false
  highPriestessBoss.mySprite.visible = true
  highPriestessBoss.big_spawn_timer = highPriestessBoss.initial_big_spawn_timer
  highPriestessBoss.laughSound.play()
  global.pauseMoveInput = false
  global.pauseGame = false
  global.shouldRenderAsCinematic = false
  crystalGeode.queue_free()
  crystalGeode2.queue_free()
  crystalGeode3.queue_free()
  crystalGeode4.queue_free()
  crystalGeode5.queue_free()
  musicPlayer.stopAll()
  musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
  levelTiles.randomize_num = 1
  global.memory["priestess"] = 1
  # global.memory.erase("spellbookPage")
  # player.nullify()
  # global.memory["broom"] = false
  # generateEyeTiles()

  var npcPlatforms = npcPlatformContainer.get_children()
  for i in range(len(npcPlatforms)):
    npcPlatforms[i].fallthroughSolidCollisionShape.scale.x = 1.5

# var climbToEyeLevel = preload("res://levels/EndlessFantasy/gd1CrystalTower/HighPriestessRoom_001climbToEye.tscn")
# func generateEyeTiles():
#   var climbToEyeLevelInstance = climbToEyeLevel.instance()
#   var newLevelTiles = climbToEyeLevelInstance.get_node("Viewport/level/LevelTiles")
#   levelTiles.queueSausageDreamFadeAwayDifference(newLevelTiles, false)
