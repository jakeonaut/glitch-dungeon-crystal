extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func isActive():
    return true

func passiveActivate(_delta, is_player):
    if is_player and not level.player.is_mushroom_infected:
        level.player.is_mushroom_infected = true
        
        level.player.gravitySound.play()
        if level.player.transformation == level.player.TransformationState.FISHY:
            level.player.getFishyCured()
        if level.player.transformation == level.player.TransformationState.CHICKEN:
            level.player.getChickenCured()
        # level.player.loseBroom()
        # level.player.grav = 0
        # level.player.vv = 3
