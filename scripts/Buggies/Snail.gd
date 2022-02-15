extends "res://scripts/Enemies/GlitchEnemy.gd"

enum SlimeState {
    IDLE,
    WALK
}
var slime_state = SlimeState.WALK

var slime_state_timer = 0
export var slime_walk_time_limit = 10
var slime_idle_time_limit = 10
export var is_wall_snail = false

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")
var heartSpriteOriginX = 0
var heartSpriteOriginY = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())
    
    should_only_do_middle_sensor = true
    if is_wall_snail:
        behavior_vertical_walking = true
        should_collide_horizontally = false
    else:
        should_collide_ceil = false

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier

    if am_i_dying:
        return

    slime_state_timer += (delta*22)
    if slime_state == SlimeState.WALK:
        myOtherSprite.updateBaseFrame(4, 3)
        if slime_state_timer >= slime_walk_time_limit:
            slime_state_timer = 0
            slime_state = SlimeState.IDLE 
            scoochSound1.play()
    elif slime_state == SlimeState.IDLE:
        myOtherSprite.updateBaseFrame(5, 3)
        if slime_state_timer >= slime_idle_time_limit:
            slime_state_timer = 0
            slime_state = SlimeState.WALK
            scoochSound2.play()
        

# @override
func glitchSetSpritesAndCollision():
    pass
    
# @override
func pressingMoveLeft():
    return .pressingMoveLeft() and slime_state == SlimeState.WALK

# @override
func pressingMoveRight():
    return .pressingMoveRight() and slime_state == SlimeState.WALK

# @override
func justPressedJump():
    return .justPressedJump() and slime_state == SlimeState.WALK

# @override
func pressingJump():
    return .pressingJump() and slime_state == SlimeState.WALK

# @override
func passiveActivate(_delta):
    pass

func processDeath():
    if not myOtherSprite.visible:
        queue_free()
        
# @override
func ouchies(_broom_origin):
    pass
