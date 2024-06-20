extends Spatial

onready var cubeSound = get_node("cubeSound")
onready var cubeSound2 = get_node("cubeSound2")
onready var cubeSound3 = get_node("cubeSound3")
onready var aniPlayer = get_node("AnimationPlayer")

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
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self):
        queue_free()
        
    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier

    if is_visible():
        if disappearing2:
            step = MID_STEP
            translate(Vector3(0, 0.5*delta, 0))
            disappearTimer += (delta*22)
            if aniPlayer.assigned_animation == "floatAway" and not aniPlayer.is_playing() and \
               not cubeSound.is_playing() and not cubeSound2.is_playing():
                queue_free()
        else:
            step = rand_range(MIN_STEP-1, MIN_STEP+1) / 4

func isActive(_debug=false):
    return is_visible() and not disappearing2

func passiveActivate(_delta, _is_player):
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
            global.setStaticLevelZoneLevelVar(level, self, true)

    # global.pauseGame = true
    # global.pauseMoveInput = true
    # player.global_transform.origin = self.global_transform.origin
