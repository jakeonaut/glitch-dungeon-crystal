extends Sprite3D

var animation_counter = 0
export var frame_delay = 0.4
var original_frame_delay = 0
# If true, this will override frame_delay after first frame change.
export var should_randomize_frame_delay = false
var start_frame = 0
var base_frame = start_frame
export var max_frames = 2

var has_finished_animation = false
var repeat_animation = true

var facing = Vector2(0, 1)
var is_rotating = false
export var should_fizzle_out = false
var should_soft_fizzle_out = false

func _ready():
    set_process(true)
    start_frame = get_frame()
    original_frame_delay = frame_delay
    
func changeSpriteColorPalette(palette):
    var material = material_override
    if material is ShaderMaterial:
        material.set_shader_param("target_palette", palette)
        material_override = material

func preProcess():
    pass

func _process(delta):
    preProcess()
    if visible:
        animate(delta)
    
func animate(delta):
    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = get_frame()

        if frame >= start_frame and frame < start_frame + max_frames - 1:
            set_frame(frame+1)
        else:
            if should_fizzle_out:
                queue_free()
            elif should_soft_fizzle_out:
                visible = false
            else:
                set_frame(start_frame)
        
        if should_randomize_frame_delay:
            randomizeFrameDelay()
            

func randomizeFrameDelay():
    frame_delay = rand_range(original_frame_delay/4, original_frame_delay*2.2)

func updateBaseFrame(hframe, vframe):
    start_frame = (self.hframes * vframe) + hframe
    base_frame = start_frame
    set_frame(start_frame)
