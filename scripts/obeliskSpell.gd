extends KinematicBody

onready var transformSound = get_node("TransformSound")
onready var mySprite = get_node("Sprite3D")

enum GlitchForm {
    NORMAL,
    FLOOR,
    FEATHER,
    INVISIBLE,
    LADDER,
    WALK_THROUGH_WALLS,
}
export var my_glitch_form = GlitchForm.FEATHER

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
    original_position = mySprite.global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

func _process(delta):
    if is_active and getPlayer().glitch_form == my_glitch_form:
        is_active = false
        mySprite.visible = false
        t = 0

    if mySprite.visible and not is_active:
        mySprite.global_transform.origin = previous_point.linear_interpolate(interpolation_point, t)
        t += (delta*2)
        if t >= 1:
            mySprite.visible = false
            t = 0

    if not mySprite.visible and getPlayer().glitch_form != my_glitch_form:
        mySprite.visible = true
        mySprite.global_transform.origin = original_position
        is_active = true

func isActive():
    return is_active

func passiveActivate(_delta):
    transformSound.play()
    is_active = false

    getPlayer().applyGlitch(my_glitch_form)
