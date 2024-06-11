extends "../../../scripts/levelScript.gd"

onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var croneNPC = get_node("CroneNPC")
onready var crystalGeode = get_node("CubeCrystal")
onready var aniPlayer = get_node("AnimationPlayer")

var has_boss_started = false
var debug_start_boss_immediately = false
# @override
func setUpRoomInitializationOverride():
  if (global.memory.has("roomPath") and (not ("preBossRoom" in global.memory["roomPath"])))or not global.memory.has("roomPath"):
    debug_start_boss_immediately = true

  if debug_start_boss_immediately:
    highPriestessBoss.am_i_hidden = false
    highPriestessBoss.mySprite.visible = true
    crystalGeode.queue_free()
    has_boss_started = true
  else:
    highPriestessBoss.am_i_hidden = true
    highPriestessBoss.mySprite.visible = false

func unhideHighPriestess():
  highPriestessBoss.am_i_hidden = false
  global.pauseGame = false
  global.shouldRenderAsCinematic = false
  # highPriestessBoss.mySprite.visible = true # happens in aniPlayer

# @override
func overrideLevelRespawnEvent():
  pass

func _process(_delta):
  levelTiles.randomize_num = 999
  if not has_boss_started:
    if crystalGeode.getMyStaticLevelZoneVar():
      has_boss_started = true
      aniPlayer.play("appear")
      global.pauseGame = true
      global.shouldRenderAsCinematic = true