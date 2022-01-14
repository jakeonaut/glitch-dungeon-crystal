extends "GlitchEnemy.gd"

enum SlimeState {
    IDLE,
    WALK
}
var slime_state = SlimeState.WALK

var slime_state_timer = 0
export var slime_walk_time_limit = 10
var slime_idle_time_limit = 10

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    pass

func _process(delta):
    # ._process(delta) implicit

    slime_state_timer += (delta*22)
    if slime_state == SlimeState.WALK:
        mySprite.hframes = 5
        mySprite.vframes = 5
        mySprite.transform.origin.y = -0.15
        if myOtherSprite.flip_h:
            myOtherSprite.transform.origin.x = -0.15
        else:
            myOtherSprite.transform.origin.x = 0.15
        myOtherSprite.transform.origin.y = -0.30
        if slime_state_timer >= slime_walk_time_limit:
            slime_state_timer = 0
            slime_state = SlimeState.IDLE 
            scoochSound1.play()
    elif slime_state == SlimeState.IDLE:
        mySprite.hframes = 6
        mySprite.vframes = 4
        mySprite.transform.origin.y = 0
        myOtherSprite.transform.origin.x = 0
        myOtherSprite.transform.origin.y = 0
        if slime_state_timer >= slime_idle_time_limit:
            slime_state_timer = 0
            slime_state = SlimeState.WALK
            scoochSound2.play()
        

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func pressingMoveLeft():
    return walk_direction == -1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
    return walk_direction == 1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))
