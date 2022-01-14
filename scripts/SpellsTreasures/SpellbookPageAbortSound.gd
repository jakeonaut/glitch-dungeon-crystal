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
        # TODO(jaketrower): you have to know how stupid this is right?
        level.get_node("UILayer/EquipmentRect").visible = true
        level.get_node("UILayer/EquipmentStatusRect").visible = true

    # IFNDEF SpriteTownLevelScript.gd
    # level.get_node("NPC").textBox.text_final = "well, that might not\nactually explain anything huh......\n..\nthese SPRITES here\nsay that CRYSTAL ELDERS\nknow much more\nif you explore more of\nthe dungeon you can\nfind them i think\nbut i'm too scared.."
    level.get_node("NPC5").textBox.text_final = "use [Z] to cast\ncollected spells!"
    level.get_node("NPC5").textBox.has_been_shown = false
        
    level.restartMusic()

func isActive():
    return true
