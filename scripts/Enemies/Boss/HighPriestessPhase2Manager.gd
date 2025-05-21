extends Spatial

onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var anglerFishBoss = get_node("AnglerFishBoss")
onready var babaYagaBoss = get_node("BabaYagaBoss")
onready var claydolBoss = get_node("ClaydolBoss")

enum Phase2Phase {
    GLITCH_ROULETTE,
    ANGLER_FISH,
    BABA_YAGA,
    DOGU_CLAYDOL,
    HURT,
    DYING
}
var phase = Phase2Phase.GLITCH_ROULETTE
var glitch_roulette_index = 0
var glitch_roulette_timer = 0
var glitch_roulette_time_limit = 5

func _ready():
    set_process(true)
    highPriestessBoss.boss_phase = highPriestessBoss.BossPhase.NULL
    anglerFishBoss.boss_phase = anglerFishBoss.BossPhase.NULL
    babaYagaBoss.boss_phase = babaYagaBoss.BossPhase.NULL
    claydolBoss.boss_phase = claydolBoss.BossPhase.NULL

func _process(delta):
    if phase == Phase2Phase.GLITCH_ROULETTE:
        glitch_roulette_timer += (delta*11)
        if glitch_roulette_timer >= glitch_roulette_time_limit:
            highPriestessBoss.attackSound.play()
            glitch_roulette_timer = 0
            glitch_roulette_index += 1
            if glitch_roulette_index > 3:
                glitch_roulette_index = 0
            highPriestessBoss.visible = glitch_roulette_index == 0
            anglerFishBoss.visible = glitch_roulette_index == 1
            claydolBoss.visible = glitch_roulette_index == 2
            babaYagaBoss.visible = glitch_roulette_index == 3
