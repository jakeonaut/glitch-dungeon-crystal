extends "../../scripts/levelScript.gd"

var cutscene_timer = 0
var should_do_cutscene = false

var has_player_died = false

# @override
func _ready_impl():
    ._ready_impl()
    
    if not global.memory.has("roomPath"):
        global.pauseMoveInput = true
        should_do_cutscene = true

func _process(delta):
    if should_do_cutscene:
        if player.physics_state != player.PhysicsState.NORMAL:
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
        print(npc.textBox.has_been_shown)
        npc.textBox.hideTextbox()
        npc.textBox.text_final = "what, you don't\nlike it?"
    has_player_died = true
