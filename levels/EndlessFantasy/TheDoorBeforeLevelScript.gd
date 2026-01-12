extends "../../scripts/levelScript.gd"

onready var timeKeeper = get_node("TimeKeeper") if has_node("TimeKeeper") else null
export(String, "angler_seaman_boss", "dogu_matryoshka_boss", "baba_yaga_boss") var boss_var_name

# @override
func setUpRoomInitializationOverride():
  if global.memory[boss_var_name] >= 1 and global.memory[boss_var_name] < 3 and global.memory["hard_mode"] == 0 and timeKeeper and not global.memory["secret_bauble"]:
    timeKeeper.visible = false
    yield(get_tree().create_timer(1.0), "timeout")
    self.summonSmokeClouds(timeKeeper.global_transform.origin, 3, true, true)
    timeKeeper.visible = true
  elif timeKeeper:
    timeKeeper.queue_free()

var has_updated_elder_text = false
func _process(_delta):
  # ._process(delta) implicit
  pass
