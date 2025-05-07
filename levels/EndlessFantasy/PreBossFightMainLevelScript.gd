extends "../../scripts/levelScript.gd"

onready var heartMimic = get_node("HeartMimic")
export(String, "angler_seaman_boss", "dogu_matryoshka_boss", "baba_yaga_boss") var boss_var_name

# @override
func setUpRoomInitializationOverride():
  if global.memory[boss_var_name] >= 1:
    yield(get_tree().create_timer(1.0), "timeout")
    self.summonSmokeClouds(heartMimic.global_transform.origin, 3, true, true)
    heartMimic.visible = true

var has_updated_elder_text = false
func _process(_delta):
  # ._process(delta) implicit
  pass