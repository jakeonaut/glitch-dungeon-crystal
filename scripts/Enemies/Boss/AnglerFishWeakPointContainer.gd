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
        var temp_pos = anglerFish.crystal1.global_transform.origin
        anglerFish.crystalsContainer.remove_child(anglerFish.crystal1)
        level.add_child(anglerFish.crystal1)
        anglerFish.crystal1.global_transform.origin = temp_pos
        anglerFish.crystal1.is_goddess_dream_collectible = true
        global.memory["angler_seaman"] = 2
    .getSmacked(broom_origin, silently)
    return true