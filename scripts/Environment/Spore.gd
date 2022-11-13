extends Spatial

# this is just Bubble.gd reversed... could make them a common script

var original_pos = null
var target_pos = null
var opacity = 1.0
var target_opacity = 0.5
var didja_get_me = false
var bubble_speed = 0

onready var mySprite = get_node("Sprite3D")
onready var interactionArea = get_node("SmallInteractionArea")

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
        global_transform.origin.y -= bubble_speed * delta

        global_transform.origin.x = global_transform.origin.x + (target_pos.x - global_transform.origin.x) * (delta)
        opacity = opacity + (target_opacity - opacity) * (delta * 2)
        mySprite.material_override.set_shader_param("opacity", opacity)
        
        if target_opacity > .5 and stepify(opacity, target_opacity) == 0:
            target_opacity = 0.2
        if target_opacity < .5 and stepify(opacity, target_opacity) == 0:
            target_opacity = 1.0

        var diff_x = target_pos.x - global_transform.origin.x
        var step = 0.1
        if stepify(abs(diff_x), step) == 0:
            randomizeTargetPos()

        tryDieToOffscreenCamera()
        bulletTryDieToSolids()
        if interactionArea.is_touching_water and interactionArea.touched_water_area != null:
            bubbleStartPop()
            interactionArea.touched_water_area.get_node("..").becomePoisonous()


func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()

func bulletTryDieToSolids():
    if didja_get_me:
        return
    var x = global_transform.origin.x
    var y = global_transform.origin.y - .25
    
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
    return tileCollisionShape is BoxShape or (checking_for_floor_collisions and isTileFallthroughSolidTop(tile_type, tile_pos_coords))
    
func isTileFallthroughSolidTop(tile_type, tile_pos_coords):
    var y = global_transform.origin.y
    var tb = get_node("CollisionShape").shape.height/2
    var bb = -tb
    var is_above_top_of_tile = y + bb > tile_pos_coords.y
    
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    return is_above_top_of_tile and (tileCollisionShape is PlaneShape)
        
func randomizeTargetPos():
    bubble_speed = rand_range(1.925, 3.8)
    target_pos = Vector3(
        original_pos.x + rand_range(-3, 3),
        original_pos.y,
        original_pos.z
    )
    
func isActive():
    return true

func passiveActivate(_delta):
    if not didja_get_me:
        bubbleStartPop()
        getPlayer().glitchTickle()

func bubbleStartPop():
    didja_get_me = true
    mySprite.max_frames = 6
    mySprite.should_soft_fizzle_out = true
