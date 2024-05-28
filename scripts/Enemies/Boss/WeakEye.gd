extends "../GlitchEnemy.gd"

var teleport_timer = 0
var teleport_time_limit = 20
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

func _ready():
  set_process(true)


func _process(delta): 
  if not secretAniPlayer.is_playing():
    teleport_timer += (delta*11)
    if teleport_timer >= teleport_time_limit:
      teleport_timer = 0
      secretAniPlayer.stop()
      secretAniPlayer.clear_queue()
      secretAniPlayer.queue("blinkClose")
      secretAniPlayer.queue("hiddenTeleport")
      secretAniPlayer.queue("blinkOpen")

func randomTeleport():
  pass
