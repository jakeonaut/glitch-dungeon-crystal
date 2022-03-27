extends "Sprite.gd"

onready var parent = get_parent()

func _ready():
    set_process(true)

func preProcess():
    .preProcess() # super

    # an object in motion...
    if not parent.on_ground \
       or parent.linear_velocity.x > 0.001 or parent.linear_velocity.x < -0.001 \
       or parent.linear_velocity.z > 0.001 or parent.linear_velocity.z < -0.001 \
       or parent.broom_state > 0:
        frame_delay = 0.1
    # TODO (need to pull this from PlayerGameMover, if glitch_form == global.GlitchForm.FEATHER and not on_ground)
    elif parent.pressingMoveRight() or parent.pressingMoveLeft() \
       or parent.pressingMoveDown() or parent.pressingMoveUp():
        frame_delay = 0.2
    else:
        frame_delay = 0.4
    
    # var shouldFaceLeft = not parent.pressingMoveRight() and (parent.pressingMoveLeft() or self.isFacingLeft())
    # var shouldFaceRight = not parent.pressingMoveLeft() and (parent.pressingMoveRight() or self.isFacingRight())
    # if parent.on_ground:
    #     if shouldFaceRight:
    #         walkRight()
    #     elif shouldFaceLeft:
    #         walkLeft()
    # else:
    #     # jumping up
    #     if parent.linear_velocity.y > 0:
    #         if shouldFaceRight:
    #             jumpRight()
    #         elif shouldFaceLeft:
    #             jumpLeft()
    #     if parent.linear_velocity.y < 0:
    #         if shouldFaceRight:
    #             fallRight()
    #         elif shouldFaceLeft:
    #             fallLeft()
                

func setNormalClothes():
    updateBaseFrame(0, 0)
func setMothCostume():
    updateBaseFrame(0, 6)
func setBugCatcherCostume():
    updateBaseFrame(0, 2)
func setClericCostume():
    updateBaseFrame(0, 8)
func setLuckyCatCostume():
    updateBaseFrame(0, 4)
func setNightgown():
    updateBaseFrame(4, 2)

# @override
func animate(delta):
    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = get_frame()

        if self.isFacingRight() or self.isFacingLeft():
            if frame >= start_frame and frame < start_frame + max_frames - 1:
                set_frame(frame+1)
            else:
                set_frame(start_frame)
        elif self.isFacingDown() or self.isFacingUp():
            set_frame(start_frame)
            # TODO(jaketrower): Need a better way to say if 
            if not parent.on_ground:
                self.flip_h = not self.flip_h
        else:
            set_frame(start_frame)
        
        if should_randomize_frame_delay:
            randomizeFrameDelay()

# @override
func isFacingUp():
    return .isFacingUp()

# @override
func isFacingDown():
    return .isFacingDown()

func isPlayerFacingDown():
    # Forward as "seen" by the camera (OpenGL convention)
    var view_forward = -parent.getCamera().get_transform().basis.z
    # Forward as "seen" by the player
    var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()

    var player_facing = parent.facing
    var facing_angle =  rad2deg(acos(player_facing.normalized().dot(forward)))
    
    return 225 > facing_angle and facing_angle > 135

func isPlayerFacingUp():
    var view_forward = -parent.getCamera().get_transform().basis.z
    # Forward as "seen" by the player
    var forward = Vector3(view_forward.x, 0.0, view_forward.z).normalized()

    var player_facing = parent.facing
    var facing_angle =  rad2deg(acos(player_facing.normalized().dot(forward)))

    return (45 > facing_angle and facing_angle >= 0) or (360 >= facing_angle and facing_angle > 325)

func isPlayerFacingRight():
    var view_right = -parent.getCamera().get_transform().basis.x
    # Right as "seen" by the player
    var right = view_right

    var player_facing = parent.facing
    var facing_angle_right =  rad2deg(acos(player_facing.normalized().dot(right.normalized())))
    return 225 > facing_angle_right and facing_angle_right > 135

func isPlayerFacingLeft():
    var view_right = -parent.getCamera().get_transform().basis.x
    # Right as "seen" by the player
    var right = view_right

    var player_facing = parent.facing
    var facing_angle_right =  rad2deg(acos(player_facing.normalized().dot(right.normalized())))
    return (45 > facing_angle_right and facing_angle_right >= 0) or (360 >= facing_angle_right and facing_angle_right > 325)

func fixSpriteFacing():
    if not is_rotating:
        if isPlayerFacingDown():
            walkDown()
        elif isPlayerFacingUp():
            walkUp()
        elif isPlayerFacingRight():
            walkRight()
        elif isPlayerFacingLeft():
            walkLeft()