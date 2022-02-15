extends "res://scripts/Spawner.gd"

export var can_cherry_fall = true

func _ready():
    set_process(true)
    
func spawn():
    var num_children = self.get_children().size() - 1 # to account for the PlayerInteractionArea
    if global.num_cherries_eaten < global.max_cherries and num_children < global.num_cherries_eaten:
        .spawn()
        var newObject = get_child(get_child_count() - 1)
        newObject.can_fall = can_cherry_fall