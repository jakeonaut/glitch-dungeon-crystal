extends KinematicBody

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")

export var my_glitch_form = 2

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
    delta = delta * global.time_dilation_multiplier
    
    if is_active and not shouldIBeActive():
        is_active = false
        mySprite.visible = false
        t = 0

    if mySprite.visible and not is_active:
        mySprite.global_transform.origin = previous_point.linear_interpolate(interpolation_point, t)
        t += (delta*2)
        if t >= 1:
            mySprite.visible = false
            t = 0

    if not mySprite.visible and shouldIBeActive():
        mySprite.visible = true
        mySprite.global_transform.origin = original_position
        is_active = true
        
func shouldIBeActive():
    return getPlayer().glitch_form != my_glitch_form and (
        not global.memory.has("spellbookPage") or \
        global.memory["spellbookPage"].size() == 0 or \
        global.memory["spellbookPage"][0] != my_glitch_form) 

func isActive():
    return is_active

func passiveActivate(_delta):
    if global.memory.has("spellbookPage"):
        collectSound.play()
    is_active = false

    getPlayer().applyObeliskGlitch(my_glitch_form)
