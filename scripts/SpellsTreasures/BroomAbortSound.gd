extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var broom = get_node("../../..")

func _ready():
    pass

func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.pauseInput = false
    var aniPlayer = level.player.get_node("AnimationPlayer")
    aniPlayer.clear_queue()
    aniPlayer.queue("walkStop")
    aniPlayer.queue("stand")
    broom.visible = false
    level.player.getABroom()
    if level.player.truly_on_ground:
        level.player.can_broomerang_warp = true
    level.player.textBox.hideTextbox()
    if not global.memory.has("spellbookPage") and level.getLevelName().find("MainMenu") > 0 and level.has_node("PastoralGrannyNPC"):
        level.player.pauseInput = true
        yield(TempTimer.idle_frame(self), "timeout")
        # level.player.textBox.dialogStartSound.play()
        var grannyNPC = level.get_node("PastoralGrannyNPC")
        grannyNPC.global_transform.origin.z = 0
        grannyNPC.activate(true)
        level.player.pauseInput = false
        broom.queue_free()
    else:
        broom.queue_free()

func isActive(_debug=false):
    return true
