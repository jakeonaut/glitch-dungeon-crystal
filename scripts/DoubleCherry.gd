extends "res://scripts/GameMover.gd"

onready var crunchSound = get_node("CrunchSound")
onready var fullSound = get_node("FullSound")
var can_play_full_sound = true
var which_cherry_was_i = 0
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
var am_i_in_range_of_player = true
var am_i_really_in_range_of_player = true
var away_from_player_timer = 0
var away_from_player_time_limit = 15

var can_fall = true
var is_active = true

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    should_collide_ceil = false
    should_collide_horizontally = false
    should_only_do_middle_sensor = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("growBack")
    mySprite.should_animate = false
    true_terminal_vel = 0

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    if secretAniPlayer.assigned_animation == "eaten" and not secretAniPlayer.is_playing() and not crunchSound.is_playing():
        queue_free()
    
    am_i_in_range_of_player = am_i_really_in_range_of_player
    am_i_really_in_range_of_player = false
    
    if global.num_cherries_eaten >= global.max_cherries and \
       secretAniPlayer.assigned_animation != "shrivel" and secretAniPlayer.assigned_animation != "eaten":
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("shrivel")
        
    if not am_i_in_range_of_player:
        away_from_player_timer += (delta * 22)
        if away_from_player_timer >= away_from_player_time_limit:
            queue_free()
    else:
        away_from_player_timer = 0
    
    if secretAniPlayer.assigned_animation == "growBack" and not secretAniPlayer.is_playing() and can_fall and not on_ground:
        true_terminal_vel = 32
        mySprite.should_animate = false
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("fall")
    elif secretAniPlayer.assigned_animation == "growBack" and not secretAniPlayer.is_playing():
        mySprite.should_animate = true
        
    if secretAniPlayer.assigned_animation == "land" and not secretAniPlayer.is_playing():
        mySprite.should_animate = true
        
    if secretAniPlayer.assigned_animation == "shrivel":
        if not secretAniPlayer.is_playing():
            queue_free()
        
                
func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true
        
# @override
func processPhysics(delta):
    if not am_i_in_range_of_player or not can_fall:
        return
    else:
        # call GameMover.gd super method
        .processPhysics(delta)
        
# @override
func landed():
    .landed()

    if secretAniPlayer.assigned_animation != "eaten" and secretAniPlayer.assigned_animation != "shrivel":
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("land")

func passiveActivate(delta):
    if global.num_cherries_eaten < global.max_cherries:
        true_terminal_vel = 0
        is_active = false
        which_cherry_was_i = global.num_cherries_eaten
        mySprite.should_animate = false
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("eaten")
        global.num_cherries_eaten += 1
        crunchSound.play()
    else:
        if can_play_full_sound:
            fullSound.play()
            can_play_full_sound = false
            
func stopPassiveActivate():
    can_play_full_sound = true

func isActive():
    return is_active
