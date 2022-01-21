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
        # TODO(jaketrower): give UILayer.gd a function
        level.uiLayer.get_node("EquipmentRect").visible = true
        level.uiLayer.get_node("EquipmentStatusRect").visible = true

    # IFNDEF SpellbookIntroLevelScript.gd
    level.get_node("NPC5").textBox.text_final = "use [Z] to cast\ncollected spells!"
    
    level.get_node("NPC").textBox.text_final = "wow you got it......i bet all\nkinds of new paths will open up\nfor you now in swamp home......\ni could never cast spells\nlike you can... i'm just\na lowly frog wizard."
        
    level.restartMusic()
    level.saveTheGame()

func isActive():
    return true
