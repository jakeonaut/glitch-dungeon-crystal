extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    var npc = get_node("NPC")
    npc.pressing_jump = false
    npc.just_pressed_jump = false
    npc.global_transform.origin.y = 4
    npc.get_node("NPC TextBox/TextBox").text_final = "i love when everything\nis green.. i can just float\nby holding jump"
