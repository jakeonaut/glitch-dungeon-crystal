extends Spatial

onready var splashSprite = get_node("SplashSprite")
onready var splashSound = get_node("SplashSound")
onready var miniSplashSound = get_node("MiniSplashSound")
onready var miniSplashSound2 = get_node("MiniSplashSound2")
onready var area = get_node("Area")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    set_process(true)

func _process(_delta):
    pass
    
func isActive():
    return true
    
func passiveActivate(_delta):
    if not getPlayer().was_touching_water:
        if bigSplash():
            splashSound.play()
        else:
            if randi() % 2 == 0:
                miniSplashSound.play()
            else:
                miniSplashSound2.play()
        if getPlayer().global_transform.origin.y > global_transform.origin.y:
            makeNewSplashSprite(-0.418)
            makeNewSplashSprite(0.582)
            
func justStopPassiveActivate():
    if not getPlayer().is_touching_water:
        if bigSplash():
            splashSound.play()
        else:
            if randi() % 3 == 0:
                miniSplashSound.pitch_scale = rand_range(1, 1.8)
                miniSplashSound.play()
            else:
                miniSplashSound2.pitch_scale = rand_range(0.8, 1.5)
                miniSplashSound2.play()
        if getPlayer().global_transform.origin.y > global_transform.origin.y:
            makeNewSplashSprite(-0.418, true)
            makeNewSplashSprite(0.582, true)
            
func bigSplash():
    return abs(getPlayer().linear_velocity.y) > 10
        
func makeNewSplashSprite(x_offset, is_mini = false):
    var newSplashSprite = splashSprite.duplicate()
    newSplashSprite.should_fizzle_out = true
    newSplashSprite.visible = true

    # x not less than -0.498, not greater than 2.502
    var new_x = getPlayer().global_transform.origin.x - self.global_transform.origin.x + x_offset
    newSplashSprite.transform.origin.x = clamp(new_x, -0.498, 2.502)
    
    if is_mini:
        newSplashSprite.updateBaseFrame(4, 0)
        newSplashSprite.max_frames = 2
    elif bigSplash():
        newSplashSprite.updateBaseFrame(0, 0)
        newSplashSprite.max_frames = 5
    else:
        newSplashSprite.updateBaseFrame(3, 0)
        newSplashSprite.max_frames = 3
        newSplashSprite.frame_delay = 0.1
    add_child(newSplashSprite)
