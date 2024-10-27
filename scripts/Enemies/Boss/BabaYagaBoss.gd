extends Spatial

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("SpriteContainer/Sprite3D")
onready var crystalsContainer = get_node("SpriteContainer/Crystals")
onready var crystal1 = get_node("SpriteContainer/Crystals/HighpriestessCrystal")

var MAX_NUM_HITS = 3

enum BossPhase {
    ASLEEP,
    WAKEUP
    IDLE,
}
var boss_phase = BossPhase.ASLEEP

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    crystal1.applyGlitchMaterial(5)

var num_hits = 0
func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()

func _process(_delta):
    if global.pauseGame:
        return

    if boss_phase == BossPhase.ASLEEP:
        if Input.is_action_just_pressed("sub_action_button"):
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
    if boss_phase == BossPhase.WAKEUP:
        pass
    if boss_phase == BossPhase.IDLE:
        pass
   
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles
