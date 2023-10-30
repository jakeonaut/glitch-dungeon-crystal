extends "res://scripts/Enemies/GlitchEnemy.gd"

export var is_wall_snail = false
var has_reached_top_of_wall = false

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")
onready var catchSound = get_node("CatchSound")
var heartSpriteOriginX = 0
var heartSpriteOriginY = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
        queue_free()

    # ._ready() implicit
<<<<<<< HEAD
    # TODO(jaketrower): testing performance # myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())
=======
    myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())
>>>>>>> 7240358 (working on suburban gothic)
    
    should_only_do_middle_sensor = true
    if is_wall_snail:
        should_collide_horizontally = false
        jump_force = 1
        grav = 0
        terminal_vel = 1
        water_terminal_vel = 1
        true_terminal_vel = 1
        on_ground = false
    else:
        should_collide_ceil = false
        
func addJumpSmokeCloud(_flip_flip_h = false):
    pass
    
# @override
func doVerticalWalkingBehavior():
    if behavior_walking and is_wall_snail:
        if on_ground:
            on_ground = false
            walk_direction.y = 1
            grav = 5
            slime_state_timer = 0
            slime_state = SlimeState.WALK
            scoochSound2.play()
            if myOtherSprite:
                myOtherSprite.flip_v = false
        elif not on_ground and linear_velocity.y == 0:
            has_reached_top_of_wall = slime_state == SlimeState.WALK and slime_state_timer > slime_walk_time_limit/2
            if has_reached_top_of_wall:
                walk_direction.y = -1
                grav = 60
                if myOtherSprite:
                    myOtherSprite.flip_v = true
                has_reached_top_of_wall = false

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier

    if am_i_dying:
        return

    slime_state_timer += (delta*22)
    if slime_state == SlimeState.WALK:
        true_terminal_vel = 1
        if is_wall_snail:
            myOtherSprite.updateBaseFrame(6, 3)
        else:
            myOtherSprite.updateBaseFrame(4, 3)
        if slime_state_timer >= slime_walk_time_limit:
            slime_state_timer = 0
            slime_state = SlimeState.IDLE 
            scoochSound1.play()
    elif slime_state == SlimeState.IDLE:
        true_terminal_vel = 0
        if is_wall_snail:
            myOtherSprite.updateBaseFrame(7, 3)
        else:
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

func processDeath():
    if not myOtherSprite.visible and not catchSound.is_playing():
        queue_free()
        
# @override
func ouchies(_broom_origin):
    pass

func isActive():
    return false # true

func passiveActivate(_delta, _is_player):
    if not am_i_dying:
        myOtherSprite.visible = false
        catchSound.play()
        if global.memory.has("snails"):
            global.memory["snails"] += 1
        else:
            global.memory["snails"] = 1
        am_i_dying = true
        global.collectable_key_recently_got = "snails"
        global.collectable_key_recently_got_timer = 0
        
        if is_static_in_level:
            global.setStaticLevelZoneLevelVar(level, self.name, true)
    
