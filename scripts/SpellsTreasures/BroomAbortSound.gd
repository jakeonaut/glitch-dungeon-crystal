extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var broom = get_node("../../..")
    broom.visible = false
    broom.is_active = false
    broom.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    if not global.memory.has("broom"):
        global.memory["broom"] = true

    # IFNDEF SpriteTownLevelScript.gd
    level.get_node("NPC").textBox.text_final = "oh cool! now we can clean together\n... well i don't have a broom..\n\nanyway, to sweep, just stand in front\nof a glitch and press [C]"
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
