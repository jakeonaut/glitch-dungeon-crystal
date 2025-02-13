extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    var npc = get_node("NPC")
    npc.pressing_jump = false
    npc.just_pressed_jump = false
    npc.global_transform.origin.y = 4
