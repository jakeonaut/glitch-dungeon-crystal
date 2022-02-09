extends "res://scripts/Spawner.gd"

export var can_cherry_fall = true

func _ready():
    set_process(true)
    
func spawn():
    if global.num_cherries_eaten < global.max_cherries:
        .spawn()
        var newObject = get_child(get_child_count() - 1)
        newObject.can_fall = can_cherry_fall