extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
var opacity = 1.0
var target_opacity = 0.2
var didja_get_me = false
var bubble_speed = 0.625

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

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    
    original_pos = global_transform.origin
    randomizeTargetPos()
    mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    if didja_get_me:
        if not mySprite.visible:
            queue_free()
    else:
        global_transform.origin.y += bubble_speed * delta

        global_transform.origin.x = global_transform.origin.x + (target_pos.x - global_transform.origin.x) * (delta)
        opacity = opacity + (target_opacity - opacity) * (delta * 2)
        mySprite.material_override.set_shader_param("opacity", opacity)
        
        if target_opacity > .5 and stepify(opacity, 0.1) == stepify(target_opacity, 0.1):
            target_opacity = 0.2
        if target_opacity < .5 and stepify(opacity, 0.1) == stepify(target_opacity, 0.1):
            target_opacity = 1.0

        if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1):
            randomizeTargetPos()

        tryDieToOffscreenCamera()
        bulletTryDieToSolids()

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()

func bulletTryDieToSolids():
    var x = global_transform.origin.x
    var y = global_transform.origin.y
    
    var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
    var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    if isTileSolid(tile_type_a, true, 1, tile_pos_a):
        bubbleStartPop()

func isTileSolid(tile_type, is_vertical, sensor_direction, tile_pos_coords):
    var checking_for_floor_collisions = is_vertical and sensor_direction == -1
    if tile_type == GridMap.INVALID_CELL_ITEM:
        return false
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    var tile_name = getLevelTiles().mesh_library.get_item_name(tile_type)
    return (tileCollisionShape is BoxShape or (checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords))) and not "Spikes" in tile_name
    
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
    var y = global_transform.origin.y
    var tb = get_node("CollisionShape").shape.height/2
    var bb = -tb
    var is_above_top_of_tile = y + bb > tile_pos_coords.y
    
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    return is_above_top_of_tile and (tileCollisionShape is PlaneShape)
        
        
func randomizeTargetPos():
    bubble_speed = rand_range(.625, 1.925)
    target_pos = Vector3(
        original_pos.x + rand_range(-3, 3),
        original_pos.y,
        original_pos.z
    )
    
func isActive(debug=false):
    return true

func passiveActivate(_delta, _is_player):
    if not didja_get_me:
        bubbleStartPop()

func bubbleStartPop():
    mySprite.frame_delay = 0.1
    mySprite.should_randomize_frame_delay = false
    mySprite.updateBaseFrame(2, 2)
    mySprite.should_soft_fizzle_out = true
    didja_get_me = true
    global_transform.origin.y += .625
