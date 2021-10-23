extends KinematicBody

onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null
onready var jumpSound = get_node("Sounds/JumpSound") if has_node("Sounds/JumpSound") else null
onready var doubleJumpSound = get_node("Sounds/DoubleJumpSound") if has_node("Sounds/DoubleJumpSound") else null
onready var wetJumpSound = get_node("Sounds/WetJumpSound") if has_node("Sounds/WetJumpSound") else null

onready var level = get_tree().get_root().get_node("level")

var levelTiles = null
func getLevelTiles():
    if levelTiles == null:
        levelTiles = level.levelTiles
    return levelTiles

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
var was_just_on_ground_time_limit = 2
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
var last_vv = vv
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
func getNextGlitch():
    if glitch_form == GlitchForm.NORMAL: return GlitchForm.FLOOR
    if glitch_form == GlitchForm.FLOOR: return GlitchForm.FEATHER
    if glitch_form == GlitchForm.FEATHER: return GlitchForm.INVISIBLE
    if glitch_form == GlitchForm.INVISIBLE: return GlitchForm.LADDER
    if glitch_form == GlitchForm.LADDER: return GlitchForm.WALK_THROUGH_WALLS
    if glitch_form == GlitchForm.WALK_THROUGH_WALLS: return GlitchForm.NORMAL
func getPrevGlitch():
    if glitch_form == GlitchForm.NORMAL: return GlitchForm.WALK_THROUGH_WALLS
    if glitch_form == GlitchForm.FLOOR: return GlitchForm.NORMAL
    if glitch_form == GlitchForm.FEATHER: return GlitchForm.FLOOR
    if glitch_form == GlitchForm.INVISIBLE: return GlitchForm.FEATHER
    if glitch_form == GlitchForm.LADDER: return GlitchForm.INVISIBLE
    if glitch_form == GlitchForm.WALK_THROUGH_WALLS: return GlitchForm.LADDER
    
var glitch_form = GlitchForm.NORMAL
var feather_fall_timer = 0
var feather_fall_initial_time_limit = 20
var feather_fall_time_limit = 60
var feather_jump_timer = 0
var feather_jump_time_limit = 10

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
var jump_squat_jump_input_timer = 0
var ladder_timer = 0
# TODO(jaketrower): dedupe with is_pressing_horizontal_input
var is_walking = false
var is_pressing_horizontal_input = false
var was_pressing_horizontal_input = false
var facing = Vector3(0, 0, 1) #default to facing "down" toward the player behind the screen
var transitioning = false
var is_falling = false
var was_walking_into_wall = false

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
    if global.pauseGame: return

    is_touching_water = smallInteractionArea.is_touching_water

    processPhysics(delta) #super

    # if not on_ground and translation.y < (last_grounded_y - falling_y_offset) and not transitioning:
    #     respawn()
    #     is_falling = true
       
func isActive():
    return visible

func tryDieToEnemy():
    pass    
    
func getHitByBroom():
    pass
    
func getCamera():
    return get_tree().get_root().get_node("level").gameCamera

func respawn():
    hv = Vector3(0, 0, 0)
    linear_velocity = Vector3(0, 0, 0)

    global_transform.origin = spawn_origin
    global_transform.origin.y += 2
    last_grounded_y = global_transform.origin.y 

func processPhysics(delta):
    if grav == null: grav = 0 # ???

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
    last_vv = vv

    postProcessInputs(delta)
    prev_dir = dir
    
    just_landed = false
    if not was_on_ground and on_ground: # I just landed!!
        landed()
        just_landed = true
    if aniPlayer != null:
        if (aniPlayer.assigned_animation == "land" or aniPlayer.assigned_animation == "walkStart") and not aniPlayer.is_playing():
            aniPlayer.play("stand")
        elif aniPlayer.assigned_animation == "jump" and on_ground:
            aniPlayer.play("land")

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
        if pressingDown() or (feather_fall_time_limit >= feather_fall_time_limit and not pressingJump()):
            g = Vector3(0, -grav/2, 0)
        else:
            g = Vector3(0, -grav/3, 0)
    else:
        g = Vector3(0, -grav, 0)

    if not on_ground or glitch_form != GlitchForm.FLOOR:
        lv += g * delta
        if lv.y < 0 and not on_ground and aniPlayer and (aniPlayer.current_animation != "jumpSquat" and aniPlayer.current_animation != "jumpStart" and \
           aniPlayer.current_animation != "fall" and aniPlayer.current_animation != "fallStart"):
            aniPlayer.clear_queue()
            aniPlayer.stop()
            aniPlayer.queue("fallStart")
            aniPlayer.queue("fall")

func applyTerminalVelocity(delta):
    feather_fall_timer += (delta*22)
    if smallInteractionArea.is_touching_water or glitch_form == GlitchForm.FEATHER:
        if pressingJump() and feather_fall_timer < feather_fall_initial_time_limit:
            terminal_vel = water_terminal_vel/2
        elif pressingDown() or feather_fall_timer >= feather_fall_time_limit:
            terminal_vel = true_terminal_vel
            feather_fall_timer = feather_fall_time_limit
        else:
            terminal_vel = water_terminal_vel
    else:
        terminal_vel = true_terminal_vel
        if pressingJump():
            feather_fall_timer = 0

    if vv < -terminal_vel:
        vv = -terminal_vel

    if glitch_form == GlitchForm.FLOOR and on_ground:
        vv = 0

func processInputs(delta):
    processJumpInputs(delta)
    processHorizontalInputs(delta)
    if justPressedDown():
        on_ground = false

    # fail safe...
    if vv > jump_force*2:
        vv = jump_force*2
        if was_walking_into_wall and not isWalkingIntoWall():
            vv = 1
    was_walking_into_wall = isWalkingIntoWall()
    if was_walking_into_wall and glitch_form == GlitchForm.LADDER:
        vv = 6
        # ladder_timer += (delta*22)
        # # CLIMB BABY!!!!
        # if ladder_timer < 8:
        #     vv = -1
        # if ladder_timer >= 8:
        #     ladder_timer = 0
        #     vv = jump_force * 8
    was_pressing_horizontal_input = is_pressing_horizontal_input

func justPressedDown():
    return false
    
func pressingDown():
    return false

func justPressedJump():
    return false
    
func recentlyJustPressedJump():
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
    if (justPressedJump() or recentlyJustPressedJump()) and not global.pauseMoveInput: 
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
        elif isKindOfOnGround():
            jumped_from_true_ground = truly_on_ground
            jump_squat_jump_input_timer = 0
            feather_jump_timer = 0
            if not aniPlayer:
                jump_squat_jump_input_timer = 1
                actuallyApplyJump()

            if aniPlayer and not "jump" in aniPlayer.assigned_animation:
                aniPlayer.clear_queue()
                aniPlayer.play("jumpSquat", -1, .6 if isFeatherLike() else 1.0)
                aniPlayer.queue("jumpStart")
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

    if aniPlayer:
        if aniPlayer.assigned_animation == "jumpSquat":
            vv = 0
            if pressingJump():
                jump_squat_jump_input_timer += (delta*22)
        if aniPlayer.assigned_animation != "jumpSquat" and jump_squat_jump_input_timer > 0:
            actuallyApplyJump()
            jump_squat_jump_input_timer = 0
            

    if isFeatherLike() and feather_jump_timer < feather_jump_time_limit and pressingJump() and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat"): 
        feather_jump_timer += (delta*22)
        actuallyApplyJump(false)
    elif feather_jump_timer < 4 and pressingJump() and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat"):
        feather_jump_timer += (delta*22)
        if feather_jump_timer > 3: 
            actuallyApplyJump(false)
    elif pressingJump() and feather_jump_timer < 7: 
        feather_jump_timer += (delta*22)
    if not pressingJump():
        feather_jump_timer = 200

func actuallyApplyJump(play_sound = true):
    if isFeatherLike():
        if feather_jump_timer < 5:
            if vv < (2*jump_force) / 3:
                vv = (2*jump_force) / 3
        elif feather_jump_timer < 8:
            if vv < jump_force / 2:
                vv = jump_force / 2
        else:
            if vv < jump_force / 3:
                vv = jump_force / 3
    elif not play_sound:
        if vv < (1.58*jump_force)/3:
            vv = (1.58*jump_force)/3
    elif glitch_form == GlitchForm.INVISIBLE:
        vv = invisible_jump_force
    else:
        # rocket boost boots
        # vv = jump_force*3
        vv = jump_force*1.1
    jumpSound.play() if jumpSound and play_sound else null
    on_ground = false
    has_just_jumped_timer = 0 
    feather_fall_timer = 0
    should_magic_jump = false

func isKindOfOnGround():
    # I'm on the ground or just fell off a platform...
    return (on_ground or (was_just_on_ground_timer <= was_just_on_ground_time_limit and vv < 0)) and (not aniPlayer or not "jump" in aniPlayer.assigned_animation)
        

const PROJECTION_ORTHOGONAL = 1
func processHorizontalInputs(delta):
    is_pressing_horizontal_input = pressingMoveLeft() or pressingMoveRight() or pressingMoveForward() or pressingMoveDown()
    var is_pressing_opposite_horizontal_input = (pressingMoveLeft() and dir.x > 0) or (pressingMoveRight() and dir.x < 0)

    # Forward as "seen" by the camera (OpenGL convention)
    var view_forward = -getCamera().get_transform().basis.z
    var view_right = -getCamera().get_transform().basis.x
    # Forward as "seen" by the player
    var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()
    var right = view_right

    var glitch_floor_jump_walking = (glitch_form == GlitchForm.FLOOR and not on_ground and not (aniPlayer != null and \
        (aniPlayer.assigned_animation == "jumpSquat" or aniPlayer.assigned_animation == "jumpStart")))
    if glitch_form == GlitchForm.FEATHER and not (aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"):
        if on_ground:
            # TODO(jaketrower): Initial dash state..???
            forward = forward / 8
            right = right / 8
        else:
            if dir.length() < 0.2:
                forward = forward / 8
                right = right / 8
            else:
                forward = forward / 32
                right = right / 32
    # elif glitch_floor_jump_walking:
    #     if dir.length() < 0.2:
    #         forward = forward / 8
    #         right = right / 8
    #     else:
    #         forward = Vector3(0, 0, 0)
    #         right = Vector3(0, 0, 0)
    
    var horizontal_input = false
    has_just_jumped_timer += (delta*22)
        
    if isKindOfOnGround() or has_just_jumped_timer < has_just_jumped_time_limit or \
        is_pressing_horizontal_input or self.isFeatherLike() or self.glitch_form == GlitchForm.LADDER:
        
        horizontal_input = true
        if glitch_form == GlitchForm.NORMAL:
            #if not (aniPlayer != null and aniPlayer.assigned_animation == "jumpSquat"): #jumpSquat Boots
            dir = Vector3(0.0, 0.0, 0.0)
        elif glitch_form == GlitchForm.FEATHER:
            if is_pressing_opposite_horizontal_input and (aniPlayer == null or aniPlayer.assigned_animation == "jumpStart" or aniPlayer.assigned_animation == "turnAround"):
                dir = Vector3(0.0, 0.0, 0.0)
        elif glitch_form == GlitchForm.FLOOR:
            if is_pressing_horizontal_input or on_ground: # and not glitch_floor_jump_walking:
                dir = Vector3(0.0, 0.0, 0.0)
        else:
            dir = Vector3(0.0, 0.0, 0.0)
            

        if not global.pauseMoveInput and not (aniPlayer and aniPlayer.assigned_animation == "jumpSquat"):
            if pressingMoveForward():
                dir += forward*(delta*DNUMHORZ)
            elif pressingMoveDown():
                dir -= forward*(delta*DNUMHORZ)
                    
            if pressingMoveLeft():
                should_teeter_turn_around = false
                if aniPlayer != null:
                    # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
                    if not mySprite.flip_h and on_ground and lv.x > 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
                        dir += (right/2)*(delta*DNUMHORZ)
                        if aniPlayer.assigned_animation != "turnAround":
                            aniPlayer.stop()
                            aniPlayer.clear_queue()
                            aniPlayer.queue("turnAround")
                            aniPlayer.queue("walkStart")
                    elif mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
                        dir += right*(delta*DNUMHORZ)
                        mySprite.flip_h = true
                        doWalkAnimation()
                # if there's no animation player, there's no animation. just flip
                else:
                    dir += right*(delta*DNUMHORZ)
                    mySprite.flip_h = true
            elif pressingMoveRight():
                should_teeter_turn_around = false
                if aniPlayer != null:
                    # this logic looks really complicated but it's basically handling turn around animation and acceleration delay
                    if mySprite.flip_h and on_ground and lv.x < 0 and aniPlayer.assigned_animation != "turnAround" or (aniPlayer.assigned_animation == "turnAround" and aniPlayer.is_playing()):
                        dir -= (right/2)*(delta*DNUMHORZ)
                        if aniPlayer.assigned_animation != "turnAround":
                            aniPlayer.clear_queue()
                            aniPlayer.play("turnAround")
                            aniPlayer.queue("walkStart")
                    elif not mySprite.flip_h or aniPlayer.assigned_animation != "turnAround" or not aniPlayer.is_playing():
                        dir -= right*(delta*DNUMHORZ)
                        mySprite.flip_h = false
                        doWalkAnimation()
                # if there's no animation player, there's no animation. just flip
                else:
                    dir -= right*(delta*DNUMHORZ)
                    mySprite.flip_h = false
    
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
            elif aniPlayer.assigned_animation != "walkStop" and aniPlayer.assigned_animation != "stand":
                aniPlayer.stop()
                if aniPlayer.assigned_animation == "walk":
                    aniPlayer.queue("walkStop")
                aniPlayer.queue("stand")

    var DNUMSKID = 60
    if self.isFeatherLike():
        if dir.length() > 1:
            dir = dir.normalized()
        if on_ground and not self.is_pressing_horizontal_input:
            dir = dir * 0.9*(delta*DNUMSKID)
            if dir.length() < 0.1:
                dir = Vector3(0, 0, 0)
        elif not on_ground:
            dir = dir * 0.99*(delta*DNUMSKID)
            if dir.length() < 0.01:
                dir = Vector3(0, 0, 0)
    # elif glitch_form == GlitchForm.FLOOR and not on_ground:
    #     dir = dir * 0.97*(delta*DNUMSKID)
    #     if dir.length() < 0.1:
    #         dir = Vector3(0, 0, 0)

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

func doWalkAnimation():
    if on_ground and aniPlayer.current_animation != "walk" and aniPlayer.current_animation != "walkStart":
        if aniPlayer.current_animation != "land":
            aniPlayer.clear_queue()
            aniPlayer.stop()
        if aniPlayer.assigned_animation == "stand" or aniPlayer.assigned_animation == "turnAround" or aniPlayer.assigned_animation == "walkStop":
            aniPlayer.queue("walkStart")
        aniPlayer.queue("walk")
        
# http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/
# https://info.sonicretro.org/SPG:Solid_Tiles
func handleCollisionsAndMove(lv, delta):
    if delta == 0:
        return lv
        
    var DNUM = 1.15
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

    # lv = handleHorizontalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.3)
    global_transform.origin.x += lv.x
    lv = handleVerticalCollisions(lv)
    global_transform.origin.y += lv.y

    # handleSpikeCollisions(left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, 0.1)
    
    if on_ground:
        feather_fall_timer = 0
        if is_touching_water:
            is_floating = true
    
    lv.x /= delta*DNUM
    lv.y /= delta*DNUM
    return lv

func isTileSolid(tile_type):
    if tile_type == GridMap.INVALID_CELL_ITEM:
        return false
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    return glitch_form != GlitchForm.WALK_THROUGH_WALLS and tileCollisionShape is BoxShape
    
func isTileFallthroughSolid(tile_type):
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    return tileCollisionShape is PlaneShape or (glitch_form == GlitchForm.WALK_THROUGH_WALLS and tileCollisionShape is BoxShape)

func isTileNotSolid(tile_type):
    return tile_type == -1 or len(getLevelTiles().mesh_library.get_item_shapes(tile_type)) == 0 or isTileSpikes(tile_type)
    
func isTileSpikes(tile_type):
    var tileCollisionShape = getLevelTiles().mesh_library.get_item_shapes(tile_type)[0]
    return tileCollisionShape is RayShape
    
func handleHorizontalCollisions(lv, left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, q):
    self.horizontal_collision = false
    for i in range(bottom_tile_y, top_tile_y):
        for j in range(left_tile_x, right_tile_x):
            var coords = getLevelTiles().world_to_map(Vector3(j, i, global_transform.origin.z))
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if tile_type == GridMap.INVALID_CELL_ITEM or not isTileSolid(tile_type):
                continue

            var x = global_transform.origin.x
            var y = global_transform.origin.y
            var lb = -get_node("CollisionShape").shape.radius
            var tb = get_node("CollisionShape").shape.height/2
            var rb = -lb
            var bb = -tb
            var TILE_WIDTH = getLevelTiles().cell_size.x
            var TILE_HEIGHT = getLevelTiles().cell_size.y
            var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
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
    
func probeSensorDown(sensor):
    var z = global_transform.origin.z
    var TILE_HEIGHT = getLevelTiles().cell_size.y
    
    var coords_a = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y, z))
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)
    
    var tile_height = -999
    if isTileSolid(tile_type_a):
        # We found a collision, regress to see if there is a previous one
        var coords_b = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y + TILE_HEIGHT, z))
        var tile_type_b = getLevelTiles().get_cell_item(coords_b.x, coords_b.y, coords_b.z)
        if isTileSolid(tile_type_b):
            # Found an earlier tile collision, use it instead of tile A
            tile_height = coords_b.y + TILE_HEIGHT
        else:
            # Did not find an earlier tile collision, so use tile A
            tile_height = coords_a.y + TILE_HEIGHT
    else:
        # We have found no collision, extend to see if there is an upcoming one
        var coords_b = getLevelTiles().world_to_map(Vector3(sensor.x, sensor.y - TILE_HEIGHT, z))
        var tile_type_b = getLevelTiles().get_cell_item(coords_b.x, coords_b.y, coords_b.z)
        if isTileSolid(tile_type_b):
            # Found a later tile collision, use it
            tile_height = coords_b.y + TILE_HEIGHT
        else:
            # We found no tile collision on this side! Just use default :)
            pass
    return tile_height

func collideWithFloor(local_lv):
    local_lv.y = 0
    on_ground = true
    truly_on_ground = true
    return local_lv
    
func handleVerticalCollisions(local_lv):
    var x = global_transform.origin.x
    var y = global_transform.origin.y
    var lb = -get_node("CollisionShape").shape.radius
    var tb = get_node("CollisionShape").shape.height/2
    var rb = -lb
    var bb = -tb

    # check for bottom collisions
    if truly_on_ground or local_lv.y <= 0:
        # Check for left ground sensor
        var left_floor_sensor = Vector2(x+lb, y+bb)
        if not truly_on_ground:
            # add y speed to floor checking if we're in the air
            left_floor_sensor.y += local_lv.y
        var left_floor_tile_height = probeSensorDown(left_floor_sensor)
        var left_floor_tile_distance = (y+bb) - left_floor_tile_height

        # Check for right ground sensor
        var right_floor_sensor = Vector2(x+rb, y+bb)
        if not truly_on_ground:
            # add y speed to floor checking if we're in the air
            right_floor_sensor.y += local_lv.y
        var right_floor_tile_height = probeSensorDown(right_floor_sensor)
        var right_floor_tile_distance = (y+bb) - right_floor_tile_height

        # Check for middle ground sensor
        var middle_floor_sensor = Vector2(x, y+bb)
        if not truly_on_ground:
            # add y speed to floor checking if we're in the air
            middle_floor_sensor.y += local_lv.y
        var middle_floor_tile_height = probeSensorDown(middle_floor_sensor)
        var middle_floor_tile_distance = (y+bb) - middle_floor_tile_height

        # Compare left and right floor tile distances
        if left_floor_tile_distance <= right_floor_tile_distance and left_floor_tile_distance <= middle_floor_tile_distance:
            if left_floor_tile_distance <= 0:
                # push player out of the tile!
                global_transform.origin.y -= left_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            elif (y + local_lv.y + bb) < left_floor_tile_height:
                # position + velocity will exceed tile position, so let's snap!
                global_transform.origin.y -= left_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            # else no collision
        elif right_floor_tile_distance < left_floor_tile_distance and right_floor_tile_distance <= middle_floor_tile_distance:
            if right_floor_tile_distance <= 0:
                global_transform.origin.y -= right_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            elif (y + local_lv.y + bb) < right_floor_tile_height:
                # position + velocity will exceed tile position, so let's snap!
                global_transform.origin.y -= right_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            # else no collision
        else:
            # special case for checking middle collision, because GameMovers are often larger than a single tile...
            if middle_floor_tile_distance <= 0:
                global_transform.origin.y -= middle_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            elif (y + local_lv.y + bb) < middle_floor_tile_height:
                # position + velocity will exceed tile position, so let's snap!
                global_transform.origin.y -= middle_floor_tile_distance
                local_lv = collideWithFloor(local_lv)
            # else no collision

    # check for top collisions
    if not truly_on_ground and local_lv.y > 0:
        pass
    
    return local_lv
    # var collided_left_side = false
    # var collided_true_left_side = false
    # var collided_middle = false
    # var collided_right_side = false
    # var collided_true_right_side = false
    # for i in range(bottom_tile_y, top_tile_y):
    #     for j in range(left_tile_x, right_tile_x):
    #         var coords = getLevelTiles().world_to_map(Vector3(j, i, global_transform.origin.z))
    #         var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
    #         if tile_type == GridMap.INVALID_CELL_ITEM or isTileNotSolid(tile_type):
    #             continue

    #         var x = global_transform.origin.x
    #         var y = global_transform.origin.y
    #         var lb = -get_node("CollisionShape").shape.radius
    #         var tb = get_node("CollisionShape").shape.height/2
    #         var rb = -lb
    #         var bb = -tb
    #         var TILE_WIDTH = getLevelTiles().cell_size.x
    #         var TILE_HEIGHT = getLevelTiles().cell_size.y
    #         var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
    #         var tile_x = tile_pos.x - TILE_WIDTH/2
    #         var tile_y = tile_pos.y - TILE_HEIGHT/2
    #         var debug_ = false

    #         # if i == 1:
    #         #     print("tx: " + str(tile_x) + ", x: " + str(x) + ", y: " + str(y))
    #         #     debug_ = true
                
    #         # Check for top collisions
    #         if lv.y > 0 and not isTileFallthroughSolid(tile_type) and isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + lb + q, y + tb + lv.y + 0.1, x + rb - q, y + tb
    #         ):
    #             lv.y /= 2
    #             y = tile_y - tb
    #             global_transform.origin.y = y

    #         # Check for bottom collisions
    #         if lv.y <= 0 and isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + lb + q, y + bb, x + rb - q, y + bb + lv.y - 0.1
    #         ):
    #             if isTileFallthroughSolid(tile_type) and \
    #                 (tile_y + TILE_HEIGHT > y + bb + 0.1 or \
    #                     (pressingDown() and not glitch_form == GlitchForm.WALK_THROUGH_WALLS and not isTileSolid(tile_type))):
    #                 continue
    #             lv.y = 0
    #             on_ground = true
    #             truly_on_ground = true
    #             y = tile_y + TILE_HEIGHT - bb
    #             global_transform.origin.y = y

    #         # check for left, right, middle collisions for teetering
    #         # TODO(jaketrower): This code will be impossible to read later on. I did this very haphazardly.
    #         var qteeter = 0.3
    #         if isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + lb + qteeter, y + bb, x + lb + qteeter, y + bb + lv.y - 0.1, debug_
    #         ):
    #             collided_left_side = true
    #         if isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + lb, y + bb, x + lb, y + bb + lv.y - 0.1, debug_
    #         ):
    #             collided_true_left_side = true
    #         if isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + rb - qteeter, y + bb, x + rb - qteeter, y + bb + lv.y - 0.1
    #         ):
    #             collided_right_side = true
    #         if isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + rb, y + bb, x + rb, y + bb + lv.y - 0.1
    #         ):
    #             collided_true_right_side = true
    #         if not mySprite.flip_h and isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x - .05, y + bb, x - .05, y + bb + lv.y - 0.1
    #         ) or mySprite.flip_h and isRectColliding(
    #             tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
    #             x + .05, y + bb, x + .05, y + bb + lv.y - 0.1
    #         ):
    #             collided_middle = true
    # # TODO(jaketrower): This code will be impossible to read later on. I did this very haphazardly.
    # if truly_on_ground:
    #     if collided_left_side and not collided_right_side:
    #         if not collided_middle and not mySprite.flip_h and (not aniPlayer or not aniPlayer.assigned_animation == "teeter"):
    #             should_teeter_turn_around = true
    #         half_on_ground = true
    #     elif collided_right_side and not collided_left_side:
    #         if not collided_middle and mySprite.flip_h and (not aniPlayer or not aniPlayer.assigned_animation == "teeter"):
    #             should_teeter_turn_around = true
    #         half_on_ground = true
    #     elif not collided_left_side and not collided_right_side:
    #         half_on_ground = true
    #         if (collided_true_left_side and not mySprite.flip_h) or (collided_true_right_side and mySprite.flip_h):
    #             should_teeter_turn_around = true 
    # return lv
    
func handleSpikeCollisions(left_tile_x, right_tile_x, top_tile_y, bottom_tile_y, q):
    for i in range(bottom_tile_y, top_tile_y):
        for j in range(left_tile_x, right_tile_x):
            var coords = getLevelTiles().world_to_map(Vector3(j, i, global_transform.origin.z))
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if tile_type == GridMap.INVALID_CELL_ITEM or not isTileSpikes(tile_type): 
                continue
                
            var x = global_transform.origin.x
            var y = global_transform.origin.y
            var lb = -get_node("CollisionShape").shape.radius
            var tb = get_node("CollisionShape").shape.height/2
            var rb = -lb
            var bb = -tb
            var TILE_WIDTH = getLevelTiles().cell_size.x
            var TILE_HEIGHT = getLevelTiles().cell_size.y
            var tile_pos = getLevelTiles().map_to_world(coords.x, coords.y, coords.z)
            var tile_x = tile_pos.x - TILE_WIDTH/2
            var tile_y = tile_pos.y - TILE_HEIGHT/2
            
            if isRectColliding(
                tile_x, tile_y + TILE_HEIGHT, tile_x + TILE_WIDTH, tile_y,
                x + lb + q, y + tb - q, x + rb - q, y + bb + q
            ):
                tryDieToEnemy()
                return

func postProcessInputs(delta):
    pass
    
func landed():
    last_grounded_y = global_transform.origin.y 
    if landSound: landSound.play()
    if aniPlayer != null and last_vv < 1 and aniPlayer.assigned_animation != "jumpSquat" and aniPlayer.assigned_animation != "jumpStart":
        aniPlayer.clear_queue()
        aniPlayer.play("land", -1, 1.0 if isFeatherLike() else 2.0)

func isWalkingIntoWall():
    return linear_velocity.x < 2 and linear_velocity.x > -2 \
            and linear_velocity.z < 2 and linear_velocity.z > -2 \
            and is_pressing_horizontal_input and was_pressing_horizontal_input \
            and (not aniPlayer or aniPlayer.assigned_animation != "jumpSquat") 

func updateFacing(dir):
    if dir.x != 0 or dir.y != 0 or dir.z != 0:
        facing = dir
        is_walking = true
    else:
        is_walking = false

