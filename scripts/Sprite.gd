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
export var should_animate = true # set this to false if you handle animation through an AnimationPlayer

export(String, FILE) var overwritten_green_palette_path = null
var overwritten_green_palette = null
export(String, FILE) var overwritten_yellow_palette_path = null
var overwritten_yellow_palette = null

onready var levelTiles = get_tree().get_root().get_node("Game/Viewport/level/LevelTiles")

func _ready():
    set_process(true)
    start_frame = get_frame()
    original_frame_delay = frame_delay

    var should_duplicate_material = false
    if overwritten_green_palette_path != null:
        overwritten_green_palette = load(overwritten_green_palette_path)
        should_duplicate_material = true
    if overwritten_yellow_palette_path != null:
        overwritten_yellow_palette = load(overwritten_yellow_palette_path)
        should_duplicate_material = true

    if should_duplicate_material and material_override:
        pass
        # TODO(jaketrower): testing performance # material_override = material_override.duplicate()
    
export var automatically_change_color = true
func changeSpriteColorPaletteToLevelPalette():
    if not automatically_change_color:
        return
    changeSpriteColorPalette(levelTiles.curr_palette)

func changeSpriteColorPalette(palette, palette_name = ""):
    if not automatically_change_color:
        return
    if material_override:
        var material = material_override
        if material is ShaderMaterial:
            if palette_name == "green_palette" and overwritten_green_palette != null: # whateva
                palette = overwritten_green_palette
            if palette_name == "yellow_palette" and overwritten_yellow_palette != null: # whateva
                palette = overwritten_yellow_palette
            material.set_shader_param("target_palette", palette)
            material_override = material

func preProcess():
    pass

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    preProcess()
    if visible and should_animate:
        animate(delta)

func trySetFrame(frame):
    if frame < hframes * vframes and frame < start_frame + max_frames:
        set_frame(frame)
        return true
    set_frame((hframes * vframes) - 1)
    return false

func glitchyTrySetFrame(frame):
    if frame < hframes * vframes:
        set_frame(frame)
        return true
    set_frame((hframes * vframes) - 1)
    return false
        
func restart():
    animation_counter = 0
    trySetFrame(start_frame)

func randomizeFrame():
    animation_counter = 0
    trySetFrame(randi() % int(min(max_frames, hframes * vframes)))
    
export var is_really_glitchy = false
func animate(delta):
    if max_frames == 1:
        return

    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = get_frame()

        if is_really_glitchy:
            if not glitchyTrySetFrame(frame+1):
                if should_fizzle_out:
                    queue_free()
                elif should_soft_fizzle_out:
                    visible = false
                else:
                    trySetFrame(start_frame)
        else:
            if not trySetFrame(frame+1):
                if should_fizzle_out:
                    queue_free()
                elif should_soft_fizzle_out:
                    visible = false
                else:
                    trySetFrame(start_frame)

        
        if should_randomize_frame_delay:
            randomizeFrameDelay()
            

func randomizeFrameDelay():
    frame_delay = rand_range(original_frame_delay/4, original_frame_delay*2.2)

func updateBaseFrame(hframe, vframe):
    start_frame = (self.hframes * vframe) + hframe
    base_frame = start_frame
    trySetFrame(start_frame)
    restart()
