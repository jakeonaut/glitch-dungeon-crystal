extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.visible = false
    npc.can_activate = false

func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true
