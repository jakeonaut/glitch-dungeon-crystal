extends Spatial

onready var npc = get_node("NPC")
onready var windGust = get_node("WindGust")
onready var chargeSound = get_node("ChargeSound")
onready var gustSound = get_node("GustSound")
onready var aniPlayer = get_node("AnimationPlayer")


func _ready():
  pass # Replace with function body.


var idle_timer = 0
var idle_time_limit = 30
var gusting_time_limit = 20
export var is_wind_gust_active = false
var is_smacked = false
func _process(delta):
  windGust.is_active = is_wind_gust_active
  windGust.global_transform.origin.y = npc.global_transform.origin.y + 2.0

  if npc.should_i_respond_to_smacks and npc.smackedBbText == "":
    npc.should_i_respond_to_smacks = false
  elif not npc.should_i_respond_to_smacks and npc.smackedBbText != "":
    npc.should_i_respond_to_smacks = true

  if npc.is_smacked and not is_smacked:
    # NPC just got smacked...
    is_wind_gust_active = not is_wind_gust_active
    if is_wind_gust_active:
      gustSound.play()
    else:
      chargeSound.play()
  is_smacked = npc.is_smacked