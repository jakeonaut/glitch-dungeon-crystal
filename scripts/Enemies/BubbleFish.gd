extends "GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var bigBubbleRes = preload("res://sceneObjects/BigBubbleSpell.tscn")
enum BubbleFishState {
    IDLE,
    PUFFED_UP_IDLE,
    SPITTING_BUBBLE,
    SPITTING_BUBBLE_CLOSE,
    BLOW_UP,
}
var bubble_fish_state = BubbleFishState.PUFFED_UP_IDLE
var opacity = 1.0
var original_pos = null
var target_pos = null
var idle_blow_up_timer = 0
var idle_blow_up_time_limit = 10

func _ready():
    set_process(true)
    original_pos = global_transform.origin
    randomizeTargetPos()
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2
    behavior_walking = false

func _process(delta):
    # ._process(delta) implicit
    if spawn_origin == null:
      spawn_origin = global_transform.origin

    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    # process movement
    if not is_smacked:
      global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*5)
      var diff = target_pos - global_transform.origin
      var step = 0.1
      if stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
        randomizeTargetPos()

    match bubble_fish_state:
      BubbleFishState.IDLE:
        setAnimationAndChangeStateWhenItEnds("skinnyIdle", null)
        idle_blow_up_timer += (delta*11)
        if idle_blow_up_timer >= idle_blow_up_time_limit:
          idle_blow_up_timer = 0
          bubble_fish_state = BubbleFishState.BLOW_UP
      BubbleFishState.PUFFED_UP_IDLE:
        setAnimationAndChangeStateWhenItEnds("puffedUpIdle", null)
        idle_blow_up_timer = 0
        # if am_i_in_range_of_player or override_am_i_in_range_of_player:
        #   bubble_fish_state = BubbleFishState.SPITTING_BUBBLE
      BubbleFishState.SPITTING_BUBBLE:
        setAnimationAndChangeStateWhenItEnds("spitBubble", BubbleFishState.IDLE)
        idle_blow_up_timer = 0
      BubbleFishState.SPITTING_BUBBLE:
        setAnimationAndChangeStateWhenItEnds("spitBubble", BubbleFishState.IDLE)
        idle_blow_up_timer = 0
      BubbleFishState.BLOW_UP:
        setAnimationAndChangeStateWhenItEnds("blowUp", BubbleFishState.PUFFED_UP_IDLE)

func landed():
  spawn_origin = self.global_transform.origin
  .landed()

func setAnimationAndChangeStateWhenItEnds(aniName, next_state):
  if secretAniPlayer.assigned_animation != aniName:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play(aniName)
  elif not secretAniPlayer.is_playing():
    if next_state != null:
      bubble_fish_state = next_state

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )

    # mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    # myOtherSprite.flip_h = mySprite.flip_h

# @override
func getSmacked(broom_origin = null, silently = false):
  .getSmacked(broom_origin, silently)
  if bubble_fish_state == BubbleFishState.PUFFED_UP_IDLE:
    if global.memory["broom"]:
      bubble_fish_state = BubbleFishState.SPITTING_BUBBLE_CLOSE
    else:
      bubble_fish_state = BubbleFishState.SPITTING_BUBBLE
    return true
  return false

func spitBubble():
  if bubble_fish_state == BubbleFishState.SPITTING_BUBBLE_CLOSE:
    level.player.getBubbleInfected()
  else:
    var bigBubbleSpell = bigBubbleRes.instance()
    level.add_child(bigBubbleSpell)
    bigBubbleSpell.global_transform.origin = self.global_transform.origin
    bigBubbleSpell.global_transform.origin.y -= 0.5
    if myOtherSprite.flip_h:
      bigBubbleSpell.global_transform.origin.x -= 2
    else:
      bigBubbleSpell.global_transform.origin.x += 2
    bigBubbleSpell.my_parent = self
    bigBubbleSpell.my_original_pos = bigBubbleSpell.global_transform.origin.x
    bigBubbleSpell.randomizeTargetPos()
