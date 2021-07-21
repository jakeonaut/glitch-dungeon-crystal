extends KinematicBody

onready var mySprite = get_node("Sprite3D") if has_node("Sprite3D") else null
onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null
onready var jumpSound = get_node("Sounds/JumpSound") if has_node("Sounds/JumpSound") else null
onready var doubleJumpSound = get_node("Sounds/DoubleJumpSound") if has_node("Sounds/DoubleJumpSound") else null
onready var wetJumpSound = get_node("Sounds/WetJumpSound") if has_node("Sounds/WetJumpSound") else null

onready var levelTiles = get_tree().get_root().get_node("level/LevelTiles")

onready var smallInteractionArea = get_node("SmallInteractionArea")
onready var collisionShape = get_node("CollisionShape")

var true_terminal_vel = 32
var water_terminal_vel = 5
var hit_water_terminal_vel = 1
var terminal_vel = true_terminal_vel
var is_floating = false
var float_timer = 0
var float_time_limit = 2
var big_float_time_limit = 5
var is_touching_water = false
var was_touching_water = false
var on_ground = true
var was_on_ground = true
var was_just_on_ground_timer = 0
var was_just_on_ground_time_limit = 5
var just_landed = false
var spawn_origin
var last_grounded_y = 0
var falling_y_offset = 16

var linear_velocity = Vector3()
var lv = linear_velocity

export var grav = 80
var g = Vector3(0, -grav, 0)

# TODO(jaketrower): Maybe should remove dir, and only rely on linear_velocity ?
var dir = Vector3(0, 0, 0)
var prev_dir = dir
var up = -g.normalized() # (up is against gravity)
var vv = up.dot(lv) # vertical velocity
var hv = lv - up * vv # horizontal velocity

var walk_speed = 10

# GlitchForm variables
enum GlitchForm {
    NORMAL,
    FLOOR,
    FEATHER,
    INVISIBLE,
    LADDER,
    WALK_THROUGH_WALLS,
}
var glitch_form = GlitchForm.NORMAL
var feather_fall_timer = 0
var feather_fall_time_limit = 30

func isFeatherLike():
    return glitch_form == GlitchForm.FEATHER

# Physics variables
var swimming_walk_speed = 6
var should_magic_jump = false
var jump_force = 20
var weaker_jump_force = 19
var has_just_jumped_timer = 0
var has_just_jumped_time_limit = 200# 3
# TODO(jaketrower): dedupe with is_pressing_horizontal_input
var is_walking = false
var is_pressing_horizontal_input = false
var was_pressing_horizontal_input = false
var facing = Vector3(0, 0, 1) #default to facing "down" toward the player behind the screen
var transitioning = false
var is_falling = false

var horizontal_collision = false


func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    float_timer = float_time_limit
    spawn_origin = global_transform.origin
    last_grounded_y = spawn_origin.y

func _process(delta):
    pass

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500

    if global.pauseGame: return

    is_touching_water = smallInteractionArea.is_touching_water

    processPhysics(delta) #super

    if not on_ground and translation.y < (last_grounded_y - falling_y_offset) and not transitioning:
        respawn()
        is_falling = true
        
func getCamera():
    return get_tree().get_root().get_node("level/Camera")

func respawn():
    hv = Vector3(0, 0, 0)
    linear_velocity = Vector3(0, 0, 0)

    global_transform.origin = spawn_origin
    global_transform.origin.y += 2
    last_grounded_y = global_transform.origin.y 

func processPhysics(delta):
    lv = linear_velocity
    g = Vector3(0, -grav, 0)
    
    if not is_touching_water:
        is_floating = false
    applyGravity(delta)
    
    up = -g.normalized() # (up is against gravity)
    vv = up.dot(lv) # vertical velocity
    hv = lv - up * vv # horizontal velocity
    
    applyTerminalVelocity(delta)
    
    processInputs(delta)
    if is_touching_water:
        hv -= (hv.normalized()*delta*22)
        if abs(hv.length()) < delta*22:
            hv = Vector3()
            dir = Vector3(0.0, 0.0, 0.0)
        
    lv = hv + (up * vv)
    
    linear_velocity = handleCollisionsAndMove(lv, delta)

    postProcessInputs(delta)
    prev_dir = dir
    
    just_landed = false
    if not was_on_ground and on_ground: # I just landed!!
        landed()
        just_landed = true


    if not is_touching_water and was_touching_water:
        float_timer = 0
    if was_on_ground and not on_ground: # I just fell off platform!
        was_just_on_ground_timer = 0
    was_touching_water = is_touching_water

    if was_just_on_ground_timer <= was_just_on_ground_time_limit:
        was_just_on_ground_timer += (delta*22)
        
func applyGravity(delta):
    if global.pauseMoveInput:
        g = Vector3(0, 0, 0)
        vv = 0
    elif is_floating:
        # somehow, a positive (upwards) gravity causes a jump (normally pushing up) to invert (push down) 
        g = Vector3(0, grav/2, 0)
        # on_ground = false
    elif smallInteractionArea.is_touching_water:
        g = Vector3(0, -grav/3, 0)
    elif isFeatherLike():
        g = Vector3(0, -grav/2, 0)
    else:
        g = Vector3(0, -grav, 0)

    if not on_ground or glitch_form != GlitchForm.FLOOR:
        lv += g * delta

func applyTerminalVelocity(delta):
    # feather_fall_timer += (delta*22)
    if smallInteractionArea.is_touching_water or (
        glitch_form == GlitchForm.FEATHER and feather_fall_timer < feather_fall_time_limit):
        terminal_vel = water_terminal_vel
    else:
        terminal_vel = true_terminal_vel

    if vv < -terminal_vel:
        vv = -terminal_vel

    if glitch_form == GlitchForm.FLOOR and on_ground:
        vv = 0

func processInputs(delta):
    processJumpInputs(delta)
    processHorizontalInputs(delta)
    if justPressedDown():
        on_ground = false

    if isWalkingIntoWall() and glitch_form == GlitchForm.LADDER:
        # CLIMB BABY!!!!
        vv = jump_force / 3
    was_pressing_horizontal_input = is_pressing_horizontal_input

func justPressedDown():
    return false
    
func pressingDown():
    return false

func justPressedJump():
    return false

func pressingJump():
    return false

func pressingMoveForward():
    return false

func pressingMoveDown():
    return false

func pressingMoveLeft():
    return false

func pressingMoveRight():
    return false

func processJumpInputs(delta):
    # jump
    if justPressedJump() and not global.pauseMoveInput: 
        # Jump from the water
        if smallInteractionArea.is_touching_water:
            if is_floating:
                vv = -jump_force / 2
            else:
                vv = jump_force / 2

            if smallInteractionArea.is_touching_water and wetJumpSound != null:
                wetJumpSound.play()
            elif jumpSound != null: 
                jumpSound.play()
            on_ground = false
            has_just_jumped_timer = -has_just_jumped_time_limit
            feather_fall_timer = 0
        # Jump from the ground
        else:
            vv = jump_force

            if jumpSound != null: jumpSound.play()
            on_ground = false
            has_just_jumped_timer = 0 
            feather_fall_timer = 0
            should_magic_jump = false

    if is_touching_water:
        if justPressedJump() and not global.pauseMoveInput:
            float_timer = 0
            is_floating = false
        elif pressingJump() and not global.pauseMoveInput:
            float_timer += (delta*22)
            if float_timer >= big_float_time_limit:
                is_floating = true
                float_timer = 0
        elif not pressingJump():
            float_timer += (delta*22)
            if on_ground:
                is_floating = true
                float_timer = 0
            elif float_timer >= big_float_time_limit:
                is_floating = false
                float_timer = 0
    else: 
        is_floating = false
        float_timer = 0
        if pressingJump() and was_touching_water and not global.pauseMoveInput:
            vv = (3*jump_force) / 5

            on_ground = false
            if jumpSound != null: jumpSound.play()
            has_just_jumped_timer = -has_just_jumped_time_limit

const PROJECTION_ORTHOGONAL = 1
func processHorizontalInputs(delta):
    is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight() or pressingMoveForward() or pressingMoveDown()

    # Forward as "seen" by the camera (OpenGL convention)
    var view_forward = -getCamera().get_transform().basis.z
    var view_right = -getCamera().get_transform().basis.x
    # Forward as "seen" by the player
    var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()
    var right = view_right

    if self.glitch_form == GlitchForm.FEATHER:
        if on_ground:
            forward = forward / 8
            right = right / 8
        else:
            forward = forward / 12
            right = right / 12
    
    var horizontal_input = false
    # I'm on the ground or just fell off a platform...
    var kind_of_on_ground = on_ground or (
        was_just_on_ground_timer <= was_just_on_ground_time_limit and vv < 0)
    has_just_jumped_timer += (delta*22)
        
    if kind_of_on_ground or has_just_jumped_timer < has_just_jumped_time_limit or \
        is_pressing_horizontal_input or self.isFeatherLike() or self.glitch_form == GlitchForm.LADDER:
        
        horizontal_input = true
        if self.glitch_form != GlitchForm.FEATHER:
            dir = Vector3(0.0, 0.0, 0.0)

        if pressingMoveForward():
            if not global.pauseMoveInput: 
                dir += forward
            # only change sprite facing if i'm idle of if I just pressed this
            if not is_walking or Input.is_action_just_pressed("ui_up") or Input.is_action_just_released("ui_down") or \
                (not pressingMoveLeft() and not pressingMoveRight()):
                mySprite.faceUp()
        elif pressingMoveDown():
            if not global.pauseMoveInput: 
                dir -= forward
            # only change sprite facing if i'm idle or if I just pressed down, or was holding down and released up
            if not is_walking or Input.is_action_just_pressed("ui_down") or Input.is_action_just_released("ui_up") or \
                (not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right")):
                mySprite.faceDown()
                
        if pressingMoveLeft():
            if not global.pauseMoveInput: 
                dir += right
            # only change sprite facing if i'm idle of if I just pressed this
            if not is_walking or Input.is_action_just_pressed("ui_left") or Input.is_action_just_released("ui_right") or \
                (not pressingMoveForward() and not pressingMoveDown()):
                mySprite.faceLeft()
        elif pressingMoveRight():
            if not global.pauseMoveInput: 
                dir -= right
            # only change sprite facing if i'm idle or if I just pressed right, or was holding right and released left
            if not is_walking or Input.is_action_just_pressed("ui_right") or Input.is_action_just_released("ui_left") or \
                (not pressingMoveForward() and not pressingMoveDown()):
                mySprite.faceRight()

    if self.isFeatherLike():
        if self.isFeatherLike() and dir.length() > 1:
            dir = dir.normalized()
        if on_ground and not self.is_pressing_horizontal_input:
            dir = dir * 0.9
            if dir.length() < 0.1:
                dir = Vector3(0, 0, 0)

    var curr_walk_speed = walk_speed
    if smallInteractionArea.is_touching_water:
        curr_walk_speed = swimming_walk_speed

    # update x and z
    if not smallInteractionArea.is_touching_water or horizontal_input:
        hv = dir * curr_walk_speed
    elif on_ground:
        hv -= (hv.normalized()*delta*30)
        if abs(hv.length()) < delta*22:
            hv = Vector3()
            dir = Vector3(0.0, 0.0, 0.0)

    if global.pauseMoveInput:
        hv = Vector3(0, 0, 0)
        is_walking = false
    else:
        updateFacing(dir)
        
func handleCollisionsAndMove(lv, delta):
    if delta == 0:
        return lv
        
    var DNUM = 1.15
    # move_and_slide automatically includes "delta"
    # return move_and_slide(lv, -g.normalized(), true, 4, 0.785398, false)
    lv.x *= delta*DNUM
    lv.y *= delta*DNUM
    
    var lb = -get_node("CollisionShape").shape.radius
    var tb = get_node("CollisionShape").shape.height/2
    var rb = -lb
    var bb = -tb
    var left_tile_x = int(floor(global_transform.origin.x + lb + lv.x - 0.1))
    var right_tile_x = int(ceil(global_transform.origin.x + rb + lv.x + 0.1))
    var top_tile_y = int(ceil(global_transform.origin.y + tb + lv.y + 0.1))
    var bottom_tile_y = int(floor(global_transform.origin.y + bb + lv.y - 0.1))
    
    was_on_ground = on_ground
    on_ground = false

    lv = handleHorizontalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.3)
    global_transform.origin.x += lv.x
    lv = handleVerticalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.3)
    global_transform.origin.y += lv.y
    
    if on_ground:
        feather_fall_timer = 0
        if is_touching_water:
            is_floating = true
    
    lv.x /= delta*DNUM
    lv.y /= delta*DNUM
    return lv

func isTileTypeSolid(tile_type):
    return tile_type == 1
    
func isTileTypeFallthroughSolid(tile_type):
    return tile_type == 2

func isTileTypeNotSolid(tile_type):
    return tile_type == -1
    
func handleHorizontalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, q):
    self.horizontal_collision = false
    for i in range(bottom_tile_y, top_tile_y):
        for j in range(left_tile_x, right_tile_x):
            var coords = levelTiles.world_to_map(Vector3(j, i, global_transform.origin.z))
            var tile_type = levelTiles.get_cell_item(coords.x, coords.y, coords.z)
            if tile_type == GridMap.INVALID_CELL_ITEM or not isTileTypeSolid(tile_type):
                continue

            var x = global_transform.origin.x
            var y = global_transform.origin.y
            var lb = -get_node("CollisionShape").shape.radius
            var tb = get_node("CollisionShape").shape.height/2
            var rb = -lb
            var bb = -tb
            var TILE_WIDTH = levelTiles.cell_size.x
            var TILE_HEIGHT = levelTiles.cell_size.y
            var tile_pos = levelTiles.map_to_world(coords.x, coords.y, coords.z)
            var tile_x = tile_pos.x - TILE_WIDTH/2
            var tile_y = tile_pos.y - TILE_HEIGHT/2

            # Check for left collisions
            if lv.x < 0 and isRectColliding(
                    tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                    x + lb + lv.x - 0.1, y + tb - q, x + lb, y + bb + q):
                # TODO(jaketrower): implement slope maybe?
                lv.x = 0
                # TODO(jaketrower): Remove dir, rely only on lv?
                dir = Vector3(0.0, 0.0, 0.0)
                self.horizontal_collision = true
                x = tile_x + TILE_WIDTH - lb
                global_transform.origin.x = x

            # Check for right collisions
            if lv.x > 0 and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y, 
                x + rb, y + tb - q, x + rb + lv.x + 0.1, y + bb + q
            ):
                # TODO(jaketrower): implement slope maybe?
                lv.x = 0
                # TODO(jaketrower): Remove dir, rely only on lv?
                dir = Vector3(0.0, 0.0, 0.0)
                self.horizontal_collision = true
                x = tile_x - rb
                global_transform.origin.x = x
    return lv
    
func isRectColliding(o_lb, o_tb, o_rb, o_bb, lb, tb, rb, bb):
    if lb <= o_rb and rb >= o_lb and tb >= o_bb and bb <= o_tb:
        return true
    return false
    
func handleVerticalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, q):
    if lv.y != 0:
        print(str(top_tile_y) + ", " + str(bottom_tile_y))
    for i in range(bottom_tile_y, top_tile_y):
        for j in range(left_tile_x, right_tile_x):
            var coords = levelTiles.world_to_map(Vector3(j, i, global_transform.origin.z))
            var tile_type = levelTiles.get_cell_item(coords.x, coords.y, coords.z)
            if tile_type == GridMap.INVALID_CELL_ITEM or isTileTypeNotSolid(tile_type):
                continue

            var x = global_transform.origin.x
            var y = global_transform.origin.y
            var lb = -get_node("CollisionShape").shape.radius
            var tb = get_node("CollisionShape").shape.height/2
            var rb = -lb
            var bb = -tb
            var TILE_WIDTH = levelTiles.cell_size.x
            var TILE_HEIGHT = levelTiles.cell_size.y
            var tile_pos = levelTiles.map_to_world(coords.x, coords.y, coords.z)
            var tile_x = tile_pos.x - TILE_WIDTH/2
            var tile_y = tile_pos.y - TILE_HEIGHT/2
                
            # Check for top collisions
            if lv.y > 0 and not isTileTypeFallthroughSolid(tile_type) and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + q, y + tb + lv.y + 0.1, x + rb - q, y + tb
            ):
                lv.y /= 2
                y = tile_y - tb
                global_transform.origin.y = y

            # Check for bottom collisions
            if lv.y < 0 and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + q, y + bb, x + rb - q, y + bb + lv.y - 0.1
            ):
                if isTileTypeFallthroughSolid(tile_type) and (tile_y > y + bb or pressingDown()):
                    continue
                lv.y = 0
                on_ground = true
                y = tile_y + TILE_HEIGHT - bb
                global_transform.origin.y = y
    return lv

func postProcessInputs(delta):
    pass
    
func landed():
    last_grounded_y = global_transform.origin.y 
    if landSound: landSound.play()

func isWalkingIntoWall():
    return linear_velocity.x < 2 and linear_velocity.x > -2 \
            and linear_velocity.z < 2 and linear_velocity.z > -2 \
            and is_pressing_horizontal_input and was_pressing_horizontal_input

func updateFacing(dir):
    if dir.x != 0 or dir.y != 0 or dir.z != 0:
        facing = dir
        is_walking = true
    else:
        is_walking = false

