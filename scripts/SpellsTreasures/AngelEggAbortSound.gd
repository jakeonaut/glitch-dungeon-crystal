extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var egg = get_node("../../..")
func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    var tadpole = level.spawnAngelTadpole(egg.global_transform.origin)
    tadpole.get_node("Sounds/HatchSound").play()
    global.incrementLevelZoneThing("angelTadpole", 1)
    global.activeInteractor = null
    egg.queue_free()
    level.player.aniPlayer.play("stand")
    level.player.sayThis("what the hell is this?", 3.0)

func isActive(debug=false):
    return true
