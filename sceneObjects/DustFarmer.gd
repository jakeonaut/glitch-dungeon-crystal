extends Spatial

onready var npc = get_node("NPC")
onready var windGust = get_node("WindGust")
onready var aniPlayer = get_node("AnimationPlayer")


func _ready():
  pass # Replace with function body.


var idle_timer = 0
var idle_time_limit = 30
var gusting_time_limit = 20
var is_active = false
func _process(delta):
  if not aniPlayer.is_playing():
    if is_active:
      idle_timer += (delta*22)
      if idle_timer >= gusting_time_limit:
        aniPlayer.play("windDown")
        is_active = false
    else:
      idle_timer += (delta*22)
      if idle_timer >= idle_time_limit:
        aniPlayer.play("chargeUp")
        is_active = true
  else:
    idle_timer = 0
