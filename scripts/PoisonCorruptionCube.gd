extends Spatial

export var mushroom_walk_direction = 1
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var mySprite = get_node("Sprite3D")

func _ready():
    mySprite.material_override = mySprite.material_override.duplicate()
    var hframe = randi() % mySprite.hframes
    var vframe = randi() % mySprite.vframes
    mySprite.updateBaseFrame(hframe, vframe)

    if mushroom_walk_direction == -1:
        mySprite.material_override.set_shader_param("target_palette", global.base_palette_pink)

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
        level.player.loseBroom()
        level.player.mushroom_infection_direction = mushroom_walk_direction
        # level.player.grav = 0
        # level.player.vv = 3
