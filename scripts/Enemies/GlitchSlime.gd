extends "GlitchEnemy.gd"

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")
onready var heartSprite = get_node("HeartSprite")
onready var heartSound = get_node("Sounds/HeartSound")
var heartSpriteOriginX = 0
var heartSpriteOriginY = 0

onready var dieAniPlayer = get_node("DieAnimationPlayer")
export var metamorphosis_on_range = false

export var flip_initial_direction = false

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    
    heartSprite.set_material_override(heartSprite.get_material_override().duplicate())
    myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())

    behavior_intermittent_walking = true
    
    should_collide_ceil = false

    if flip_initial_direction:
        walk_direction.x = -walk_direction.x
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    is_turn_based = true

func _process(delta):
    # ._process(delta) implicit
    if not visible: return
    
    delta = delta * global.time_dilation_multiplier
    dieAniPlayer.playback_speed = global.time_dilation_multiplier

    if am_i_dying:
        return

    if am_i_in_range_of_player and metamorphosis_on_range:
        ouchies(level.player.global_transform.origin)

    if slime_state == SlimeState.WALK:
        mySprite.hframes = 5
        mySprite.vframes = 5
        mySprite.transform.origin.y = -0.15
        if myOtherSprite.flip_h:
            myOtherSprite.transform.origin.x = -0.15
        else:
            myOtherSprite.transform.origin.x = 0.15
        myOtherSprite.transform.origin.y = -0.30
        if slime_state_timer == 0:
            scoochSound2.play()
    elif slime_state == SlimeState.IDLE:
        mySprite.hframes = 6
        mySprite.vframes = 4
        mySprite.transform.origin.y = 0
        myOtherSprite.transform.origin.x = 0
        myOtherSprite.transform.origin.y = 0
        if slime_state_timer == 0:
            scoochSound1.play()
        

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func pressingMoveLeft():
    if am_i_dying or not visible: return false
    return walk_direction.x == -1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
    if am_i_dying or not visible: return false
    return walk_direction.x == 1 and ((behavior_walking and slime_state == SlimeState.WALK) or (behavior_was_thrown and not on_ground))

# @override
func passiveActivate(_delta, _is_player):
    if am_i_dying or not visible: return
        
    # var aniPlayer = get_node("HeartSprite/AnimationPlayer")
    # if level.player.glitch_form == global.GlitchForm.INVISIBLE and not aniPlayer.is_playing():
    #     heartSound.play()
    #     aniPlayer.stop()
    #     aniPlayer.queue("heartWiggle")
    #     aniPlayer.queue("noHeart")

func processDeath():
    if not visible: return
    if not myOtherSprite.visible:
        queue_free()

func unenemize():
    if smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.remove_from_group("enemies")
    if smallInteractionArea.is_in_group("weak_enemies"):
        smallInteractionArea.remove_from_group("weak_enemies")
        
# @override
func ouchies(broom_origin):
    .ouchies_base()
    if am_i_dying or not visible: return
        
    am_i_dying = true
    

    mySprite.hframes = 10
    mySprite.vframes = 6
    mySprite.restart()
    mySprite.frame_delay = 0.1
    mySprite.max_frames = 4
    mySprite.should_soft_fizzle_out = true
    
    var new_material = mySprite.get_material_override().duplicate()
    new_material.set_shader_param("texture_albedo", altGlitchEnemySheet)
    mySprite.set_material_override(new_material)
    myOtherSprite.set_script(null)
    
    dieAniPlayer.stop()
    dieAniPlayer.clear_queue()
    if metamorphosis_on_range:
        dieAniPlayer.play("flutterAway", -1, rand_range(0.5, 1.0))
    else:
        dieAniPlayer.queue("metamorphosis")
        dieAniPlayer.queue("flutterAway")
    
    if broom_origin.x < self.global_transform.origin.x:
        pass
