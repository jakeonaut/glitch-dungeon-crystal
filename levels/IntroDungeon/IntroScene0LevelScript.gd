extends "../../scripts/levelScript.gd"

var cutscene_timer = 20
var should_do_cutscene = false

var has_player_died = false

# @override
func _ready_impl():
    ._ready_impl()
    
    if not global.memory.has("roomPath"):
        global.pauseMoveInput = true
        should_do_cutscene = true
        player.applyGlitch(global.GlitchForm.NORMAL)
        player.true_terminal_vel = 5
        player.aniPlayer.playback_speed = 0.3
        player.aniPlayer.remove_animation("fallFar")
        player.aniPlayer.add_animation("fallFar", player.aniPlayer.get_animation("fall"))

func _process(delta):
    if should_do_cutscene:
        if player.physics_state != player.PhysicsState.NORMAL:
            player.true_terminal_vel = 32
            player.aniPlayer.playback_speed = 1
            cutscene_timer += (delta*22)
            if cutscene_timer > 40 and cutscene_timer < 45 and not get_node("NPC3/AnimationPlayer").is_playing():
                get_node("NPC3/AnimationPlayer").play("flickerOn")
            if cutscene_timer > 100:
                get_node("NPC3").passiveActivate(delta)
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
        npc.textBox.has_been_shown = (npc.textBox.text_final == "what, you don't\nlike it?")
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        npc.textBox.hideTextbox()
        npc.textBox.text_final = "what, you don't\nlike it?\npress [ENTER] to change"
        npc.textBox.has_been_shown = false
    has_player_died = true
