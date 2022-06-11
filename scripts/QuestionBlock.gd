extends KinematicBody

onready var aniPlayer = get_node("AnimationPlayer")
onready var player = get_node("../Player")
var has_been_hit = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func isActive():
	return not has_been_hit
	
func passiveActivate(_delta):
	if not has_been_hit:
		if player.linear_velocity.y < 0 or player.justPressedJump():
			has_been_hit = true
			aniPlayer.play("hit")
			summonSmokeClouds(5)
		elif player.linear_velocity.y > 0:
			has_been_hit = true
			aniPlayer.play("hitDown")
			summonSmokeClouds(5)
		
func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
	for _i in range(num_clouds):
		var newSmokeCloud = smokeCloudRes.instance()
		level.add_child(newSmokeCloud)
		newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
		newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(1, 2)
		newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
		if play_sound:
			newSmokeCloud.get_node("CleanGlitchSound").play()
			newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
			play_sound = false
		if is_glitchy:
			var new_material = newSmokeCloud.get_material_override().duplicate()
			new_material.set_shader_param("enable_glitch", "true")
			new_material.set_shader_param("target_palette", global.weird_base_palette)
			newSmokeCloud.set_material_override(new_material.duplicate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
