extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var egg = get_node("../../..")
    global.pauseGame = false
    global.pauseMoveInput = false
    level.saveTheGame("got an angel!")
    level.spawnAngelTadpole(egg.global_transform.origin)
    global.incrementLevelZoneThing("angelTadpole", 1)
    global.activeInteractor = null
    egg.queue_free()
    level.player.aniPlayer.play("stand")

func isActive():
    return true
