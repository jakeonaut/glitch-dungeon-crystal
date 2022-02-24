extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

enum MoleState {
	IDLE,
	PREPARE_JUMP,
	LAND,
	JUMP,
	DIG,
}
var mole_state = MoleState.IDLE
var mole_state_timer = 0
var mole_state_dig_time_limit = 10

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

var player = null
func getPlayer():
	if player == null:
		player = level.player
	return player

func _ready():
	set_process(true)
	aniPlayer.stop()
	aniPlayer.clear_queue()
	aniPlayer.play("idle")

	mySprite.material_override = mySprite.material_override.duplicate() # make unique
	myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique

func _process(delta):
	# ._process(delta) implicit
	
	delta = delta * global.time_dilation_multiplier
	aniPlayer.playback_speed = global.time_dilation_multiplier
	
	if mole_state == MoleState.IDLE:
		walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
		myOtherSprite.flip_h = walk_direction == -1
		if am_i_in_range_of_player and not aniPlayer.is_playing():
			aniPlayer.play("idle")
	elif mole_state == MoleState.DIG:
		if on_ground and not aniPlayer.is_playing():
			aniPlayer.play("dig")
		if aniPlayer.assigned_animation == "dig": 
			mole_state_timer += (delta*22)
			if mole_state_timer >= mole_state_dig_time_limit:
				digTilesBelow()
				mole_state_timer = 0
	elif mole_state == MoleState.PREPARE_JUMP:
		# run away from player
		walk_direction = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
		myOtherSprite.flip_h = walk_direction == -1
		if not aniPlayer.is_playing():
			aniPlayer.stop()
			aniPlayer.clear_queue()
			aniPlayer.queue("jumpStart")
			aniPlayer.queue("jump")
			mole_state = MoleState.JUMP
			behavior_jumping = true
	elif mole_state == MoleState.JUMP:
		behavior_walking = not on_ground
	elif mole_state == MoleState.LAND:
		if not aniPlayer.is_playing():
			mole_state = MoleState.IDLE
			aniPlayer.stop()
			aniPlayer.clear_queue()
			aniPlayer.play("idle")


	if am_i_dying:
		return

func digTilesBelow():
	var x = global_transform.origin.x
	var y = global_transform.origin.y
	var z = global_transform.origin.z
	var lb = -get_node("CollisionShape").shape.radius
	var rb = -lb
	var bb = -get_node("CollisionShape").shape.height/2
	
	var coords_a = getLevelTiles().world_to_map(Vector3(x + lb, y + bb - 0.1, z))
	var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
	var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

	print(coords_a)

	var coords_b = getLevelTiles().world_to_map(Vector3(x + rb, y + bb - 0.1, z))
	var tile_pos_b = getLevelTiles().map_to_world(coords_b.x, coords_b.y, coords_b.z)
	var tile_type_b = getLevelTiles().get_cell_item(coords_b.x, coords_b.y, coords_b.z)

	var coords_mid = getLevelTiles().world_to_map(Vector3(x, y + bb - 0.1, z))
	var tile_pos_mid = getLevelTiles().map_to_world(coords_mid.x, coords_mid.y, coords_mid.z)
	var tile_type_mid = getLevelTiles().get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

	print(coords_b)

	if isTileSolid(tile_type_a, true, 1, tile_pos_a):
		getLevelTiles().set_cell_item(coords_a.x, coords_a.y, coords_a.z, -1)
		summonSmokeClouds(2)
	if isTileSolid(tile_type_b, true, 1, tile_pos_b):
		getLevelTiles().set_cell_item(coords_b.x, coords_b.y, coords_b.z, -1)
		summonSmokeClouds(2)
	if isTileSolid(tile_type_mid, true, 1, tile_pos_mid):
		getLevelTiles().set_cell_item(coords_mid.x, coords_mid.y, coords_mid.z, -1)
		summonSmokeClouds(2)
				
# @override
func landed():
	.landed()
	behavior_jumping = false
		
	if mole_state == MoleState.JUMP:
		mole_state = MoleState.LAND
		behavior_walking = false

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate2():
	if mole_state == MoleState.IDLE or mole_state == MoleState.LAND:
		if aniPlayer.assigned_animation == "idle":
			aniPlayer.stop()
			aniPlayer.clear_queue()
		mole_state = MoleState.DIG
		mole_state_timer = 0
		behavior_walking = false

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate3():
	if mole_state == MoleState.IDLE or mole_state == MoleState.DIG or mole_state == MoleState.LAND:
		aniPlayer.stop()
		aniPlayer.clear_queue()
		aniPlayer.queue("jumpSquat")
		mole_state = MoleState.PREPARE_JUMP
		behavior_walking = false

# @override
func glitchSetSpritesAndCollision():
	pass

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
	for _i in range(num_clouds):
		var newSmokeCloud = smokeCloudRes.instance()
		level.add_child(newSmokeCloud)
		newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
		newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
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
