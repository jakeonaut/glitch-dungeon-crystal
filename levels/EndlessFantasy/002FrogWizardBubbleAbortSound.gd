extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
  summonSmokeClouds(NPC, 5, true, true)
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

func isActive():
    # OVERRIDE ME... if you dare
    return true


func summonSmokeClouds(npc, num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = npc.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = npc.global_transform.origin.y + rand_range(1, 2)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.cleanGlitchSound.play()
            newSmokeCloud.cleanGlitchSound.pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())
