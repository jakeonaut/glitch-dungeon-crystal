extends Spatial

# String is a path to a file.
export(String, FILE) var spawned_object_path
var spawned_object_res = null
var spawn_timer = 0
export var spawn_time_limit = 5
export var max_num_children = 10
export var x_range = Vector2(-5, 5)
export var y_range = Vector2(0, 0)
export var is_active = true

var am_i_in_range_of_player = false
var am_i_really_in_range_of_player = false

func _ready():
    set_process(true)
    spawned_object_res = load(spawned_object_path)
    spawn_timer = spawn_time_limit

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    am_i_in_range_of_player = am_i_really_in_range_of_player
    am_i_really_in_range_of_player = false
    
    if not am_i_in_range_of_player or not is_active:
        return

    var num_children = getNumChildren()

    if num_children < max_num_children:
        spawn_timer += (delta*22)
        if spawn_timer >= spawn_time_limit:
            spawn()
            spawn_timer = 0
    else:
        spawn_timer = 0

func getNumChildren():
    return self.get_children().size() - 1 # to account for the PlayerInteractionArea
        
func spawn(_with_flare = true):
    var newObject = spawned_object_res.instance()
    newObject.transform.origin = Vector3(
        stepify(rand_range(x_range.x, x_range.y), 0.125),
        stepify(rand_range(y_range.x, y_range.y), 0.125),
        0
    )
    add_child(newObject)
    if newObject.has_method("setAsParent"):
        newObject.setAsParent(self)
    if "is_static_in_level" in newObject:
        newObject.is_static_in_level = false

            
func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true
