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

func unpause():
    global.pauseGame = false

func fast_reverse_fade():
    aniPlayer.play("reverse_fade", -1, 2.0)
func reverse_fade():
    aniPlayer.play("reverse_fade")
func reverse_granny_teleport():
    aniPlayer.play("reverse_granny_teleport")
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func granny_teleport_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("granny_teleport", -1, 1.0)
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func fast_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("long_fade", -1, 2.0) # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func long_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("long_fade") # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func really_long_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("long_fade", -1, 0.5) # play the long transition animation
# PUBLIC FUNCTION. CALLED WHENEVER YOU WANT TO CHANGE SCENE
func really_really_long_fade_to(scn_path):
    was_i_interrupted = false
    self.path = scn_path # store the scene path
    aniPlayer.play("really_long_fade")

func interrupt():
    was_i_interrupted = true
    aniPlayer.stop()
    aniPlayer.seek(0, true)

# PRIVATE FUNCTION. CALLED AT THE MIDDLE OF THE TRANSITION ANIMATION
func change_scene():
    if was_i_interrupted:
        was_i_interrupted = false
        return

    global.set_camera_position_on_respawn = true

    if self.path != "":
        var was_change_ok = get_tree().change_scene(self.path)
        if was_change_ok != OK:
            was_change_ok = get_tree().change_scene("res://levels/EndlessFantasy/gd1FishingVillage/000FishingVillageIntro.tscn")
            print("okay something is broken")
            global.pauseGame = false
    else:
        global.pauseGame = false
        
    if global.activeThrowableObject:
        global.activeThrowableObjectPath = global.activeThrowableObject.filename