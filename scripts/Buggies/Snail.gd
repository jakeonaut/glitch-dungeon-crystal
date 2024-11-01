extends "res://scripts/Enemies/GlitchEnemy.gd"

export var is_wall_snail = false
var has_reached_top_of_wall = false

onready var scoochSound1 = get_node("Sounds/ScoochSound1")
onready var scoochSound2 = get_node("Sounds/ScoochSound2")
onready var catchSound = get_node("CatchSound")
var heartSpriteOriginX = 0
var heartSpriteOriginY = 0

var can_i_spawn_crystal = true
func _ready():
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self):
        can_i_spawn_crystal = false

    # ._ready() implicit
    myOtherSprite.set_material_override(myOtherSprite.get_material_override().duplicate())
    
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

    if didja_get_me:
        opacity = opacity + (0.0 - opacity) * (delta * 5)
        myOtherSprite.material_override.set_shader_param("opacity", opacity)
        
        if stepify(opacity, 0.1) == 0:
            queue_free()
        slime_state = SlimeState.WALK
        slime_state_timer = 0

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

var is_active = true
func isActive(_debug=false):
    return visible and is_active

func passiveActivate(_delta, _is_player):
    pass

var didja_get_me = false
var opacity = 1.0
onready var smackSound = get_node("Sounds/SmackSound")
func getSmacked(_broom_origin = Vector3(0, 0, 0), _silently = false):
    if is_smacked:
        return

    if catchSound: catchSound.play()
    if smackSound: smackSound.play()
    myOtherSprite.material_override.set_shader_param("time_influence", time_influence)
    myOtherSprite.material_override.set_shader_param("y_div", y_div)
    myOtherSprite.material_override.set_shader_param("normal_offset", normal_offset)
    
    smack_timer = 0
    is_smacked = true
    didja_get_me = true

    if is_static_in_level and can_i_spawn_crystal:
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        miniCubeCrystal.is_static_in_level = false
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = self.global_transform.origin
        miniCubeCrystal.passiveActivate(0, false)

        global.setStaticLevelZoneLevelVar(level, self, global_transform.origin)

func unsmack():
    is_smacked = false
    myOtherSprite.material_override.set_shader_param("time_influence", 3)
    myOtherSprite.material_override.set_shader_param("y_div", 2.3)
    myOtherSprite.material_override.set_shader_param("normal_offset", .02)
