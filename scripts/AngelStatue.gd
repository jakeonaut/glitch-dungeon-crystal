extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var activateSound = get_node("ActivateSound")
onready var mySprite = get_node("Sprite3D")
onready var tweetSound = get_node("TweetSound")
var hasRandomizedTweet = false
var is_angel_activated = false

func _ready():
    set_process(true)
    
func _process(delta):
    aniPlayer.playback_speed = global.time_dilation_multiplier
    delta = delta * global.time_dilation_multiplier

    if tweetSound.is_playing() and not hasRandomizedTweet:
        tweetSound.pitch_scale = rand_range(0.8, 1.5)
        hasRandomizedTweet = true
    
    if not tweetSound.is_playing():
        hasRandomizedTweet = false
        
    if is_angel_activated and aniPlayer.current_animation == "ActivatedIdle":
        var my_material = mySprite.get_material_override()
        if my_material is ShaderMaterial:
            my_material.set_shader_param("enable_palette_cycle", false)


func isActive():
    return true

func passiveActivate(_delta):
    if not is_angel_activated:
        is_angel_activated = true
        activateSound.play()
        aniPlayer.stop()
        aniPlayer.clear_queue()
        aniPlayer.queue("BirdFlyIn")
        aniPlayer.queue("ActivatedIdle")
        var my_material = mySprite.get_material_override()
        if my_material is ShaderMaterial:
            my_material.set_shader_param("enable_palette_cycle", true)
    

func stopPassiveActivate():
    pass
