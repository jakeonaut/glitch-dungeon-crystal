extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func isActive():
    return true

func passiveActivate(_delta, is_player):
    if is_player:
        level.player.is_mushroom_infected = true
        level.player.loseBroom()
        # level.player.grav = 0
        # level.player.vv = 3
