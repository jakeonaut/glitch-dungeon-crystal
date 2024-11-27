extends "GlitchEnemy.gd"

onready var fishingRod = get_node("FishingRod")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var smallKeyRes = preload("res://sceneObjects/SpellsTreasureCollectables/SmallKey.tscn")
var am_revealed = false
var is_hook_got_something = false
var was_hook_got_something = false
export var has_a_key = false

func _ready():
  set_process(true)

  if global.has_revealed_an_angler_fish:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("revealQuiet")
    am_revealed = true
  if has_a_key and not self.getMyStaticLevelZoneVar():
    mySprite.material_override.set_shader_param("target_palette", global.white_palette)

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

    if (secretAniPlayer.assigned_animation == "reveal" or secretAniPlayer.assigned_animation == "openMouth") and not secretAniPlayer.is_playing() and not is_hook_got_something:
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("closeMouthCoyly")

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

# @ override
func isActive(_debug=false):
  # same as GlitchEnemy.gd except allow is_smacked to still count as "active"
  return visible and not behavior_evolve and not is_frozen and not am_i_dying and (glitch_form == global.GlitchForm.NORMAL or glitch_form == getPlayer().glitch_form)

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
  if not self.getMyStaticLevelZoneVar():
    var hurtMyToofAnimation = secretAniPlayer.get_animation("hurtMyToof")
    hurtMyToofAnimation.length = 2.1
  secretAniPlayer.play("hurtMyToof")
  secretAniPlayer.queue("cry")
  global.has_revealed_an_angler_fish = true
  gameMover.visible = false
  gameMover.physics_state = gameMover.PhysicsState.IGNORE_PHYSICS
  nowWhoAmIEating = gameMover
  
func swallowPlayer():
  if nowWhoAmIEating == level.player:
    level.player.tryDieToEnemy(0, true, true, true)
    gulping = false
    if origin_before_teleportation != null:
      self.global_transform.origin = origin_before_teleportation
  elif nowWhoAmIEating != null:
    # gulping = false
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("cry")

func owie():
  level.summonSmokeClouds(self.global_transform.origin, 3, true, true)

func getCorruptedAndDie():
  nowWhoAmIEating.tumbleFall(Vector2(1 if mySprite.flip_h else -1, 0))
  nowWhoAmIEating.global_transform.origin = self.global_transform.origin
  nowWhoAmIEating.global_transform.origin.y += 1
  nowWhoAmIEating.visible = true
  # nowWhoAmIEating.aniPlayer.stop()
  nowWhoAmIEating = null
  # visible = false
  # am_i_dying = true
  # fallthroughSolid.remove_from_group("fallthrough")

func spitOutAKey():
  if self.getMyStaticLevelZoneVar():
    return

  global.setStaticLevelZoneLevelVar(level, self, self.global_transform.origin)
  mySprite.material_override.set_shader_param("target_palette", global.grey_palette)
  if has_a_key:
    var smallKey = smallKeyRes.instance()
    level.add_child(smallKey)
    smallKey.global_transform.origin = self.global_transform.origin
    if mySprite.flip_h:
      smallKey.override_press_move_right = true
    else:
      smallKey.override_press_move_left = true
  else:
    trySpawnACrystal()