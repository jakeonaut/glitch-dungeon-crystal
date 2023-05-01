extends "Spawner.gd"


onready var mySprite = get_node("Sprite3D")
var has_spawned = false

func _ready():
    mySprite.visible = false

func _process(_delta):
    is_active = global.hasGottenLevelGeode and not has_spawned

# @override
func getNumChildren():
    if has_spawned:
        return max_num_children
    return self.get_children().size() - 2 # to account for the PlayerInteractionArea and Sprite

# @override
func spawn():
    if has_spawned:
        return
    .spawn() # super()
    has_spawned = true