extends Sprite3D

var animation_counter = 0
export var frame_delay = 0.4
# If true, this will override frame_delay after first frame change.
export var should_randomize_frame_delay = false
var start_frame = 0
var base_frame = start_frame
export var max_frames = 2

var has_finished_animation = false
var repeat_animation = true

var facing = Vector2(0, 1)
var is_rotating = false

func _ready():
    set_process(true)
    start_frame = get_frame()

func preProcess():
    pass

func _process(delta):
    preProcess()
    animate(delta)
    
func animate(delta):
    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = get_frame()

        if frame >= start_frame and frame < start_frame + max_frames - 1:
            set_frame(frame+1)
        else:
            set_frame(start_frame)
        
        if should_randomize_frame_delay:
            randomizeFrameDelay()

func randomizeFrameDelay():
    frame_delay = rand_range(0.1, 1.0)

func updateBaseFrame(hframe, vframe):
    var is_facing_right = isFacingRight()
    start_frame = (self.hframes * vframe) + hframe
    base_frame = start_frame
    set_frame(start_frame)
    
    if is_facing_right:
        walkRight()
    else:
        walkLeft()

func walkLeft():
    walkRight()
    self.flip_h = true
    facing = Vector2(-1, 0)
func jumpLeft(set_facing = true):
    jumpRight()
    self.flip_h = true
    facing = Vector2(-1, 0)
func fallLeft(set_facing = true):
    fallRight()
    self.flip_h = true
    facing = Vector2(-1, 0)
func isFacingLeft():
    return facing.x == -1 and facing.y == 0

func walkRight(set_facing = true):
    var right_frame = base_frame + 2
    if start_frame != right_frame:
        start_frame = right_frame
        set_frame(start_frame)
    self.flip_h = false
    facing = Vector2(1, 0)
func jumpRight(set_facing = true):
    var right_frame = base_frame + 4
    if start_frame != right_frame:
        start_frame = right_frame
        set_frame(start_frame)
    self.flip_h = false
    facing = Vector2(1, 0)
func fallRight(set_facing = true):
    var right_frame = base_frame + 6
    if start_frame != right_frame:
        start_frame = right_frame
        set_frame(start_frame)
    self.flip_h = false
    facing = Vector2(1, 0)
func isFacingRight():
    return facing.x == 1 and facing.y == 0

func walkUp():
    var up_frame = base_frame + (self.hframes)
    if start_frame != up_frame:
        start_frame = up_frame
        set_frame(start_frame)
    facing = Vector2(0, -1)

    
func isFacingUp():
    # var up_frame = base_frame + (self.hframes)
    # return start_frame == up_frame
    return facing.x == 0 and facing.y == -1

func walkDown():
    var down_frame = base_frame
    if start_frame != down_frame:
        start_frame = down_frame
        set_frame(start_frame)
    facing = Vector2(0, 1)
func isFacingDown():
    # var down_frame = base_frame
    # return start_frame == down_frame
    return facing.x == 0 and facing.y == 1

func fixSpriteFacing():
    if not is_rotating:
        # by default, just face down. Player will have more sophisticated based on facing var and camera
        walkDown()

func setRotating(val):
    is_rotating = val

func setFlipRotating(val):
    # is_flip_rotating = val
    pass