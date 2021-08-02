extends KinematicBody

onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null
onready var jumpSound = get_node("Sounds/JumpSound") if has_node("Sounds/JumpSound") else null
onready var doubleJumpSound = get_node("Sounds/DoubleJumpSound") if has_node("Sounds/DoubleJumpSound") else null
onready var wetJumpSound = get_node("Sounds/WetJumpSound") if has_node("Sounds/WetJumpSound") else null

onready var levelTiles = get_tree().get_root().get_node("level/LevelTiles")

onready var smallInteractionArea = get_node("SmallInteractionArea")
onready var collisionShape = get_node("CollisionShape")
onready var aniPlayer = get_node("AnimationPlayer") if has_node("AnimationPlayer") else null
onready var mySprite = get_node("Sprite3D")

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
var truly_on_ground = false
var half_on_ground = false
var should_teeter_turn_around = false
var jumped_from_true_ground = false
var was_just_on_ground_timer = 0
var was_just_on_ground_time_limit = 5
var just_landed = false
var spawn_origin
var last_grounded_y = 0
var falling_y_offset = 16

var linear_velocity = Vector3()
var lv = linear_velocity

export var grav = 60
var g = Vector3(0, -grav, 0) if grav != 0 else Vector3(0, -1, 0)

# TODO(jaketrower): Maybe should remove dir, and only rely on linear_velocity ?
var dir = Vector3(0, 0, 0)
var prev_dir = dir
var up = -g.normalized() # (up is against gravity)
var vv = up.dot(lv) # vertical velocity
var hv = lv - up * vv # horizontal velocity

var walk_speed = 8
var DNUMHORZ = 65

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
var floor_glitch_walk_speed = 3
var invisible_glitch_walk_speed = 6
var swimming_walk_speed = 6
var should_magic_jump = false
var jump_force = 16
var invisible_jump_force = 14
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
       
func isActive():
    return visible

func tryDieToEnemy():
    pass    
    
func getHitByBroom():
    pass
    
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
    g = Vector3(0, -grav, 0) if grav != 0 else Vector3(0, -1, 0)
    
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
    if aniPlayer != null and aniPlayer.assigned_animation == "land" and not aniPlayer.is_playing():
        aniPlayer.play("stand")


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
        g = Vector3(0, -grav/1.5, 0)
    else:
        g = Vector3(0, -grav, 0)

    if not on_ground or glitch_form != GlitchForm.FLOOR:
        lv += g * delta
        if lv.y < 0 and not on_ground and aniPlayer and (aniPlayer.current_animation != "fall" and aniPlayer.current_animation != "fallStart"):
            aniPlayer.clear_queue()
            aniPlayer.stop()
            aniPlayer.queue("fallStart")
            aniPlayer.queue("fall")

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
        vv = jump_force / 2.5
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
        else: # TODO(jaketrower): Do a double jump only if feather
            jumped_from_true_ground = truly_on_ground
            vv = jump_force
            if self.isFeatherLike():
                vv = (jump_force*6)
            elif glitch_form == GlitchForm.INVISIBLE:
                vv = invisible_jump_force

            if jumpSound != null: jumpSound.play()
            on_ground = false
            has_just_jumped_timer = 0 
            feather_fall_timer = 0
            should_magic_jump = false
            if aniPlayer:
                aniPlayer.clear_queue()
                aniPlayer.play("jumpSquat")
                aniPlayer.queue("jump")

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
            vv = (jump_force) / 6

            on_ground = false
            if jumpSound != null: jumpSound.play()
            has_just_jumped_timer = -has_just_jumped_time_limit

    if self.isFeatherLike() and (pressingJump() or vv > jump_force) and not justPressedJump():
        vv = (4*jump_force) / 5
        

const PROJECTION_ORTHOGONAL = 1
func processHorizontalInputs(delta):
    is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight() or pressingMoveForward() or pressingMoveDown()

    # Forward as "seen" by the camera (OpenGL convention)
    var view_forward = -getCamera().get_transform().basis.z
    var view_right = -getCamera().get_transform().basis.x
    # Forward as "seen" by the player
    var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()
    var right = view_right

    if glitch_form == GlitchForm.FEATHER and not (aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"):
        if on_ground:
            forward = forward / 8
            right = right / 8
        else:
            forward = forward / 12
            right = right / 12
    elif glitch_form == GlitchForm.FLOOR and not on_ground:
        if dir.length() < 0.2:
            forward = forward / 8
            right = right / 8
        else:
            forward = Vector3(0, 0, 0)
            right = Vector3(0, 0, 0)
    
    var horizontal_input = false
    # I'm on the ground or just fell off a platform...
    var kind_of_on_ground = on_ground or (
        was_just_on_ground_timer <= was_just_on_ground_time_limit and vv < 0)
    has_just_jumped_timer += (delta*22)
        
    if kind_of_on_ground or has_just_jumped_timer < has_just_jumped_time_limit or \
        is_pressing_horizontal_input or self.isFeatherLike() or self.glitch_form == GlitchForm.LADDER:
        
        horizontal_input = true
        if glitch_form != GlitchForm.FEATHER and not (glitch_form == GlitchForm.FLOOR and not on_ground):
            #if not (aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"): #jumpSquat Boots
            dir = Vector3(0.0, 0.0, 0.0)

        if not global.pauseMoveInput:
            if pressingMoveForward():
                dir += forward*(delta*DNUMHORZ)
            elif pressingMoveDown():
                dir -= forward*(delta*DNUMHORZ)
                    
            if pressingMoveLeft():
                if aniPlayer != null:
                    # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
                    if not mySprite.flip_h and on_ground and lv.x > 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
                        dir += (right/2)*(delta*DNUMHORZ)
                        if aniPlayer.assigned_animation != "turnAround":
                            aniPlayer.clear_queue()
                            aniPlayer.play("turnAround")
                    elif mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
                        dir += right*(delta*DNUMHORZ)
                        mySprite.flip_h = true
                        if on_ground and aniPlayer.current_animation != "walk":
                            if aniPlayer.current_animation != "land":
                                aniPlayer.clear_queue()
                                aniPlayer.stop()
                            aniPlayer.queue("walk")
                # if there's no animation player, there's no animation. just flip
                else:
                    dir += right*(delta*DNUMHORZ)
                    mySprite.flip_h = true
            elif pressingMoveRight():
                if aniPlayer != null:
                    # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
                    if mySprite.flip_h and on_ground and lv.x < 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
                        dir -= (right/2)*(delta*DNUMHORZ)
                        if aniPlayer.assigned_animation != "turnAround":
                            aniPlayer.clear_queue()
                            aniPlayer.play("turnAround")
                    elif not mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
                        dir -= right*(delta*DNUMHORZ)
                        mySprite.flip_h = false
                        if on_ground and aniPlayer.current_animation != "walk":
                            if aniPlayer.current_animation != "land":
                                aniPlayer.clear_queue()
                                aniPlayer.stop()
                            aniPlayer.queue("walk")
                # if there's no animation player, there's no animation. just flip
                else:
                    dir -= right*(delta*DNUMHORZ)
                    mySprite.flip_h = false
    
    # print("teeter check: " + str(on_ground) + ", " + str(aniPlayer.assigned_animation))
    # TODO(jaketrower): This code will be impossible to read later on. I did this very haphazardly.
    if not pressingMoveLeft() and not pressingMoveRight() and on_ground and aniPlayer and \
        (aniPlayer.current_animation == "walk" or aniPlayer.assigned_animation == "stand" or \
        (aniPlayer.assigned_animation == "turnAround" and not aniPlayer.is_playing()) or aniPlayer.assigned_animation == "teeter"):
        if aniPlayer.assigned_animation == "turnAround" or (aniPlayer.assigned_animation == "teeter" and should_teeter_turn_around):
            mySprite.flip_h = not mySprite.flip_h
            should_teeter_turn_around = false
        aniPlayer.clear_queue()
        if aniPlayer.assigned_animation != "teeter":
            if half_on_ground and not glitch_form == GlitchForm.FLOOR:
                aniPlayer.stop()
                if should_teeter_turn_around:
                    aniPlayer.queue("turnAround")
                aniPlayer.queue("teeter")
            else:
                aniPlayer.play("stand")

    var DNUMSKID = 60
    if self.isFeatherLike():
        if self.isFeatherLike() and dir.length() > 1:
            dir = dir.normalized()
        if on_ground and not self.is_pressing_horizontal_input:
            dir = dir * 0.9*(delta*DNUMSKID)
            if dir.length() < 0.1:
                dir = Vector3(0, 0, 0)
    elif glitch_form == GlitchForm.FLOOR and not on_ground:
        dir = dir * 0.98*(delta*DNUMSKID)
        if dir.length() < 0.1:
            dir = Vector3(0, 0, 0)

    var curr_walk_speed = walk_speed
    # if glitch_form == GlitchForm.FLOOR and not on_ground and not jumped_from_true_ground:
    #     curr_walk_speed = floor_glitch_walk_speed
    if glitch_form == GlitchForm.INVISIBLE:
        curr_walk_speed = invisible_glitch_walk_speed
    elif smallInteractionArea.is_touching_water:
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
    var left_tile_x = int(floor(global_transform.origin.x + lb + lv.x - .5))
    var right_tile_x = int(ceil(global_transform.origin.x + rb + lv.x + .5))
    var top_tile_y = int(ceil(global_transform.origin.y + tb + lv.y + .5))
    var bottom_tile_y = int(floor(global_transform.origin.y + bb + lv.y - .5))
    
    was_on_ground = on_ground
    if glitch_form != GlitchForm.FLOOR:
        on_ground = false
    truly_on_ground = false
    half_on_ground = false

    lv = handleHorizontalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.3)
    global_transform.origin.x += lv.x
    lv = handleVerticalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.1)
    global_transform.origin.y += lv.y
    
    if on_ground:
        feather_fall_timer = 0
        if is_touching_water:
            is_floating = true
    
    lv.x /= delta*DNUM
    lv.y /= delta*DNUM
    return lv

func isTileTypeSolid(tile_type):
    return glitch_form != GlitchForm.WALK_THROUGH_WALLS and tile_type == 1
    
func isTileTypeFallthroughSolid(tile_type):
    return tile_type == 2 or (glitch_form == GlitchForm.WALK_THROUGH_WALLS and tile_type == 1)

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
    
func isRectColliding(o_lb, o_tb, o_rb, o_bb, lb, tb, rb, bb, debug_ = false):
    if debug_:
        print("\tisRectColliding: " + str(lb <= o_rb) + ", " + str(rb >= o_lb) + ", " + str(tb >= o_bb) + ", " + str(bb <= o_tb))
    if lb <= o_rb and rb >= o_lb and tb >= o_bb and bb <= o_tb:
        return true
    return false
    
func handleVerticalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, q):
    var collided_left_side = false
    var collided_true_left_side = false
    var collided_middle = false
    var collided_right_side = false
    var collided_true_right_side = false
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
            var debug_ = false

            # if i == 1:
            #     print("tx: " + str(tile_x) + ", x: " + str(x) + ", y: " + str(y))
            #     debug_ = true
                
            # Check for top collisions
            if lv.y > 0 and not isTileTypeFallthroughSolid(tile_type) and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + q, y + tb + lv.y + 0.1, x + rb - q, y + tb
            ):
                lv.y /= 2
                y = tile_y - tb
                global_transform.origin.y = y

            # Check for bottom collisions
            if lv.y <= 0 and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + q, y + bb, x + rb - q, y + bb + lv.y - 0.1
            ):
                if isTileTypeFallthroughSolid(tile_type) and (tile_y + TILE_HEIGHT > y + bb or pressingDown()):
                    continue
                lv.y = 0
                on_ground = true
                truly_on_ground = true
                y = tile_y + TILE_HEIGHT - bb
                global_transform.origin.y = y

            # check for left, right, middle collisions for teetering
            # TODO(jaketrower): This code will be impossible to read later on. I did this very haphazardly.
            var qteeter = 0.3
            if isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + qteeter, y + bb, x + lb + qteeter, y + bb + lv.y - 0.1, debug_
            ):
                collided_left_side = true
            if isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb, y + bb, x + lb, y + bb + lv.y - 0.1, debug_
            ):
                collided_true_left_side = true
            if isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + rb - qteeter, y + bb, x + rb - qteeter, y + bb + lv.y - 0.1
            ):
                collided_right_side = true
            if isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + rb, y + bb, x + rb, y + bb + lv.y - 0.1
            ):
                collided_true_right_side = true
            if not mySprite.flip_h and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x - .05, y + bb, x - .05, y + bb + lv.y - 0.1
            ) or mySprite.flip_h and isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + .05, y + bb, x + .05, y + bb + lv.y - 0.1
            ):
                collided_middle = true
    # TODO(jaketrower): This code will be impossible to read later on. I did this very haphazardly.
    if truly_on_ground:
        if collided_left_side and not collided_right_side:
            if not collided_middle and not mySprite.flip_h and not aniPlayer.assigned_animation == "teeter":
                should_teeter_turn_around = true
            half_on_ground = true
        elif collided_right_side and not collided_left_side:
            if not collided_middle and mySprite.flip_h and not aniPlayer.assigned_animation == "teeter":
                should_teeter_turn_around = true
            half_on_ground = true
        elif not collided_left_side and not collided_right_side:
            half_on_ground = true
            if (collided_true_left_side and not mySprite.flip_h) or (collided_true_right_side and mySprite.flip_h):
                should_teeter_turn_around = true 
    # print("trulyOnGround: " + str(truly_on_ground) + ", collided_left: " + str(collided_left_side) + ", halfOnGround: " + str(half_on_ground))
    return lv

func postProcessInputs(delta):
    pass
    
func landed():
    last_grounded_y = global_transform.origin.y 
    if landSound: landSound.play()
    if aniPlayer != null:
        aniPlayer.clear_queue()
        aniPlayer.play("land", -1, 1.0 if isFeatherLike() else 2.0)

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

