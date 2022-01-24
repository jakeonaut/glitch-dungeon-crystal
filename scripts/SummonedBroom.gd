extends Spatial


var broom_active_timer = 0
var broom_active_time_limit = 10 
var my_broom_owner = null
onready var broomSound = get_node("BroomSound")
var broomSoundTimer = 0
var broomSoundTimeLimit = 5
var broomSoundCounter = 0
var broomSoundCountLimit = 2
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var myArea = get_node("Area")
onready var collisionShape = get_node("Area/CollisionShape")

var levelTiles = null
func getLevelTiles():
	if levelTiles == null:
		levelTiles = level.levelTiles
	return levelTiles


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	broomSound.play()
	broomSoundCounter += 1


func _process(delta):
	cleanUpGlitches()
	broom_active_timer += (delta*22)
	if broom_active_timer >= broom_active_time_limit:
		broom_active_timer = 0
		if my_broom_owner: my_broom_owner.broomStop()
		visible = false
		summonSmokeClouds(3)
		
	if visible:
		broomSoundTimer += (delta*22)
		if broomSoundTimer >= broomSoundTimeLimit:
			broomSoundTimer = 0
			if broomSoundCounter < broomSoundCountLimit:
				broomSound.play()
				broomSoundCounter += 1
	if not visible and not broomSound.is_playing():
		queue_free()
		
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
		if is_glitchy:
			var new_material = newSmokeCloud.get_material_override().duplicate()
			new_material.set_shader_param("enable_glitch", "true")
			new_material.set_shader_param("target_palette", global.weird_base_palette)
			newSmokeCloud.set_material_override(new_material.duplicate())
		
func isTileSpikes(tile_type):
	if tile_type == GridMap.INVALID_CELL_ITEM:
		return false
	var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
	return tileCollisionShape is RayShape
		
func cleanUpGlitches():
	var areas = myArea.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
			area.get_node("..").ouchies()
			summonSmokeClouds(5, false, true)
			# TODO kill glitches or "free" them like glitch slug...
			pass

	# erase glitch tiles...
	var x = collisionShape.global_transform.origin.x
	var y = collisionShape.global_transform.origin.y
	var tb = y + collisionShape.shape.height/2
	var bb = y - collisionShape.shape.height/2
	var lb = x - collisionShape.shape.radius
	var rb = x + collisionShape.shape.radius
	
	var has_played_sound = false
	for i in range(int(floor(bb)), int(ceil(tb))):
		for j in range(int(floor(lb)), int(ceil(rb))):
			var coords = getLevelTiles().world_to_map(Vector3(j, i, collisionShape.global_transform.origin.z))
			var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
			var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
			if isTileSpikes(tile_type):
				getLevelTiles().set_cell_item(coords.x, coords.y, coords.z, GridMap.INVALID_CELL_ITEM)
				summonSmokeClouds(2, not has_played_sound, true)
				has_played_sound = true
				# TODO(jaketrower): also reset the levelTiles array position?
	

func isActive():
	return visible
