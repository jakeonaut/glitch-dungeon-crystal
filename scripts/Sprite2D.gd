extends Sprite

var animation_counter = 0
export var frame_delay = 0.4
# If true, this will override frame_delay after first frame change.
export var should_randomize_frame_delay = false
export var randomize_frame_on_init = false
var start_frame = 0
var base_frame = start_frame
export var max_frames = 2

var has_finished_animation = false
var repeat_animation = true

var facing = Vector2(0, 1)
var is_rotating = false

func _ready():
    set_process(true)

    if randomize_frame_on_init:
        self.frame = randi() % ((self.hframes * self.vframes) - max_frames)
    start_frame = get_frame()
    
func changeSpriteColorPalette(palette):
    if self.material:
        var material = self.material
        if material is ShaderMaterial:
            material.set_shader_param("target_palette", palette)
            self.material = material

func preProcess():
    pass

func _process(delta):
    delta = delta * global.time_dilation_multiplier

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
            
func restart():
    animation_counter = 0
    set_frame(start_frame)

func totallyRandomizeFrame():
    self.frame = randi() % ((self.hframes * self.vframes) - max_frames)

func randomizeFrameDelay():
    frame_delay = rand_range(0.1, 1.0)

func updateBaseFrame(hframe, vframe):
    start_frame = (self.hframes * vframe) + hframe
    if base_frame != start_frame:
        base_frame = start_frame
        set_frame(start_frame)
        restart()
