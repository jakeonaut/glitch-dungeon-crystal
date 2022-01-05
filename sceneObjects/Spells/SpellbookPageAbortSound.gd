extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var spellbookPage = get_node("../../..")
    spellbookPage.visible = false
    spellbookPage.is_active = false
    
    if not global.memory.has("spellbookPage"):
        global.memory["spellbookPage"] = []

func isActive():
    return true