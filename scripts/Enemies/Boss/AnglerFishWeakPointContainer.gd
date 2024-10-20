extends "../GlitchEnemy.gd"

onready var anglerFish = get_node("..")
var vulnerable = false
func _ready():
  pass

func isActive(_debug=false):
  return true

# @override
func glitchSetSpritesAndCollision():
  return false

# WARNING!!! WARNING!!! DO NOT LET BUBBLES HIT THE SMALL FISH, JUST A PERSONAL BROOM SMACK
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
  var boss_phase = anglerFish.boss_phase
  var BossPhase = anglerFish.BossPhase
  if boss_phase == BossPhase.HURT or boss_phase == BossPhase.DEFEATED or \
     boss_phase == BossPhase.STUN_FALL or boss_phase == BossPhase.EAT_IT:
    return false
  if boss_phase == BossPhase.STUN_IDLE:
    anglerFish.boss_phase = BossPhase.HURT
    anglerFish.secretAniPlayer.stop()
    anglerFish.secretAniPlayer.clear_queue()
    anglerFish.secretAniPlayer.play("ouchies")
    anglerFish.weakPointAniPlayer.stop()
    anglerFish.weakPointAniPlayer.clear_queue()
    anglerFish.weakPointAniPlayer.play("ouchies")
    anglerFish.num_hits += 1
    if anglerFish.num_hits >= anglerFish.MAX_NUM_HITS:
        anglerFish.boss_phase = BossPhase.DEFEATED
        anglerFish.secretAniPlayer.queue("defeated")
        var temp_pos = anglerFish.crystal1.global_transform.origin
        anglerFish.crystalsContainer.remove_child(anglerFish.crystal1)
        level.add_child(anglerFish.crystal1)
        anglerFish.crystal1.global_transform.origin = temp_pos
        anglerFish.crystal1.is_goddess_dream_collectible = true
    .getSmacked(broom_origin, silently)
    return true
  else:
    anglerFish.boss_phase = BossPhase.EAT_IT
    anglerFish.secretAniPlayer.stop()
    anglerFish.secretAniPlayer.clear_queue()
    anglerFish.lure_bullet_direction_vector = null
    anglerFish.preyTarget = weakref(level.player)
    # lureFreeRange.hooked = false
    # lureFreeRange.restorePlayer(true)
    # lureFreeRange.hookTarget = null
    anglerFish.secretAniPlayer.play("chompDown")
    anglerFish.weakPointAniPlayer.stop()
    anglerFish.weakPointAniPlayer.clear_queue()
    anglerFish.weakPointAniPlayer.play("chompDown")
    return false
    