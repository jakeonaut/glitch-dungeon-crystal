extends KinematicBody

onready var transformSound = get_node("TransformSound")
var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
var is_active = true

var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("level").player
    return player

func _ready():
    set_process(true)
    original_position = global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(
        original_position.x + (randf() * 1) - .5, 
        original_position.y + (randf() * 1) - .5, 
        original_position.z)

func _process(delta):
    pass
    # global_transform.origin = previous_point.linear_interpolate(interpolation_point, t)
    # t += (delta*2)
    # if t >= 1:
    #     previous_point = interpolation_point
    #     if not is_active:
    #         if self.global_transform.origin.x != getPlayer().global_transform.origin.x or self.global_transform.origin.y != getPlayer().global_transform.origin.y:
    #             interpolation_point = getPlayer().global_transform.origin
    #         else:
    #             interpolation_point = Vector3(
    #                 getPlayer().global_transform.origin.x + (randf() * 2) - 1, 
    #                 getPlayer().global_transform.origin.y + (randf() * 2.5) - .5, 
    #                 getPlayer().global_transform.origin.z)
    #     else:
    #         interpolation_point = Vector3(
    #             original_position.x + (randf() * 1) - .5, 
    #             original_position.y + (randf() * 1) - .5, 
    #             original_position.z)
    #     t = 0

func isActive():
    return is_active

func passiveActivate(delta):
    transformSound.play()
    is_active = false
    visible = false

    getPlayer().ladderGlitch()
