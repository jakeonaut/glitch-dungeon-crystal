extends Control

onready var redSpell = get_node("TextureRect/RedSpell")
onready var greenSpell = get_node("TextureRect/GreenSpell")
onready var blackSpell = get_node("TextureRect/BlackSpell")
onready var yellowSpell = get_node("TextureRect/YellowSpell")
onready var whiteSpell = get_node("TextureRect/WhiteSpell")

var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("Game/Viewport/level").player
    return player


func _ready():
    set_process(true)

func _process(delta):
    if getPlayer().glitch_form == global.GlitchForm.FLOOR:
        redSpell.updateBaseFrame(1, 0)
        redSpell.max_frames = 2
    else:
        redSpell.updateBaseFrame(0, 0)
        redSpell.max_frames = 1

    if getPlayer().glitch_form == global.GlitchForm.FEATHER:
        greenSpell.updateBaseFrame(1, 1)
        greenSpell.max_frames = 2
    else:
        greenSpell.updateBaseFrame(0, 1)
        greenSpell.max_frames = 1

    if getPlayer().glitch_form == global.GlitchForm.INVISIBLE:
        blackSpell.updateBaseFrame(1, 2)
        blackSpell.max_frames = 2
    else:
        blackSpell.updateBaseFrame(0, 2)
        blackSpell.max_frames = 1

    if getPlayer().glitch_form == global.GlitchForm.LADDER:
        yellowSpell.updateBaseFrame(1, 3)
        yellowSpell.max_frames = 2
    else:
        yellowSpell.updateBaseFrame(0, 3)
        yellowSpell.max_frames = 1

    if getPlayer().glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
        whiteSpell.updateBaseFrame(1, 4)
        whiteSpell.max_frames = 2
    else:
        whiteSpell.updateBaseFrame(0, 4)
        whiteSpell.max_frames = 1
