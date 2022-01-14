extends AudioStreamPlayer

var fishy = preload("res://sceneObjects/Fish.tscn")

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.visible = false
    npc.can_activate = false
    npc.is_active = false
    var new_self = fishy.instance()
    new_self.global_transform.origin = npc.global_transform.origin
    npc.get_parent().add_child(new_self)
    npc.get_node("../Player").glitch_death_timer = 0
    musicPlayer.changeSongPitch(0.5)

    npc.get_node("../GlitchEnemy13").visible = false

func isActive():
    # OVERRIDE ME... if you dare
    return true
