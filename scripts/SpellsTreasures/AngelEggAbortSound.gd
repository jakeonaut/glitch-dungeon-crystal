extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var egg = get_node("../../..")
func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.pauseInput = false
    # var tadpole = level.spawnAngelTadpole(egg.global_transform.origin)
    # tadpole.get_node("Sounds/HatchSound").play()
    # global.incrementLevelZoneThing("angelTadpole", 1)
    global.incrementLevelZoneThing("angelEgg", 1)
    # level.spawnAngelEggFollower(level.player.global_transform.origin)
    global.activeInteractor = null
    egg.queue_free()
    level.player.aniPlayer.play("stand")
    level.player.giveMeMiniCrystalCubes(3)
    # level.player.sayThis("what the hell is this?", 3.0)
    if global.demo_mode <= 0:
        Steam.set_achievement("ANGEL_EGG_FIRST")
        var numAngelEggs = global.getThingFromAllLevelZonez("angelEgg")
        if numAngelEggs >= 28:
            Steam.set_achievement("ANGEL_EGG_ALL")
        else:
            Steam.user_stats.indicate_achievement_progress("ANGEL_EGG_ALL", numAngelEggs, 28)

func isActive(_debug=false):
    return true
