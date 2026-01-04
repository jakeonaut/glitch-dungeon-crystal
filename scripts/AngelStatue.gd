extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var activateSound = get_node("ActivateSound")
onready var mySprite = get_node("Sprite3D")
onready var birdSprite = get_node("BirdSprite")
onready var musicNoteSprite = get_node("MusicNoteSprite")
onready var tweetSound = get_node("TweetSound")
onready var savePoint = get_node("SavePoint")
var hasRandomizedTweet = false
var is_angel_activated = false
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("NPC") if has_node("NPC") else null

func _ready():
    set_process(true)
    birdSprite.material_override = birdSprite.material_override.duplicate()
    musicNoteSprite.material_override = musicNoteSprite.material_override.duplicate()
    mySprite.material_override = mySprite.material_override.duplicate()

    # if global.getLevelZoneThing("angel_statue") != null:
    #     is_angel_activated = true
    #     aniPlayer.stop()
    #     aniPlayer.clear_queue()
    #     aniPlayer.play("ActivatedIdle")
    
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


func isActive(_debug=false):
    return false # self.visible

func passiveActivate(_delta, _is_player, _is_local_broom = false):
    pass
    # if not is_angel_activated:
    #     global.setLevelZoneThing("angel_statue", [
    #         global.getDisplayTitle(level.getLevelZoneName(), level.getLevelName()),
    #         level.getLevelName()
    #     ])
    #     is_angel_activated = true
    #     activateSound.play()
    #     aniPlayer.stop()
    #     aniPlayer.clear_queue()
    #     aniPlayer.queue("BirdFlyIn")
    #     aniPlayer.queue("ActivatedIdle")
    #     var my_material = mySprite.get_material_override()
    #     if my_material is ShaderMaterial:
    #         my_material.set_shader_param("enable_palette_cycle", true)
    # savePoint.passiveActivate(delta, is_player)
    

func stopPassiveActivate():
    pass
