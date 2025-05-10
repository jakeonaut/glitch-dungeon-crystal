extends Spatial

onready var highPriestessBoss = get_node("HighPriestessBoss")
onready var anglerFishBoss = get_node("AnglerFishBoss")
onready var claydolBoss = get_node("ClaydolBoss")
onready var babaYagaBoss = get_node("BabaYagaBoss")

enum Phase2Phase {
    GLITCH_ROULETTE,
    BABA_YAGA,
    ANGLER_FISH,
    DOGU_CLAYDOL,
    HURT,
    DYING
}
var phase = Phase2Phase.GLITCH_ROULETTE

func _ready():
    set_process(true)

func _process(_delta):
    pass
