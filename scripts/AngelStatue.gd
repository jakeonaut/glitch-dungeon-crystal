extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var activateSound = get_node("ActivateSound")
onready var tweetSound = get_node("TweetSound")
var hasRandomizedTweet = false
var is_angel_activated = false

func _ready():
    set_process(true)
    
func _process(_delta):
    if tweetSound.is_playing() and not hasRandomizedTweet:
        tweetSound.pitch_scale = rand_range(0.8, 1.5)
        hasRandomizedTweet = true
    
    if not tweetSound.is_playing():
        hasRandomizedTweet = false


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
    

func stopPassiveActivate():
    pass