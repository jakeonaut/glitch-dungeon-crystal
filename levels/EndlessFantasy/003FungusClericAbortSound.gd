extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
onready var fungusNPC2 = get_node("../../../../FungusNPC2")
onready var fungusNPC3 = get_node("../../../../FungusNPC3")
onready var fungusNPC4 = get_node("../../../../FungusNPC4")
onready var angelStatue = get_node("../../../../AngelStatue")
onready var glitchSlime2 = get_node("../../../../GlitchSlime2")
onready var glitchSlime3 = get_node("../../../../GlitchSlime3")
onready var glitchEnemy2 = get_node("../../../../GlitchEnemy2")
onready var glitchEnemy3 = get_node("../../../../GlitchEnemy3")
onready var glitchEnemy4 = get_node("../../../../GlitchEnemy4")
onready var smallKey = get_node("../../../../SmallKey")
# onready var broom = get_node("../../../../Broom")
export var which_one_am_i = 1
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    summonSmokeClouds(NPC, 5, true, true)
    NPC.visible = false
    NPC.can_activate = false
    NPC.is_active = false
    yield(get_tree().create_timer(0.5), "timeout")

    if which_one_am_i == 1:
      summon(fungusNPC2)
    elif which_one_am_i == 2:
      summon(fungusNPC3)
      pass
    elif which_one_am_i == 3:
      summon(smallKey, false)

func summon(npc, set_vars = true):
  yield(get_tree().create_timer(0.4), "timeout")
  summonSmokeClouds(npc, 5, true, true)
  npc.visible = true
  if set_vars:
    npc.can_activate = true
    npc.is_active = true

func summonAngelStatue():
  summonSmokeClouds(angelStatue, 5, true, true)
  angelStatue.visible = true

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
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())
