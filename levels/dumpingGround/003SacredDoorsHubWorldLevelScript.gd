extends "../../scripts/levelScript.gd"


# @override
func _ready_impl():
    ._ready_impl()

    if global.memory.has("roomPath") and (not ("0_1Haven" in global.memory["roomPath"])):
        get_node("FungusNPC").queue_free()
        get_node("Door3").visible = true
