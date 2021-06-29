extends "Sprite.gd"

onready var parent = get_parent()

func _ready():
    set_process(true)

func preProcess():
    .preProcess() # super

    # an object in motion...
    if parent.linear_velocity.x > 0.001 or parent.linear_velocity.x < -0.001 \
       or parent.linear_velocity.z > 0.001 or parent.linear_velocity.z < -0.001 \
       or parent.broom_state > 0:
        frame_delay = 0.1
    # TODO (need to pull this from PlayerGameMover, if glitch_form == GlitchForm.FEATHER and not on_ground)
    elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") \
         or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
        frame_delay = 0.2
    else:
        frame_delay = 0.4

func setNormalClothes():
    updateBaseFrame(0, 0)
func setMothCostume():
    updateBaseFrame(0, 6)
func setBugCatcherCostume():
    updateBaseFrame(0, 2)
func setClericCostume():
    updateBaseFrame(4, 0)
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
func faceLeft():
    faceRight()
    self.flip_h = true
    facing = Vector2(-1, 0)
# @override
func isFacingLeft():
    var right_frame = base_frame + 2
    return start_frame == right_frame and self.flip_h

# @override
func faceRight(set_facing = true):
    var right_frame = base_frame + 2
    if start_frame != right_frame:
        start_frame = right_frame
        set_frame(start_frame)
    self.flip_h = false
    facing = Vector2(1, 0)
# @override
func isFacingRight():
    var right_frame = base_frame + 2
    return start_frame == right_frame and not self.flip_h

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
            faceDown()
        elif isPlayerFacingUp():
            faceUp()
        elif isPlayerFacingRight():
            faceRight()
        elif isPlayerFacingLeft():
            faceLeft()