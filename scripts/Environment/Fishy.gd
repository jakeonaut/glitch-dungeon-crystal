extends Spatial

var original_pos = null
var target_pos = null
onready var mySprite = get_node("Sprite3D")
onready var catchSound = get_node("CatchSound")
var is_swimmin_away = false
var opacity = 1.0

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
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
    
    var step = 1
    if is_swimmin_away:
        step = 5
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        is_swimmin_away = false
        randomizeTargetPos()
        
func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-3, 3),
        original_pos.y + rand_range(-3, 3),
        original_pos.z
    )
    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
    
func isActive(_debug=false):
    return true

func passiveActivate(_delta, _is_player, _is_local_broom = false):
    if not is_swimmin_away:
        catchSound.play()
        is_swimmin_away = true
        
    var x_min = 2
    var x_max = 3
    var y_min = 2
    var y_max = 3
    if getPlayer().global_transform.origin.x > self.global_transform.origin.x:
        x_min = -3
        x_max = -2
    if getPlayer().global_transform.origin.y > self.global_transform.origin.y:
        y_min = -3
        y_max = -2


    target_pos = Vector3(
        global_transform.origin.x + rand_range(x_min, x_max),
        global_transform.origin.y + rand_range(y_min, y_max),
        original_pos.z
    )
    mySprite.flip_h = (target_pos.x < global_transform.origin.x)
