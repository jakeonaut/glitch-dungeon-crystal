extends "../../scripts/levelScript.gd"


# @override
func _ready_impl():
    ._ready_impl()

    if global.memory["which_floor"] > 0:
        get_node("FungusNPC").queue_free()
        get_node("Door3").visible = true