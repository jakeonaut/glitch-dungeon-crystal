extends InterpolatedCamera

var initial_z
onready var actual_target = get_node(target) 
onready var initial_target = get_node(target)
onready var realCamera = get_node("RealCamera")

var leftmost_x = 999
var rightmost_x = -999
var topmost_y = -999
var botmost_y = 999
var initial_size = 15

var levelTiles = null
func getLevelTiles():
    if levelTiles == null:
        levelTiles = get_tree().get_root().get_node("Game/Viewport/level").levelTiles
    return levelTiles

func _ready():
    initial_size = self.size
    initial_z = global_transform.origin.z
    
    # Wait two frames so that levelTiles on levelScript is available
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")

    global_transform.origin.x = initial_target.global_transform.origin.x
    global_transform.origin.y = initial_target.global_transform.origin.y
    
    var tile_coords = getLevelTiles().get_used_cells()
    
    for i in range(len(tile_coords)):
        var coords = tile_coords[i]
        var TILE_WIDTH = getLevelTiles().cell_size.x
        var TILE_HEIGHT = getLevelTiles().cell_size.y
        var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
        var tile_x = tile_pos.x - TILE_WIDTH/2
        var tile_y = tile_pos.y - TILE_HEIGHT/2

        if tile_x < leftmost_x:
            leftmost_x = tile_x
        if tile_x + TILE_WIDTH > rightmost_x:
            rightmost_x = tile_x + TILE_WIDTH
        if tile_y < botmost_y:
            botmost_y = tile_y
        if tile_y + TILE_HEIGHT > topmost_y:
            topmost_y = tile_y + TILE_HEIGHT

func _process(delta):
    global_transform.origin.z = initial_z
    # d=√((x_2-x_1)²+(y_2-y_1)²)
    var distance = global_transform.origin.distance_to(actual_target.global_transform.origin)

    if distance > 19.8:
        set_interpolation_enabled(true)
        set_speed(7)
    elif distance > 19.7:
        set_interpolation_enabled(true)
        set_speed(5)
    elif distance > 19.6:
        set_interpolation_enabled(true)
        set_speed(4)
    elif distance > 19.5:
        set_interpolation_enabled(true)
        set_speed(3)
    elif distance > 19.4:
        set_interpolation_enabled(true)
        set_speed(2)
    elif distance < 19.33 and global.activeInteractor == null:
        set_interpolation_enabled(false)

    if global.activeInteractor != null and global.activeInteractor.focus_me and initial_size > 12:
        actual_target = global.activeInteractor.get_node("../..")
        set_target(actual_target)
        # interpolation = A + (B - A) * t
        if not global.activeInteractor.tiny:
            self.size = self.size + (12 - self.size) * (delta*5)
        set_speed(2)
        set_interpolation_enabled(true)
    else:
        actual_target = initial_target
        set_target(actual_target)
        self.size = self.size + (initial_size - self.size) * (delta*5)
        
    respectLevelTilesEdges()
    
    # TODO(jaketrower): This value "0.12" should actually somehow be calculated based on the camera's size
    realCamera.size = self.size
    realCamera.global_transform.origin.x = stepify(self.global_transform.origin.x, 0.06)
    realCamera.global_transform.origin.y = stepify(self.global_transform.origin.y, 0.06)    

func respectLevelTilesEdges():
    # respect left and right, dependent on gameCamera size
    var x_margin = 10 - ((15-self.size)/1.5)
    if global_transform.origin.x < leftmost_x + x_margin:
        global_transform.origin.x = leftmost_x + x_margin
    if global_transform.origin.x > rightmost_x - x_margin:
        global_transform.origin.x = rightmost_x - x_margin
        
    # respect top and bottom, dependent on gameCamera size
    var y_margin = 7.5 - ((15-self.size)/2)
    if global_transform.origin.y < botmost_y + y_margin:
        global_transform.origin.y = botmost_y + y_margin
    if global_transform.origin.y > topmost_y - y_margin:
        global_transform.origin.y = topmost_y - y_margin
        
func isNearBottom():
    # print("is near bottom?: " + str(global_transform.origin.y) + " < " + str(botmost_y + 8) + " : " + str(global_transform.origin.y < botmost_y + 8))
    return global_transform.origin.y < botmost_y + 8
    
func isInitialTargetNearBottom():
    # print("is near bottom?: " + str(initial_target.global_transform.origin.y) + " < " + str(botmost_y + 5) + " : " + str(initial_target.global_transform.origin.y < botmost_y + 4))
    return initial_target.global_transform.origin.y < botmost_y + 4
