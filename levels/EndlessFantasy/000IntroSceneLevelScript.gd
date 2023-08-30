extends "../../scripts/levelScript.gd"

var cutscene_timer = 20
var should_do_cutscene = false

var has_player_died = false
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    var NPC = get_node("NPC")

    if should_do_cutscene:
        if cutscene_timer <= 115:
            global.pauseMoveInput = true
            glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (cutscene_timer - 20)*0.0001)
            glitchScreenEffect.get_material().set_shader_param("shake_power", -.00001*pow(cutscene_timer-20, 2) + .005)
            # material.set_shader_param("shake_color_rate", -.0001*pow(x-25, 2) + .005)
            glitchScreenEffect.visible = true
            if player.global_transform.origin.y <= 10:
                player.mySprite.get_material_override().set_shader_param("enable_glitch", true)
                var NPC5 = get_node("NPC5")
                if NPC5.visible:
                    NPC5.visible = false
                    summonSmokeClouds(get_node("NPC5"), 5, true, true)
        else:
            glitchScreenEffect.visible = false
            player.mySprite.get_material_override().set_shader_param("enable_glitch", false)
            
        if player.physics_state != player.PhysicsState.NORMAL:
            player.true_terminal_vel = 32
            player.animation_speed_multiplier = 1.0
            cutscene_timer += (delta*22)
            if cutscene_timer > 40 and cutscene_timer < 45 and not NPC.get_node("AnimationPlayer").is_playing():
                NPC.passiveActivate(delta, true)
            if cutscene_timer > 100:
                NPC.passiveActivate(delta, true)
            if cutscene_timer > 115:
                global.pauseMoveInput = false
        elif cutscene_timer > 115 and global.activeInteractor == NPC.get_node("NPC TextBox/TextBox"):
            cutscene_timer = 0
            NPC.textBox.hideTextbox()
            NPC.textBox.has_been_shown = false
            should_do_cutscene = false

func summonSmokeClouds(npc, num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
      var newSmokeCloud = smokeCloudRes.instance()
      self.add_child(newSmokeCloud)
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
