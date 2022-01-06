extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var spellbookPage = get_node("../../..")
    spellbookPage.visible = false
    spellbookPage.is_active = false
    spellbookPage.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    if not global.memory.has("spellbookPage"):
        global.memory["spellbookPage"] = []
        
    level.restartMusic()

func isActive():
    return true