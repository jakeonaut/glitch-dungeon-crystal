extends CanvasLayer

# https://fede0d.github.io/blog/2016/02/07/Godot-Extra-Tips-2.html

# STORE THE SCENE PATH
var path = ""
var was_i_interrupted = false

onready var aniPlayer = get_node("AnimationPlayer")

func _ready():
    set_process(true)

func _process(_delta):
    aniPlayer.playback_speed = global.time_dilation_multiplier

# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("fade") # play the transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func long_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("long_fade") # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func blink_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("blink_fade") # play the blink transition animation

func interrupt():
    was_i_interrupted = true
    aniPlayer.stop()
    aniPlayer.seek(0, true)

# PRIVATE FUNCTION. CALLED AT THE MIDDLE OF THE TRANSITION ANIMATION
func change_scene():
    # print("was i interrupted?: " + str(was_i_interrupted) + ", " + str(self.path))
    if was_i_interrupted:
        was_i_interrupted = false
        return

    if self.path != "":
        var _was_change_ok = get_tree().change_scene(self.path)
    else:
        global.pauseGame = true
        
    if global.activeThrowableObject:
        global.activeThrowableObjectPath = global.activeThrowableObject.filename