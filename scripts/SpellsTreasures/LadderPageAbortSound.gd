extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

onready var page = get_node("../../..")
func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.play("stand")
    if not global.memory.has("spellbookPage"):
      level.player.sayThis("•i need a spellbook first")
      return
      
    # TODO(jaketrower): check you don't already have it
    global.memory["spellbookPage"].push_front(global.GlitchForm.LADDER)
    page.queue_free()
    

func isActive():
    return true
