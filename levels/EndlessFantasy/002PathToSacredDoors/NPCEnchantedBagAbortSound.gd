extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")
onready var sprite3DBag = get_node("../../../Sprite3DBag")

func isActive():
    return true

# TODO(jaketrower): CLEAN UP BASED ON MEMORY
func activateScript():
    sprite3DBag.visible = false
    global.memory["max_hp"] = 2
    global.memory["hp"] = 2
    level.player.textContainer.bbText = "oh! thank you kizzy\nBAG should come in handy"
    level.player.textContainer.setVars()
    level.player.textBox.tinify()
    level.player.textBox.interact()