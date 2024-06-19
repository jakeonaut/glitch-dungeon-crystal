extends "../../../scripts/levelScript.gd"

onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var croneNPC = get_node("CroneNPC")
onready var crystalGeode = get_node("CubeCrystal")
onready var crystalGeode2 = get_node("CubeCrystal2")
onready var crystalGeode3 = get_node("CubeCrystal3")
onready var crystalGeode4 = get_node("CubeCrystal4")
onready var crystalGeode5 = get_node("CubeCrystal5")
onready var aniPlayer = get_node("AnimationPlayer")

var has_boss_started = false
var debug_start_boss_immediately = false
# @override
func setUpRoomInitializationOverride():
  if not global.memory.has("roomPath"):
    debug_start_boss_immediately = true
  if crystalGeode.getMyStaticLevelZoneVar():
    debug_start_boss_immediately = true

  if debug_start_boss_immediately:
    gameCamera.initial_size = 35
    gameCamera.zoomed_size = 35
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

func _process(_delta):
  if not has_boss_started:
    if crystalGeode.getMyStaticLevelZoneVar():
      has_boss_started = true
      levelTiles.randomize_num = 999
      aniPlayer.play("appear")
      gameCamera.initial_size = 35
      gameCamera.zoomed_size = 35
      global.pauseMoveInput = true
      global.pauseGame = true
      global.shouldRenderAsCinematic = true
      musicPlayer.stopAll()

func triggerCroneDialog():
  croneNPC.activate(true)

func unhideHighPriestess():
  highPriestessBoss.visible = true
  highPriestessBoss.am_i_hidden = false
  highPriestessBoss.mySprite.visible = true
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
  global.memory["has_seen_highpriestess"] = true
  global.memory.erase("spellbookPage")
  player.nullify()
