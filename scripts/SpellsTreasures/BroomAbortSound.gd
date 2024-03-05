extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var broom = get_node("../../..")
func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    var aniPlayer = level.player.get_node("AnimationPlayer")
    aniPlayer.clear_queue()
    aniPlayer.queue("walkStop")
    aniPlayer.queue("stand")
    level.player.getABroom()
    level.player.textBox.hideTextbox()
    if not global.memory.has("spellbookPage") and level.getLevelName().find("000PastoralScene") > 0 and level.has_node("PastoralGrannyNPC"):
        level.player.pauseInput = true
        yield(get_tree().create_timer(0.1), "timeout")
        # level.player.textBox.dialogStartSound.play()
        var grannyNPC = level.get_node("PastoralGrannyNPC")
        grannyNPC.global_transform.origin.z = 0
        grannyNPC.activate(true)
        level.player.pauseInput = false
        broom.queue_free()
    else:
        broom.queue_free()

func isActive(debug=false):
    return true
