extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
onready var floorSpell = get_node("../../../../FloorSpell")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    if not has_done_my_magick:
        NPC.textBoxContainer.bbText = ""
        NPC.textBoxContainer.setVars()
        NPC.pressing_move_left = true
        yield(get_tree().create_timer(1.00), "timeout")
        floorSpell.passiveActivate(1.0)
        yield(get_tree().create_timer(3.30), "timeout")
        NPC.pressing_move_left = false
        NPC.aniPlayer.stop()
        NPC.aniPlayer.clear_queue()
        NPC.textBoxContainer.bbText = "•your broom... how did you do that?\n... \npress DOWN to enter door"
        NPC.textBoxContainer.setVars()
        NPC.textBox.is_important = true
        NPC.textBox.is_really_important = true
        has_done_my_magick = true
    elif has_done_my_magick:
        summonSmokeClouds(NPC, 5, true, true)
        NPC.visible = false
        NPC.can_activate = false
        NPC.is_active = false
        global.doorSound.play()
    
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