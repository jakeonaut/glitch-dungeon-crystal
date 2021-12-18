extends "../../scripts/levelScript.gd"

func _ready():
    # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
    _ready_impl()

# @override
func overrideLevelRespawnEvent():
    var npc = get_node("NPC")
    npc.pressing_jump = false
    npc.just_pressed_jump = false
    npc.global_transform.origin.y = 4
    npc.get_node("NPC TextBox/TextBox").text_final = "just keep holding\njump!!\nGO LEFT TO DOOR"
