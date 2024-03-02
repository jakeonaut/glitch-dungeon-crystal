extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var fishingRod = get_node("../../..")
func activateScript():
    fishingRod.visible = false
    fishingRod.is_active = false
    fishingRod.being_collected = false
    
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("walkStop")
    level.player.aniPlayer.queue("stand")
    
    if not global.memory.has("fishingRod"):
        global.memory["fishingRod"] = true

    # IFNDEF SpriteTownLevelScript.gd
    # level.get_node("NPC").textBox.text_final = "•oh cool! now we can\nfish together... well i\ndon't have a fishing rod\n•anyway, to fish, just stand\nin front of some water and\npress [DOWN]\n•you can find different fish\nin different areas.... \nso i've heard"
        
    level.saveTheGame()

func isActive(debug=false):
    return true
