extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    global.pauseGame = false
    global.pauseMoveInput = false
    level.player.aniPlayer.play("stand")
    if not global.memory.has("spellbookPage"):
      level.player.textBox.text_final = "i need a spellbook first"
      level.player.textBox.tinify()
      level.player.textBox.interact()
      return
      
    # TODO(jaketrower): check you don't already have it
    global.memory["spellbookPage"].push_back(global.GlitchForm.FLOOR)
    var page = get_node("../../..")
    page.queue_free()
    

func isActive():
    return true
