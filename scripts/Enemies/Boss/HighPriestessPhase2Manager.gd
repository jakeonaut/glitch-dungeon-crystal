extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var anglerFishBoss = get_node("AnglerFishBoss")
onready var babaYagaBoss = get_node("BabaYagaBoss")
onready var claydolBoss = get_node("ClaydolBoss")

var num_granny_hits = 3
var MAX_NUM_HITS = 6
var num_hits = 0

enum Phase2Phase {
    GLITCH_ROULETTE_FAST
    GLITCH_ROULETTE_MEDIUM,
    GLITCH_ROULETTE_SLOW,
    ANGLER_FISH,
    BABA_YAGA,
    DOGU_CLAYDOL,
    HURT,
    DYING
}
var phase = Phase2Phase.GLITCH_ROULETTE_FAST
var glitch_roulette_index = 0
var glitch_roulette_timer = 0
var glitch_roulette_timer_counter = 0
var glitch_roulette_fast_time_limit = 4
var glitch_roulette_medium_time_limit = 6
var glitch_roulette_slow_time_limit = 8

func _ready():
    set_process(true)
    highPriestessBoss.boss_phase = highPriestessBoss.BossPhase.NULL
    highPriestessBoss.is_weird_glitched = true
    anglerFishBoss.boss_phase = anglerFishBoss.BossPhase.NULL
    anglerFishBoss.is_weird_glitched = true
    babaYagaBoss.boss_phase = babaYagaBoss.BossPhase.NULL
    babaYagaBoss.is_weird_glitched = true
    claydolBoss.boss_phase = claydolBoss.BossPhase.NULL
    claydolBoss.is_weird_glitched = true
    num_granny_hits += global.getNumGrannyHearts()

func _process(delta):
    if phase == Phase2Phase.GLITCH_ROULETTE_FAST or phase == Phase2Phase.GLITCH_ROULETTE_MEDIUM or phase == Phase2Phase.GLITCH_ROULETTE_SLOW:
        # level.gameCamera.override_target = self
        var glitch_roulette_time_limit = glitch_roulette_fast_time_limit
        var glitch_roulette_timer_counter_limit = 6
        if phase == Phase2Phase.GLITCH_ROULETTE_MEDIUM:
            glitch_roulette_time_limit = glitch_roulette_medium_time_limit
            glitch_roulette_timer_counter_limit = 3
        elif phase == Phase2Phase.GLITCH_ROULETTE_SLOW:
            glitch_roulette_time_limit = glitch_roulette_slow_time_limit
            glitch_roulette_timer_counter_limit = 1
        glitch_roulette_timer += (delta*11)
        if glitch_roulette_timer >= glitch_roulette_time_limit:
            highPriestessBoss.attackSound.play()
            glitch_roulette_timer = 0
            glitch_roulette_index += 1
            if glitch_roulette_index > 3:
                glitch_roulette_index = 0
            highPriestessBoss.visible = glitch_roulette_index == 0
            anglerFishBoss.global_transform.origin = self.global_transform.origin
            claydolBoss.global_transform.origin = self.global_transform.origin + Vector3(0, -4, 0)
            babaYagaBoss.global_transform.origin = self.global_transform.origin + Vector3(0, -4, 0)
            anglerFishBoss.visible = glitch_roulette_index == 1
            claydolBoss.visible = glitch_roulette_index == 2
            babaYagaBoss.visible = glitch_roulette_index == 3
            glitch_roulette_timer_counter += 1
            if glitch_roulette_timer_counter >= glitch_roulette_timer_counter_limit:
                glitch_roulette_timer_counter = 0
                if phase == Phase2Phase.GLITCH_ROULETTE_FAST:
                    phase = Phase2Phase.GLITCH_ROULETTE_MEDIUM
                elif phase == Phase2Phase.GLITCH_ROULETTE_MEDIUM:
                    phase = Phase2Phase.GLITCH_ROULETTE_SLOW
                elif phase == Phase2Phase.GLITCH_ROULETTE_SLOW:
                    # level.gameCamera.override_target = null
                    if anglerFishBoss.boss_phase != anglerFishBoss.BossPhase.DEFEATED:
                        phase = Phase2Phase.ANGLER_FISH
                        anglerFishBoss.visible = true
                        anglerFishBoss.boss_phase = anglerFishBoss.BossPhase.IDLE
                        highPriestessBoss.visible = false
                        claydolBoss.visible = false
                        babaYagaBoss.visible = false
                    elif claydolBoss.boss_phase != claydolBoss.BossPhase.DEFEATED:
                        phase = Phase2Phase.DOGU_CLAYDOL
                        claydolBoss.visible = true
                        claydolBoss.boss_phase = claydolBoss.BossPhase.IDLE
                        anglerFishBoss.visible = false
                        highPriestessBoss.visible = false
                        babaYagaBoss.visible = false
                    elif babaYagaBoss.boss_phase != babaYagaBoss.BossPhase.DEFEATED:
                        phase = Phase2Phase.BABA_YAGA
                        babaYagaBoss.visible = true
                        babaYagaBoss.boss_phase = babaYagaBoss.BossPhase.IDLE
                        anglerFishBoss.visible = false
                        highPriestessBoss.visible = false
                        claydolBoss.visible = false
    elif phase == Phase2Phase.ANGLER_FISH:
        if anglerFishBoss.boss_phase == anglerFishBoss.BossPhase.DEFEATED:
            phase = Phase2Phase.GLITCH_ROULETTE_FAST
    elif phase == Phase2Phase.DOGU_CLAYDOL:
        if claydolBoss.boss_phase == claydolBoss.BossPhase.DEFEATED:
            phase = Phase2Phase.GLITCH_ROULETTE_FAST
    elif phase == Phase2Phase.BABA_YAGA:
        if babaYagaBoss.boss_phase == babaYagaBoss.BossPhase.DEFEATED:
            phase = Phase2Phase.GLITCH_ROULETTE_FAST

func getHurt():
    if phase == Phase2Phase.ANGLER_FISH:
        anglerFishBoss.getHurt()
    elif phase == Phase2Phase.DOGU_CLAYDOL:
        claydolBoss.getHurt()
    elif phase == Phase2Phase.BABA_YAGA:
        babaYagaBoss.getHurt()

func getMyVariable():
    return 1
