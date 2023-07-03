extends Spatial

onready var transformSound = get_node("TransformSound")
var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
var is_active = true

var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("Game/Viewport/level").player
    return player

func _ready():
    set_process(true)
    original_position = global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

func _process(_delta):
    pass

func isActive():
    return is_active

func passiveActivate(_delta, _is_player):
    getPlayer().nullify()
