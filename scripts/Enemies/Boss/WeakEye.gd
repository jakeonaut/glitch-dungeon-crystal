extends "../GlitchEnemy.gd"

var teleport_timer = 0
var teleport_time_limit = 20
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var sparkleSprite = get_node("SparkleSprite3D")
export var is_permanent = false
var is_fast = false
export var should_reenemizeMyself = false

onready var spikes3 = get_node("TileSpikes/Spikes3")
onready var spikes4 = get_node("TileSpikes/Spikes4")
onready var spikes5 = get_node("TileSpikes/Spikes5")
onready var spikes6 = get_node("TileSpikes/Spikes6")

func _ready():
  set_process(true)
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  if not is_permanent:
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.queue("blinkOpen")
    if is_fast:
      secretAniPlayer.queue("blinkIdleFast")
    else:
      secretAniPlayer.queue("blinkIdle")
    if global.memory["broomerang"] <= 0:
      if is_fast:
        secretAniPlayer.queue("blinkIdleFast")
      else:
        secretAniPlayer.queue("blinkIdle")
    secretAniPlayer.queue("blinkClose")

  if should_reenemizeMyself:
    reenemize(true)


var spawn_timer = 0
var spawn_time_limit = 5
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if not global.userSettings["canGlitchScreen"]:
    spikes3.mesh.material.set_shader_param("enable_glitch", false)
    spikes3.mesh.material.set_shader_param("enable_glitch_3d", false)
    spikes4.mesh.material.set_shader_param("enable_glitch", false)
    spikes4.mesh.material.set_shader_param("enable_glitch_3d", false)
    spikes5.mesh.material.set_shader_param("enable_glitch", false)
    spikes5.mesh.material.set_shader_param("enable_glitch_3d", false)
    spikes6.mesh.material.set_shader_param("enable_glitch", false)
    spikes6.mesh.material.set_shader_param("enable_glitch_3d", false)

  if "blinkClose" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing():
    queue_free()
    return
  
  spawn_timer += (delta*22)
  if spawn_timer >= spawn_time_limit:
    var newSprite = sparkleSprite.duplicate()
    newSprite.should_fizzle_out = true
    newSprite.visible = true
    var random_pos = Vector3(
        stepify(rand_range(-1.0, 1.0), 0.125),
        stepify(rand_range(0.5, 1.5), 0.125),
        0
    )
    newSprite.updateBaseFrame(0, 0)
    newSprite.max_frames = 2
    add_child(newSprite)
    newSprite.global_transform.origin = self.global_transform.origin + random_pos
    spawn_timer = 0

func ouchies(_broom_pos):
  if am_i_dying:
    return
  unenemize()
  am_i_dying = true
  if dieSound != null: dieSound.play()
  level.player.getSmacked()
  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  secretAniPlayer.queue("getHurt")
  secretAniPlayer.queue("blinkCloseFast")

  var whichBoss = level.getBoss()
  if whichBoss != null:
    whichBoss.getHurt()
  

func processDeath():
  pass

func reenemize(is_weak = false):
  if smallInteractionArea != null and not smallInteractionArea.is_in_group("enemies"):
    smallInteractionArea.add_to_group("enemies")
  if smallInteractionArea != null and is_weak and not smallInteractionArea.is_in_group("weak_enemies"):
    smallInteractionArea.add_to_group("weak_enemies")
  # if smallInteractionArea != null and is_weak and not smallInteractionArea.is_in_group("nonviolent_enemies"):
  #   smallInteractionArea.add_to_group("nonviolent_enemies")