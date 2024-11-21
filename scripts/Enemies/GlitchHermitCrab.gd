extends "GlitchEnemy.gd"

onready var thudSound = get_node("Sounds/ThudSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
enum CrabState {
    IDLE,
    PREPARE_THROW,
    THROW,
    SCURRY_AWAY,
}
var crab_state = CrabState.IDLE
var opacity = 1.0
var hermitCrabShell = null
onready var myManager = get_node("..")

func _ready():
    if getMyStaticLevelZoneVar():
        visible = false
        queue_free()
        return

    set_process(true)
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2

func _process(delta):
    # ._process(delta) implicit

    if not visible:
      return

    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
      updateMyHermitCrabShellPos()

    match crab_state:
      CrabState.IDLE:
        behavior_walking = false
        myOtherSprite.flip_h = level.player.global_transform.origin.x <= global_transform.origin.x
        if Input.is_action_just_pressed("sub_action_button"):
          crab_state = CrabState.PREPARE_THROW    
      CrabState.PREPARE_THROW:
        setAnimationAndChangeStateWhenItEnds("prepareToThrow", CrabState.THROW)
        behavior_walking = false
      CrabState.THROW:
        setAnimationAndChangeStateWhenItEnds("throwShell", CrabState.SCURRY_AWAY)
        behavior_walking = false
      CrabState.SCURRY_AWAY:
        myOtherSprite.flip_h = level.player.global_transform.origin.x > global_transform.origin.x
        walk_direction.x = 1 if not myOtherSprite.flip_h else -1
        setAnimationAndChangeStateWhenItEnds("walkNaked", null)
        behavior_walking = true
        walk_speed = 8

        opacity = opacity + (0.0 - opacity) * (delta * 5)
        myOtherSprite.material_override.set_shader_param("opacity", opacity)
        if stepify(opacity, 0.1) == 0:
            visible = false
            opacity = 1.0
            myOtherSprite.material_override.set_shader_param("opacity", opacity)

func setAnimationAndChangeStateWhenItEnds(aniName, next_state):
  if secretAniPlayer.assigned_animation != aniName:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play(aniName)
  elif not secretAniPlayer.is_playing():
    if next_state != null:
      crab_state = next_state

var myHermitCrabShell = null
func summonHermitCrabShell():
  if myManager.hermitCrabShell.get_ref() != null:
    myHermitCrabShell = weakref(myManager.hermitCrabShell.get_ref())
    myHermitCrabShell.get_ref().visible = true
    myHermitCrabShell.get_ref().secretAniPlayer.stop()
    myHermitCrabShell.get_ref().secretAniPlayer.clear_queue()
    myHermitCrabShell.get_ref().secretAniPlayer.play("RESET")
    updateMyHermitCrabShellPos()

func throwPreparedShell():
  if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
    var direction_vector = Vector2(1 if not myOtherSprite.flip_h else -1, 0)
    myHermitCrabShell.get_ref().tumbleFall(direction_vector, false)
    myHermitCrabShell = null

func updateMyHermitCrabShellPos():
  if myHermitCrabShell != null and myHermitCrabShell.get_ref() != null:
    myHermitCrabShell.get_ref().global_transform.origin = self.global_transform.origin
    myHermitCrabShell.get_ref().global_transform.origin.y += 1
    myHermitCrabShell.get_ref().myOtherSprite.flip_h = self.myOtherSprite.flip_h

# @override
func actuallyDieToOffscreenCamera():
  if is_static_in_level:
    setGlobalMemoryOfHasBeenDefeated()
    trySpawnACrystal()
  myManager.queue_free()
