extends "../../scripts/levelScript.gd"

var cutscene_timer = 20
var should_do_cutscene = false

var has_player_died = false

# @override
func _ready_impl():
    ._ready_impl()

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if should_do_cutscene:
        if cutscene_timer <= 115:
            global.pauseMoveInput = true
            glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (cutscene_timer - 20)*0.0001)
            glitchScreenEffect.get_material().set_shader_param("shake_power", -.00001*pow(cutscene_timer-20, 2) + .005)
            # material.set_shader_param("shake_color_rate", -.0001*pow(x-25, 2) + .005)
            glitchScreenEffect.visible = true
            if player.global_transform.origin.y <= 30:
                player.mySprite.get_material_override().set_shader_param("enable_glitch", true)
        else:
            glitchScreenEffect.visible = false
            player.mySprite.get_material_override().set_shader_param("enable_glitch", false)
            
        if player.physics_state != player.PhysicsState.NORMAL:
            player.true_terminal_vel = 32
            player.animation_speed_multiplier = 1.0
            cutscene_timer += (delta*22)
            if cutscene_timer > 40 and cutscene_timer < 45 and not get_node("NPC3/AnimationPlayer").is_playing():
                get_node("NPC3").passiveActivate(delta, true)
            if cutscene_timer > 100:
                get_node("NPC3").passiveActivate(delta, true)
            if cutscene_timer > 115:
                global.pauseMoveInput = false
        elif cutscene_timer > 115 and global.activeInteractor == get_node("NPC3/NPC TextBox/TextBox"):
            cutscene_timer = 0
            get_node("NPC3").textBox.hideTextbox()
            get_node("NPC3").textBox.has_been_shown = false
            should_do_cutscene = false

func overrideLevelRespawnEvent():
    if has_player_died:
        var npc = get_node("NPC8")
        # npc.textBox.has_been_shown = (npc.textBox.text_final == "•what, you don't\nlike it?")
        yield(TempTimer.idle_frame(self), "timeout")
        yield(TempTimer.idle_frame(self), "timeout")
        npc.textBox.hideTextbox()
        # npc.textBox.text_final = "•what, you don't\nlike it?\npress [ENTER] to change"
        npc.textBox.has_been_shown = false
    has_player_died = true
