extends AudioStreamPlayer

var save_point = preload("res://sceneObjects/SavePoint.tscn")

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.level.glitchScreenEffect.visible = false
    npc.level.player.glitch_death_timer = -3200

func isActive():
    # OVERRIDE ME... if you dare
    return true
