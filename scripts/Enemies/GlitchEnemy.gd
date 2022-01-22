extends "../GameMover.gd"

var flipTimer = 0
var flipTimeLimit = 4

onready var dieSound = get_node("Sounds/DieSound")
onready var evolveSound = get_node("Sounds/EvolveSound")
onready var startEvolveSound = get_node("Sounds/StartEvolveSound")
onready var myOtherSprite = get_node("Sprite3D2") if has_node("Sprite3D2") else null

var am_i_dying

export var behavior_walking = false
export var behavior_vertical_walking = false
export var behavior_jumping = false
export var behavior_flip_on_land = false
export var behavior_stop_on_land = false
export var behavior_was_thrown = false
export var behavior_thrower = false
export var behavior_evolve = false
export var behavior_fizzle_out_after_evolve = false
export var walk_direction = 1

var glitch_switch_timer = 0
var glitch_switch_time_limit = 99

var evolution_timer = 0
var evolution_time_limit = 15

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    walk_speed = 3
    
    #if behavior_walking:
    #    mySprite.frame_delay = 0.2
    #    mySprite.updateBaseFrame(0, 1)
    if behavior_vertical_walking:
        jump_force = 3
        grav = 0
        terminal_vel = 3
        water_terminal_vel = 3
        true_terminal_vel = 3
    if behavior_jumping and grav == 0:
        grav = 60

    if behavior_evolve:
        mySprite.hframes = mySprite.hframes * 2
        mySprite.vframes = mySprite.vframes * 2
    else:
        glitch_switch_time_limit = rand_range(30.0, 50.0)
        mySprite.frame_delay = rand_range(0.3, 0.5)

func _process(delta):
    if am_i_dying: return

    if behavior_fizzle_out_after_evolve:
        if not mySprite.visible:
            queue_free()
            return

    glitch_switch_timer += (delta*22)
    if glitch_switch_timer > glitch_switch_time_limit:
        mySprite.updateBaseFrame(randi() % 6, randi() % 3)
        glitch_switch_time_limit = rand_range(30.0, 50.0)
        glitch_switch_timer = 0

    if behavior_walking and horizontal_collision:
        horizontal_collision = false
        walk_direction = -walk_direction
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
            
    if behavior_walking and behavior_vertical_walking:
        if on_ground:
            on_ground = false
            walk_direction = 1
            grav = 0
        elif not on_ground and linear_velocity.y == 0:
            walk_direction = -1
            grav = 60

    if behavior_evolve:
        evolution_timer += (delta*22)
        if evolution_timer > evolution_time_limit/3 and not startEvolveSound.is_playing():
            startEvolveSound.play()
        if evolution_timer > evolution_time_limit:
            evolution_timer = 0
            mySprite.hframes = mySprite.hframes / 2
            mySprite.vframes = mySprite.vframes / 2
            behavior_evolve = false
            evolveSound.play()

            if behavior_fizzle_out_after_evolve:
                glitch_switch_timer = 0
                glitch_switch_time_limit = 99999
                mySprite.should_soft_fizzle_out = true

    glitchSetSpritesAndCollision()

func glitchSetSpritesAndCollision():
    if behavior_jumping:
        return
        
    var modAmt = 0.5
    mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
    mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, modAmt)
    if myOtherSprite:
        myOtherSprite.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
        myOtherSprite.global_transform.origin.y = stepify(self.global_transform.origin.y, modAmt)
    smallInteractionArea.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
    smallInteractionArea.global_transform.origin.y = stepify(self.global_transform.origin.y, modAmt)

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500
    pass

# @override
func pressingMoveLeft():
    if am_i_dying: return false
    return walk_direction == -1 and not behavior_vertical_walking and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
    if am_i_dying: return false
    return walk_direction == 1 and not behavior_vertical_walking and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func justPressedJump():
    if am_i_dying: return false
    return behavior_jumping or (behavior_vertical_walking and walk_direction == 1)
# @override
func pressingJump():
    if am_i_dying: return false
    return behavior_jumping or (behavior_vertical_walking and walk_direction == 1)
    
# @override
func isKindOfOnGround():
    if behavior_vertical_walking:
        return walk_direction == 1
    else:
        return .isKindOfOnGround()
    
# @override
func landed():
    .landed()
    if behavior_flip_on_land:
        walk_direction = -walk_direction
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    if behavior_stop_on_land:
        behavior_was_thrown = false
        behavior_jumping = false


# @override
func getHitByBroom():
    if visible:
        visible = false
        dieSound.play()

func isActive():
    return visible and not behavior_evolve

func activate():
    pass

func passiveActivate(delta):
    pass

func stopPassiveActivate():
    pass

func ouchies():
    queue_free()
    pass
