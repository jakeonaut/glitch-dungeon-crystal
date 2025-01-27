extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC = get_node("../../..")
onready var fungusNPC = get_node("../../../../FungusNPC")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    if not has_done_my_magick:
        level.summonSmokeClouds(fungusNPC.global_transform.origin, 3, true, true)
        yield(get_tree().create_timer(0.5), "timeout")
        fungusNPC.aniPlayer.play("corruptGrowth")
        has_done_my_magick = true

func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive(_debug=false):
    # OVERRIDE ME... if you dare
    return true
