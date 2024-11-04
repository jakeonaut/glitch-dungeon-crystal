extends "../GlitchEnemy.gd"

onready var anglerFish = get_node("..")
var vulnerable = false
func _ready():
  pass

func isActive(_debug=false):
  return vulnerable

# @override
func glitchSetSpritesAndCollision():
  return false

# WARNING!!! WARNING!!! DO NOT LET BUBBLES HIT THE SMALL FISH, JUST A PERSONAL BROOM SMACK
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  if anglerFish.boss_phase == anglerFish.BossPhase.STUN_IDLE:
    notDieSound.play()
    dieSound.play()
    anglerFish.boss_phase = anglerFish.BossPhase.HURT
    anglerFish.secretAniPlayer.stop()
    anglerFish.secretAniPlayer.clear_queue()
    anglerFish.secretAniPlayer.play("ouchies")
    anglerFish.weakPointAniPlayer.stop()
    anglerFish.weakPointAniPlayer.clear_queue()
    anglerFish.weakPointAniPlayer.play("ouchies")
    anglerFish.num_hits += 1
    if anglerFish.num_hits >= anglerFish.MAX_NUM_HITS:
        anglerFish.boss_phase = anglerFish.BossPhase.DEFEATED
        anglerFish.secretAniPlayer.queue("defeated")
        global.memory["angler_seaman_boss"] = 2
    .getSmacked(broom_origin, silently)
    return true
