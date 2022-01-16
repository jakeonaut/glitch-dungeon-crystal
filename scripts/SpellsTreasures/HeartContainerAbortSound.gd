extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var treasure = get_node("../../..")
    treasure.visible = false
    treasure.is_active = false
    treasure.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    if not global.memory.has("total_hearts"):
        global.memory["total_hearts"] = 1
        
    global.memory["total_hearts"] += 1
    global.memory["hearts_recovering"] = true
    level.get_node("UILayer").recreateHeartSprites()
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
