extends AudioStreamPlayer

onready var npc = get_node("../../..")
onready var sprite3DBag = get_node("../../../Sprite3DBag")

func isActive():
    return true

# TODO(jaketrower): CLEAN UP BASED ON MEMORY
func activateScript():
    sprite3DBag.visible = false
    global.memory["max_hp"] = 2
    global.memory["hp"] = 2
