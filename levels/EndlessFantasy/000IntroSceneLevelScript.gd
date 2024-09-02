extends "../../scripts/levelScript.gd"

var cutscene_timer = 20
var should_do_cutscene = false

var has_player_died = false

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    var NPC = get_node("NPC")

    if should_do_cutscene:
        if cutscene_timer <= 115:
            global.pauseMoveInput = true
            glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (cutscene_timer - 20)*0.0001)
            glitchScreenEffect.get_material().set_shader_param("shake_power", -.00001*pow(cutscene_timer-20, 2) + .005)
            # material.set_shader_param("shake_color_rate", -.0001*pow(x-25, 2) + .005)
            glitchScreenEffect.visible = global.memory["canGlitchScreen"]
            if player.global_transform.origin.y <= 10:
                player.mySprite.get_material_override().set_shader_param("enable_glitch", true)
                var NPC5 = get_node("NPC5")
                if NPC5.visible:
                    NPC5.visible = false
                    self.summonSmokeClouds(NPC5.global_transform.origin, 5, true, true)
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