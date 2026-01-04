extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var activateSound = get_node("ActivateSound")
onready var mySprite = get_node("Sprite3D")
onready var birdSprite = get_node("BirdSprite")
onready var musicNoteSprite = get_node("MusicNoteSprite")
onready var tweetSound = get_node("TweetSound")
var hasRandomizedTweet = false
var is_angel_activated = false
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("NPC") if has_node("NPC") else null
export(String, "gd1TutorialDungeon", "gd1FishingVillage", "gd1ToxicJungle", "gd1ShiftingSandLand", "gd1CrystalTower", "gd1GrandmaVillage", "gd1BubblegloopSwamp", "gd1TombSouls", "gd1AbstractSuburbs", "gd1PrimordialOoze") var levelZone 

func _ready():
    set_process(true)
    mySprite.material_override = mySprite.material_override.duplicate()
    birdSprite.material_override = birdSprite.material_override.duplicate()
    musicNoteSprite.material_override = musicNoteSprite.material_override.duplicate()

    yield(get_tree().create_timer(0.5), "timeout")
    for rememberedLevelZone in global.memory["level_zonez"]:
        print(rememberedLevelZone)
        if levelZone == rememberedLevelZone and global.memory.has(rememberedLevelZone) and global.memory[rememberedLevelZone].has("angel_statue"):
            is_angel_activated = true
            aniPlayer.stop()
            aniPlayer.clear_queue()
            aniPlayer.play("ActivatedIdle")
            break
    if not is_angel_activated:
        mySprite.material_override.set_shader_param("target_palette", global.grey_palette)
        mySprite.material_override.set_shader_param("opacity", 0.5)
    
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
    return false

func passiveActivate(_delta, _is_player, _is_local_broom = false):
    pass

func stopPassiveActivate():
    pass
