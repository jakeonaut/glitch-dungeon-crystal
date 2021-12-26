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
        player = get_tree().get_root().get_node("Game/Viewport/level").player
    return player

func _ready():
    set_process(true)
    original_position = global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

func _process(delta):
    if is_active and getPlayer().glitch_form == getPlayer().GlitchForm.FLOOR:
        is_active = false
        visible = false
        t = 0
        
    if visible and not is_active:
        global_transform.origin = previous_point.linear_interpolate(interpolation_point, t)
        t += (delta*2)
        if t >= 1:
            visible = false
            t = 0

    if not visible and getPlayer().glitch_form != getPlayer().GlitchForm.FLOOR:
        visible = true
        global_transform.origin = original_position
        is_active = true

func isActive():
    return is_active

func passiveActivate(_delta):
    transformSound.play()
    is_active = false

    getPlayer().floorGlitch()
