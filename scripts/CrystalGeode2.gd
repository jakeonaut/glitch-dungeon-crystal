extends Spatial

var has_been_smacked = false
var rot_amount = 100
var rot_amount_max = 200
onready var cubeContainer = get_node("CubeContainer")
onready var aniPlayer = get_node("AnimationPlayer")
onready var npc = get_node("NPC")
onready var getHitSound = get_node("GetHitSound")
onready var getHitSound2 = get_node("GetHitSound2")
onready var notGetHitSound = get_node("NotGetHitSound")
var can_do_my_power = true
# String is a path to a file.
export(String, FILE) var path

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    set_process(true)
    if global.hasGottenLevelGeode:
        aniPlayer.play("quick_explode")
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        stopAnimation()
        alwaysActivateStuff()

var tadpole_spin_start_timer = 0
var tadpole_spin_start_time_limit = 10
var tadpoles = []
var num_tadpoles = 0
var tadpole_index = 0
func _process(delta):
    if not can_do_my_power:
        return

    if global.hasLevelGeodeBeenSmacked and not global.hasGottenLevelGeode:
        npc.rotation_degrees.y -= (delta * rot_amount)
        rot_amount += (delta * 33)
        if rot_amount >= rot_amount_max:
            global.hasGottenLevelGeode = true
            aniPlayer.play("explode")
    elif global.hasGottenLevelGeode and level.player.pauseSelf:
        opacity = opacity + (0.0 - opacity) * (delta * 1)
        npc.mySprite.material_override.set_shader_param("opacity", opacity)

        var pos = npc.global_transform.origin
        var playerPos = level.player.global_transform.origin
        level.player.global_transform.origin = global.moveToward2D(playerPos, pos, delta * 1)
        if global.compare2D(level.player.global_transform.origin, pos, 0.1):
            level.gameCamera.zoomed_size = level.gameCamera.initial_size - 4
            level.gameCamera.am_i_zooming = true
        level.player.ladderUpdateTargetLastGroundedY()
        level.player.on_ground = false
        if rot_amount > 50:
            rot_amount -= (delta * 55)
            npc.rotation_degrees.y -= (delta * rot_amount)
            self.global_transform.origin.y += (delta * 1)
        else:
            pass

    if global.hasLevelGeodeBeenSmacked or global.hasGottenLevelGeode:
        spinTheFroggies(delta)

var opacity = 0.8
var stop_animation_timer = 0
var stop_animation_time_limit = 20
func spinTheFroggies(delta):
    # TODO(jaketrower): move player to center of geode, fade out background, 
    # the tadpoles stop bouncing and rotate in 3d around the player,
    # and pop one by one into NPCs, start chanting and you all speed upward and teleport back
    # to hub world...
    if tadpole_index < num_tadpoles:
        tadpole_spin_start_timer += (delta*11)
        if tadpole_spin_start_timer >= tadpole_spin_start_time_limit:
            tadpole_spin_start_timer = 0
            var tadpole = tadpoles[tadpole_index]
            tadpole.startSpinning(tadpole_index, num_tadpoles)
            tadpole_index += 1
    else:
        var should_stop_animation = true
        for tadpole in tadpoles:
            if not tadpole.is_evolved:
                should_stop_animation = false
        if should_stop_animation:
            stop_animation_timer += (delta*11)
            if stop_animation_timer >= stop_animation_time_limit:
                stopAnimation()
                transition.long_fade_to(self.path)

func stopAnimation():
    npc.is_active = false
    npc.visible = false
    npc.can_activate = false

    can_do_my_power = false
    global.hasLevelGeodeBeenSmacked = false
    # level.levelTiles.randomize_num = 1
    # level.levelTiles.randomize_num_counter = 0
    # level.player.pauseSelf = false
    # level.restartMusic()
    # level.gameCamera.am_i_zooming = false



func isActive():
    return visible and not has_been_smacked and not global.hasGottenLevelGeode

func activate(is_player):
    if not is_player:
        if not notGetHitSound.is_playing(): notGetHitSound.play()
        return

    level.levelTiles.randomize_num += 10
    level.levelTiles.randomize_num_counter = 15
    has_been_smacked = true
    level.show_crt_effect = true
    global.hasLevelGeodeBeenSmacked = true
    level.player.pauseSelf = true
    # musicPlayer.stopAll()
    musicPlayer.changeSongPitch(0.5)
    getHitSound.play()
    getHitSound2.play()

    level.get_node("SavePoint").passiveActivate(0, is_player)
    otherActivateStuff()
    alwaysActivateStuff()

func otherActivateStuff():
    tadpole_spin_start_timer = tadpole_spin_start_time_limit
    tadpoles = level.get_tree().get_nodes_in_group("tadpoles")
    num_tadpoles = len(tadpoles)
    
    if level.has_node("ParallaxBackground"):
        level.get_node("ParallaxBackground").hideMe()

func alwaysActivateStuff():
    musicPlayer.tryToPlay(musicPlayer.goddessThemePlayer)
    # TODO(jaketrower): Make more generic, this is specific to fishingVillage
    if level.has_node("NPC"):
        level.get_node("NPC").queue_free()
