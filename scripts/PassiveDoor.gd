extends Spatial
# String is a path to a file.
export(String, FILE) var path

onready var doorSound = get_node("DoorSound")

func isActive():
    return true

func passiveActivate(delta):
    global.pauseGame = true
    transition.long_fade_to(path)
    if not doorSound.is_playing():
        doorSound.play()
