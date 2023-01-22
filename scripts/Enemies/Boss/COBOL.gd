extends "../GlitchEnemy.gd"


onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
export var metamorphosis_on_range = false

var idle_timer = 0
var idle_time_limit = 10
enum BossState {
    IDLE,
    JUMP_SQUAT,
    JUMP,
    LAND
}
var boss_state = BossState.IDLE

func _process(delta):
    # ._process(delta) implicit
    if not visible: return
    
    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    if am_i_dying:
        return
        
    if boss_state == BossState.IDLE:
        idle_timer += (delta*22)
        if idle_timer >= idle_time_limit:
            idle_timer = 0
            boss_state = BossState.JUMP_SQUAT
            secretAniPlayer.get_animation("idle").loop = false
            secretAniPlayer.queue("jumpSquat")
    elif boss_state == BossState.JUMP_SQUAT:
        if not secretAniPlayer.is_playing():
            boss_state = BossState.JUMP
            behavior_jumping = true
            secretAniPlayer.stop()
            secretAniPlayer.queue("jumpStart")
            secretAniPlayer.queue("jumpFall")
    elif boss_state == BossState.JUMP:
        if linear_velocity.y <= 0:
            behavior_jumping = false
        if on_ground:
            boss_state = BossState.LAND
            secretAniPlayer.stop()
            secretAniPlayer.play("land")
    elif boss_state == BossState.LAND:
        if not secretAniPlayer.is_playing():
            secretAniPlayer.get_animation("idle").loop = true
            secretAniPlayer.play("idle")
            boss_state = BossState.IDLE
    

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func passiveActivate(_delta):
    if am_i_dying or not visible: return
        
# @override
func ouchies(broom_origin):
    pass
