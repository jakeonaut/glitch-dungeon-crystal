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

# @override
func actuallyDieToOffscreenCamera(_delta):
  pass

func getSmacked(broom_origin = null, silently = false):
  if (
    anglerFish.boss_phase == anglerFish.BossPhase.STUN_IDLE or 
    anglerFish.boss_phase == anglerFish.BossPhase.GNASH_ATTACK_PREP or 
    anglerFish.boss_phase == anglerFish.BossPhase.GNASH_ATTACK_CHARGE
  ):
    notDieSound.play()
    dieSound.play()
    level.player.glitchTickle()
    anglerFish.boss_phase = anglerFish.BossPhase.HURT
    anglerFish.secretAniPlayer.stop()
    anglerFish.secretAniPlayer.clear_queue()
    anglerFish.secretAniPlayer.play("ouchies")
    anglerFish.weakPointAniPlayer.stop()
    anglerFish.weakPointAniPlayer.clear_queue()
    anglerFish.weakPointAniPlayer.play("ouchies")
    anglerFish.weakEyeAniPlayer.play("blinkCloseFast")
    if anglerFish.num_hits > 0:
      anglerFish.weakPointAniPlayer.queue("swim")
    anglerFish.num_hits += 1
    if anglerFish.cubeCrystal.get_ref() != null:
      if anglerFish.num_hits == 1:
          anglerFish.cubeCrystal.get_ref().getHitSound.play()
      elif anglerFish.num_hits == 2:
          anglerFish.cubeCrystal.get_ref().getHitSound2.play()
      elif anglerFish.num_hits == 3:
          anglerFish.cubeCrystal.get_ref().getHitSound3.play()
    if anglerFish.num_hits >= anglerFish.MAX_NUM_HITS:
        anglerFish.yaBeatMe()
    .getSmacked(broom_origin, silently)
    return true
