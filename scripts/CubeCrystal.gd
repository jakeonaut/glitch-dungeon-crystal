extends Spatial

onready var cubeContainer = get_node("CubeContainer")
onready var cubeSound = get_node("cubeSound")
onready var cubeSound2 = get_node("cubeSound2")
onready var cubeSound3 = get_node("cubeSound3")
onready var aniPlayer = get_node("AnimationPlayer")

onready var meshInstance2 = get_node("CubeContainer/MeshInstance2")
onready var mySprite = get_node("Sprite3D")

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true

export var MIN_STEP = -2
var MID_STEP = 5
export var MAX_STEP = -12
var step = MIN_STEP

var disappearing2 = false
var disappearTimer = 0

func _ready():
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    if is_static_in_level and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name):
        queue_free()
        
    set_process(true)

    var rand_init_step = rand_range(-90, -2)
    cubeContainer.rotate_y(rand_init_step)
    cubeContainer.rotate_x((rand_init_step/2))

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier

    if is_visible():
        if disappearing2:
            step = MID_STEP
            translate(Vector3(0, 0.5*delta, 0))
            disappearTimer += (delta*22)
            cubeContainer.rotate_y(disappearTimer*delta)
            cubeContainer.rotate_x((disappearTimer/2)*delta)
            if aniPlayer.assigned_animation == "floatAway" and not aniPlayer.is_playing() and \
               not cubeSound.is_playing() and not cubeSound2.is_playing():
                queue_free()
        else:
            step = rand_range(MIN_STEP-1, MIN_STEP+1)
        cubeContainer.rotate_y(step*delta)
        cubeContainer.rotate_x((step/2)*delta)

func isActive():
    return is_visible() and not disappearing2

func passiveActivate(_delta):
    # musicPlayer.stopAll()
    if not disappearing2:
        cubeSound.play()
        cubeSound2.pitch_scale = global.mini_cube_crystal_pitch
        global.mini_cube_crystal_pitch_timer = 0
        global.mini_cube_crystal_pitch += 0.1
        cubeSound2.play()
        aniPlayer.play("floatAway")
        level.player.giveMeMiniCrystalCubes(15)

        disappearing2 = true
        
        if is_static_in_level:
            if not global.memory.has(level.getShortLevelName()):
                global.memory[level.getShortLevelName()] = {}
            global.memory[level.getShortLevelName()][self.name] = true

    # global.pauseGame = true
    # global.pauseMoveInput = true
    # player.global_transform.origin = self.global_transform.origin
