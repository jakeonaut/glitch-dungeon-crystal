extends "res://scripts/GameMover.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")

var where_was_i = false

func _ready():
    set_process(true)
    
    mySprite.material_override = mySprite.material_override.duplicate()

    if randi() % 2 == 0:
        secretAniPlayer.queue("startToLeft")
        secretAniPlayer.queue("floatLeft")
        secretAniPlayer.queue("leftToRight")
    else:
        secretAniPlayer.queue("startToRight")
        secretAniPlayer.queue("floatRight")
        secretAniPlayer.queue("rightToLeft")
        
    should_collide_ceil = false
    should_collide_horizontally = false
    should_only_do_middle_sensor = true
    
    
func _process(delta):
    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier
    
    var assani = secretAniPlayer.assigned_animation
    if assani == "leftToRight" and not secretAniPlayer.is_playing():
        secretAniPlayer.clear_queue()
        if randi() % 4 == 0:
            secretAniPlayer.queue("rightToLeft")
            secretAniPlayer.queue("floatLeft")
            secretAniPlayer.queue("leftToRight")
        else:
            secretAniPlayer.queue("floatRight")
            secretAniPlayer.queue("rightToLeft")
        
    if assani == "rightToLeft" and not secretAniPlayer.is_playing():
        secretAniPlayer.clear_queue()
        if randi() % 4 == 0:
            secretAniPlayer.queue("leftToRight")
            secretAniPlayer.queue("floatRight")
            secretAniPlayer.queue("rightToLeft")
        else:
            secretAniPlayer.queue("floatLeft")
            secretAniPlayer.queue("leftToRight")
        
    
    if assani == "leftToRight" or assani == "rightToLeft" or assani == "startToLeft" or assani == "startToRight":
        true_terminal_vel = 2
    if assani == "floatLeft" or assani == "floatRight":
        true_terminal_vel = 2 + sin(secretAniPlayer.current_animation_position) * 2
        
    if assani == "disappear" and not secretAniPlayer.is_playing():
        queue_free()
        
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()

# @override
func landed():
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("disappear")

# @override
func alignMySprite():
    var pixelSize = 0.125
    mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize)
    get_node("CollisionShape").transform.origin.x = mySprite.global_transform.origin.x
