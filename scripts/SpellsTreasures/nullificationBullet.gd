extends Spatial

onready var transformSound = get_node("TransformSound")
var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
var is_active = true

var bullet_direction_vector = Vector3(1, 0, 0)
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
onready var interactionArea = get_node("InteractionArea")

var particle_timer = 0
var particle_time_limit = 2

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var levelTiles = null
func getLevelTiles():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if levelTiles == null:
        levelTiles = level.levelTiles
    return levelTiles
    
var gameCamera = null
func getGameCamera():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if gameCamera == null:
        gameCamera = level.gameCamera
    return gameCamera

var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player

func _ready():
    set_process(true)
    original_position = global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    global_transform.origin += bullet_direction_vector * delta
    tryDieToBody()
    # bulletTryDieToSolids()
    tryDieToOffscreenCamera()

    particle_timer += (delta*22)
    if particle_timer >= particle_time_limit:
        particle_timer = 0
        var newParticle = get_node("Sprite3D").duplicate()
        newParticle.should_fizzle_out = true
        newParticle.restart()
        level.add_child(newParticle)
        newParticle.global_transform.origin = global_transform.origin

func tryDieToBody():
    var areas = interactionArea.get_overlapping_areas()
    for area in areas:
        if area.is_in_group("corporeal_body"):
            summonSmokeClouds(3)
            queue_free()

# func bulletTryDieToSolids():
#     var x = global_transform.origin.x
#     var y = global_transform.origin.y
    
#     var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
#     var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
#     var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

#     if isTileSolid(tile_type_a, true, 1, tile_pos_a):
#         summonSmokeClouds(3)
#         queue_free()

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()

func isActive():
    return is_active

func passiveActivate(_delta, _is_player):
    if getPlayer().glitch_form != global.GlitchForm.NORMAL:
        transformSound.play()
        getPlayer().applyGlitch(global.GlitchForm.NORMAL, true)

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.tryPlaySound()
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())