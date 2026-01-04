extends "../GlitchEnemy.gd"


onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")

onready var wingSpriteContainer = get_node("WingSprites")
onready var faceSprite = get_node("Faces/Sprite3D")
onready var fleshSprite = get_node("FleshSprites/Sprite3D")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var hurtSound = get_node("Sounds/HurtSound")

var untouchableSprite = preload("res://assets/glitches/untouchable.png")
var vulnerableSprite = preload("res://assets/glitches/dither3.png")
export var metamorphosis_on_range = false

var idle_timer = 0
var idle_time_limit = 10
var hurt_timer = 0
var hurt_time_limit = 30
var calm_down_counter = 0
var calm_down_count_limit = 1
enum BossState {
    DOCILE,
    HURT,
    IDLE,
    JUMP_SQUAT,
    JUMP,
    LAND,
    CALM_DOWN
    DIE,
}
var boss_state = BossState.HURT # BossState.DOCILE

func _ready():
    walk_direction.x = -1
    behavior_flip_on_land = true

func _process(delta):
    # ._process(delta) implicit
    if not visible: return
    
    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    if am_i_dying:
        return

    if boss_state == BossState.DOCILE:
        idle_timer = 0  
        hurt_timer = 0
    elif boss_state == BossState.HURT:
        hurt_timer += (delta*22)
        if hurt_timer >= hurt_time_limit:
            hurt_timer = 0
            idle_timer = idle_time_limit
            boss_state = BossState.JUMP_SQUAT
            faceSprite.get_material_override().set_shader_param("enable_palette_cycle", false)
            secretAniPlayer.stop()
            secretAniPlayer.play("jumpSquat")
    elif boss_state == BossState.IDLE:
        secretAniPlayer.get_animation("idle").loop = true
        idle_timer += (delta*22)
        if idle_timer >= idle_time_limit:
            idle_timer = 0
            boss_state = BossState.JUMP_SQUAT
            secretAniPlayer.get_animation("idle").loop = false
            secretAniPlayer.queue("jumpSquat")
    elif boss_state == BossState.JUMP_SQUAT:
        # musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
        if not secretAniPlayer.is_playing():
            boss_state = BossState.JUMP
            behavior_jumping = true
            #behavior_walking = true
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
            behavior_walking = false
            # calm_down_counter += 1
            # if calm_down_counter >= calm_down_count_limit:
            #     boss_state = BossState.CALM_DOWN
            #     secretAniPlayer.stop()
            #     secretAniPlayer.queue("calmDown")
            #     secretAniPlayer.queue("idle")
    elif boss_state == BossState.LAND:
        if not secretAniPlayer.is_playing():
            boss_state = BossState.IDLE
            secretAniPlayer.play("idle")
    elif boss_state == BossState.CALM_DOWN:
        secretAniPlayer.get_animation("idle").loop = true
        boss_state = BossState.DOCILE
        fleshSprite.get_material_override().set_shader_param("enable_glitch", false)
        fleshSprite.get_material_override().set_shader_param("enable_palette_cycle", true)
        fleshSprite.get_material_override().set_shader_param("texture_albedo", vulnerableSprite)
        fleshSprite.get_material_override().set_shader_param("target_palette", global.weird_base_palette)
    

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func passiveActivate(_delta, _is_player, _is_local_broom = false):
    if am_i_dying or not visible: return
        
# @override
func ouchies(_broom_origin):
    if boss_state == BossState.DOCILE:
        if calm_down_count_limit == 4:
            faceSprite.get_material_override().set_shader_param("enable_palette_cycle", true)

            fleshSprite.get_material_override().set_shader_param("enable_glitch", true)
            fleshSprite.get_material_override().set_shader_param("enable_palette_cycle", false)
            fleshSprite.get_material_override().set_shader_param("texture_albedo", untouchableSprite)
            fleshSprite.get_material_override().set_shader_param("target_palette", global.grey_palette)
            secretAniPlayer.stop()
            secretAniPlayer.queue("die")
            secretAniPlayer.queue("flyUp")
            secretAniPlayer.queue("hover")
            boss_state = BossState.DIE
            return    
        
        # if not musicPlayer.bossThemePlayer.is_playing():
        #     musicPlayer.stopAll()
        calm_down_counter = 0
        calm_down_count_limit += 1
        if calm_down_count_limit == 3:
            true_terminal_vel = 2.5
            wingSpriteContainer.visible = true
            walk_speed = 3.5
        hurtSound.play()
        secretAniPlayer.stop()
        secretAniPlayer.play("hurt")
        boss_state = BossState.HURT
        faceSprite.get_material_override().set_shader_param("enable_palette_cycle", true)

        fleshSprite.get_material_override().set_shader_param("enable_glitch", true)
        fleshSprite.get_material_override().set_shader_param("enable_palette_cycle", false)
        fleshSprite.get_material_override().set_shader_param("texture_albedo", untouchableSprite)
        fleshSprite.get_material_override().set_shader_param("target_palette", global.grey_palette)
