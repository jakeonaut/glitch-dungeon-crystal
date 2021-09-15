extends KinematicBody

onready var transformSound = get_node("TransformSound")
var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("level").player
    return player

func isActive():
    return visible

func passiveActivate(delta):
    transformSound.play()
    visible = false

    getPlayer().ladderGlitch()
