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
    level.get_node("NPC").textBox.text_final = "you found the broom! now you\ncan help me clean my house...\ni have a great reward buried somewhere under the dust!\nplease, come in."
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
