extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var treasure = get_node("../../..")
func activateScript():
    treasure.visible = false
    treasure.is_active = false
    treasure.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    if not global.memory.has("max_hp"):
        global.memory["max_hp"] = 1
        
    global.memory["max_hp"] += 1
    global.memory["hearts_recovering"] = true
    level.get_node("UILayer").recreateHeartSprites()
        
    level.saveTheGame()

func isActive():
    return true
