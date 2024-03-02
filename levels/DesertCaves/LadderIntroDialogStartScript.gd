extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    print(level.has_node("GlitchSlime4"))
    if not level.has_node("GlitchSlime4") or \
       level.levelTiles.get_cell_item(22, -11, 0) == GridMap.INVALID_CELL_ITEM or \
       level.levelTiles.get_cell_item(31, -11, 0) == GridMap.INVALID_CELL_ITEM:
        print("HWAUH?")
        get_node("../../..").textBox.text_final = "•hey.. why did you do that\n•we love glitch baths.."
        get_node("../../..").textBox.has_been_shown = false
    
func preActivateScript():
    # OVERRIDE ME
    pass

func isActive(debug=false):
    # OVERRIDE ME... if you dare
    return true