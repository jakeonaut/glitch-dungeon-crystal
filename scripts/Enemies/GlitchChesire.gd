extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

enum CatState {
    HIDDEN,
    IDLE,
    FLICKER_ON,
    PREPARE_LUNGE,
    WALK,
    LAND,
    FREEZE,
    UNFREEZE,
    JUMP,
    TELEPORT_IN,
    TELEPORT_OUT,
    TELEPORT_BACK,
    ASLEEP,
}
var cat_state = CatState.HIDDEN
var cat_state_timer = 0
var cat_state_prepare_lunge_time_limit = 10
export var can_freeze = false

var proper_jump_force = 10
export var lunge_jump_force = 7
var proper_walk_speed  = 2
export var lunge_walk_speed = 5

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

onready var secretAniPlayer = get_node("SecretAnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.visible = false
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    playerActivationAreaCollisionShape.shape = playerActivationAreaCollisionShape.shape.duplicate() # make unique

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    self.glitch_form = global.GlitchForm.FLOOR # TODO(jaketrower): ???
    
    if "jump" in secretAniPlayer.assigned_animation and vv <= 0:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("fall")
    
    if cat_state == CatState.FLICKER_ON and not secretAniPlayer.is_playing():
        secretAniPlayer.stop()
        cat_state = CatState.WALK
        behavior_walking = true
        walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
        secretAniPlayer.play("walk")
    elif cat_state == CatState.IDLE:
        walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
        if am_i_in_range_of_player:
            cat_state = CatState.WALK
            behavior_walking = true
            secretAniPlayer.play("walk")
    elif cat_state == CatState.TELEPORT_IN:
        if not secretAniPlayer.is_playing():
            cat_state = CatState.IDLE
    elif cat_state == CatState.TELEPORT_OUT:
        if not secretAniPlayer.is_playing():
            teleport()
    elif cat_state == CatState.TELEPORT_BACK:
        if not secretAniPlayer.is_playing():
            respawn()
    elif cat_state == CatState.WALK:
        walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
        if abs(getPlayer().global_transform.origin.x - global_transform.origin.x) < 1:
            playerActivationAreaPassiveActivate2()
    elif cat_state == CatState.PREPARE_LUNGE:
        walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
        cat_state_timer += (delta*22)
        if cat_state_timer >= cat_state_prepare_lunge_time_limit:
            cat_state_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.queue("jumpStart")
            secretAniPlayer.queue("jump")
            cat_state = CatState.JUMP
            behavior_walking = true
            behavior_jumping = true
            
            walk_speed = lunge_walk_speed
            floor_glitch_walk_speed = lunge_walk_speed
            invisible_glitch_walk_speed = lunge_walk_speed
            jump_force = lunge_jump_force
            invisible_jump_force = lunge_jump_force
    elif cat_state == CatState.LAND:
        cat_state_timer += (delta*22)
        if cat_state_timer >= cat_state_prepare_lunge_time_limit:
            cat_state_timer = 0
            cat_state = CatState.WALK
            behavior_walking = true
            
            walk_speed = proper_walk_speed
            floor_glitch_walk_speed = proper_walk_speed
            invisible_glitch_walk_speed = proper_walk_speed
            jump_force = proper_jump_force
            invisible_jump_force = proper_jump_force
            
    if cat_state != CatState.FLICKER_ON and cat_state != CatState.HIDDEN and \
       cat_state != CatState.TELEPORT_IN and cat_state != CatState.TELEPORT_OUT and \
       cat_state != CatState.TELEPORT_BACK and cat_state != CatState.ASLEEP:
        if can_freeze and cat_state != CatState.FREEZE and getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
            cat_state = CatState.FREEZE
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("stonify")
            behavior_jumping = false
            behavior_walking = false
            grav = 0
            lv = Vector3(0, 0, 0)
            linear_velocity = Vector3(0, 0, 0)
        if not am_i_in_range_of_player and on_ground:
            cat_state = CatState.TELEPORT_BACK
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("teleportOut")
            behavior_jumping = false
            behavior_walking = false
            grav = 0
            lv = Vector3(0, 0, 0)
            linear_velocity = Vector3(0, 0, 0)


    if am_i_dying:
        return
        
func doHorizontalWalkingBehavior():
    if behavior_walking and horizontal_collision and on_ground:
        behavior_jumping = true
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.queue("jumpStart")
        secretAniPlayer.queue("jump")
        
func respawn():
    global_transform.origin = spawn_origin
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.queue("fallAsleep")
    secretAniPlayer.queue("sleepIdle")
    behavior_walking = false
    behavior_jumping = false
    
    grav = 30
    on_ground = true
    walk_speed = proper_walk_speed
    floor_glitch_walk_speed = proper_walk_speed
    invisible_glitch_walk_speed = proper_walk_speed
    jump_force = proper_jump_force
    invisible_jump_force = proper_jump_force

    walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
    myOtherSprite.flip_h = walk_direction == -1
    cat_state = CatState.ASLEEP
        
func teleport():
    global_transform.origin = getPlayer().global_transform.origin
    var teleport_distance = 4
    # appear in front of player
    if getPlayer().facing.x == -1:
        global_transform.origin.x -= teleport_distance
    else:
        global_transform.origin.x += teleport_distance
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("teleportIn")
    behavior_walking = false
    behavior_jumping = false
    
    grav = 30
    on_ground = true
    walk_speed = proper_walk_speed
    floor_glitch_walk_speed = proper_walk_speed
    invisible_glitch_walk_speed = proper_walk_speed
    jump_force = proper_jump_force
    invisible_jump_force = proper_jump_force

    walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
    myOtherSprite.flip_h = walk_direction == -1
    cat_state = CatState.TELEPORT_IN
        
# @override
func landed():
    .landed()
    if cat_state != CatState.HIDDEN and cat_state != CatState.FLICKER_ON:
        behavior_jumping = false
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.queue("land")
        secretAniPlayer.queue("walk")
        
        if cat_state == CatState.JUMP:
            cat_state = CatState.LAND
            cat_state_timer = 0
            behavior_walking = false

    
# @override
func playerActivationAreaPassiveActivate():
    if cat_state == CatState.HIDDEN:
        cat_state = CatState.FLICKER_ON
        secretAniPlayer.play("flickerOn")
        walk_direction = 1 if getPlayer().global_transform.origin.x > global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
    else:
        .playerActivationAreaPassiveActivate()

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate2():
    if cat_state == CatState.WALK or cat_state == CatState.LAND or cat_state == CatState.ASLEEP:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        if cat_state == CatState.WALK or cat_state == CatState.ASLEEP:
            secretAniPlayer.queue("meow")
        cat_state = CatState.PREPARE_LUNGE
        behavior_walking = false
        cat_state_timer = 0

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func processPhysics(delta):
    var was_i_in_range_of_player = am_i_in_range_of_player
    am_i_in_range_of_player = true
    # call GameMover.gd super method
    .processPhysics(delta)
    am_i_in_range_of_player = was_i_in_range_of_player