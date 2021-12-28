extends AudioStreamPlayer

var save_point = preload("res://sceneObjects/SavePoint.tscn")

func _ready():
	pass

func activateScript():
	var npc = get_node("../../..")
	npc.visible = false
	npc.can_activate = false
	var new_save_point = save_point.instance()
	new_save_point.global_transform.origin = npc.global_transform.origin
	npc.get_parent().add_child(new_save_point)
	npc.get_node("../Player").glitch_death_timer = 0
	musicPlayer.changeSongPitch(0.5)

	npc.get_node("../GlitchEnemy13").visible = false

func isActive():
	# OVERRIDE ME... if you dare
	return true
