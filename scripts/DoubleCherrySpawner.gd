extends "res://scripts/Spawner.gd"

export var can_cherry_fall = true
export var is_infinite = false
var spawned_children = 0
var spawned_children_cherry_nums = []

func _ready():
    set_process(true)
    
func _process(_delta):
    # ._process() is implicit

    if spawned_children < 0: spawned_children = 0
    if spawned_children > max_num_children: spawned_children = max_num_children
        
    for i in range(spawned_children_cherry_nums.size()-1, -1, -1):
        var cherry_num = spawned_children_cherry_nums[i]
        if global.num_cherries_eaten < cherry_num:
            decrementSpawnedChildren()
            spawned_children_cherry_nums.pop_back()
    
func spawn(_with_flare = true):
    var num_children = self.get_children().size() - 1 # to account for the PlayerInteractionArea
    if spawned_children < max_num_children and num_children < max_num_children:
        .spawn()
        spawned_children += 1
        var newObject = get_child(get_child_count() - 1)
        newObject.can_fall = can_cherry_fall
        
func decrementSpawnedChildren():
    spawned_children -= 1
    spawn_timer = -spawn_time_limit
    
func spawnedChildWasEaten(which_cherry_was_it):
    spawned_children_cherry_nums.append(which_cherry_was_it)
