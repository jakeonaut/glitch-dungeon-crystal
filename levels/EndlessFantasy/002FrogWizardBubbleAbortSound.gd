extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
  level.summonSmokeClouds(NPC.global_transform.origin, 5, true, true)
  var material = NPC.mySprite.material_override.duplicate()
  material.set_shader_param("enable_palette_cycle", true)
  material.set_shader_param("palette_cycle_speed", 5)
  NPC.mySprite.material_override = material
  level.get_node("BubbleSpellSpawners/Spawner1").is_active = true
  level.get_node("BubbleSpellSpawners/Spawner1pt5").is_active = true
  level.get_node("BubbleSpellSpawners/Spawner2").is_active = true
  if level.has_node("NPC4"):
    level.get_node("NPC4").queue_free()
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true