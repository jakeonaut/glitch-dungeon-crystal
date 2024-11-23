extends "GlitchEnemy.gd"

onready var fishingRod = get_node("FishingRod")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var am_revealed = false
var is_hook_got_something = false
var was_hook_got_something = false
func _ready():
  set_process(true)

  if global.has_revealed_an_angler_fish:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("revealQuiet")
    am_revealed = true

func _process(_delta):
  if am_i_dying:
    return

  is_hook_got_something = fishingRod.hookTarget != null
  fishingRod.max_speed = 6

  if not gulping:
    if not am_revealed:
      if is_hook_got_something and not was_hook_got_something:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("reveal")
        am_revealed = true
        global.has_revealed_an_angler_fish = true
    else:
      if is_hook_got_something and not was_hook_got_something:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("openMouth")
        global.has_revealed_an_angler_fish = true

  was_hook_got_something = is_hook_got_something

func fallthroughCollisionActivate(friend):
  if friend == level.player:
    passiveActivate(0, true)

var origin_before_teleportation = null
# @override
func unsmack():
  .unsmack()
  if gulping or am_i_dying:
    return
  # if origin_before_teleportation != null:
  #   origin_before_teleportation = self.global_transform.origin
  # self.global_transform.origin = level.player.global_transform.origin
  # .passiveActivate(0, true)

# @override
func getSmacked(broom_origin = null, silently = false):
  if is_smacked or am_i_dying:
    return false
  .getSmacked(broom_origin, silently)

var gulping = false
var nowWhoAmIEating = null
func passiveActivate(_delta, is_player):
  if gulping or am_i_dying:
    return
  if is_player and level.player.canIGetCaught():
    am_revealed = true
    gulping = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("digest")
    global.has_revealed_an_angler_fish = true
    level.player.visible = false
    level.player.physics_state = level.player.PhysicsState.IGNORE_PHYSICS
    nowWhoAmIEating = level.player
  elif origin_before_teleportation != null:
    self.global_transform.origin = origin_before_teleportation

func otherPassiveActivate(_delta, gameMover):
  if gulping or am_i_dying:
    return
  am_revealed = true
  gulping = true
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  secretAniPlayer.play("hurtMyToof")
  secretAniPlayer.queue("cry")
  global.has_revealed_an_angler_fish = true
  gameMover.visible = false
  gameMover.physics_state = gameMover.PhysicsState.IGNORE_PHYSICS
  nowWhoAmIEating = gameMover
  
func swallowPlayer():
  if nowWhoAmIEating == level.player:
    if level.player.malware_infected:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("corrupt")
    else:
      level.player.tryDieToEnemy(0, true, true, true)
      gulping = false
      if origin_before_teleportation != null:
        self.global_transform.origin = origin_before_teleportation
  elif nowWhoAmIEating != null:
    # gulping = false
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("cry")

func getCorruptedAndDie():
  level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
  nowWhoAmIEating.tumbleFall(Vector2(1 if mySprite.flip_h else -1, 0))
  nowWhoAmIEating.global_transform.origin = self.global_transform.origin
  nowWhoAmIEating.global_transform.origin.y += 1
  nowWhoAmIEating.visible = true
  # nowWhoAmIEating.aniPlayer.stop()
  nowWhoAmIEating = null
  # visible = false
  # am_i_dying = true
  # fallthroughSolid.remove_from_group("fallthrough")
