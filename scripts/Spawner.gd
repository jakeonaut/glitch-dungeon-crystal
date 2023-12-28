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
export var only_activate_in_range = true
var should_staticify_children = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    set_process(true)
    if spawned_object_path.length() != 0:
        spawned_object_res = load(spawned_object_path)
    spawn_timer = spawn_time_limit if spawn_time_limit != null else 0
    yield(get_tree().create_timer(0.1), "timeout")
    for child in self.get_foreign_children():
        child.visible = false

export var num_native_children = 1
func get_foreign_children():
  return self.get_children().slice(num_native_children, self.get_child_count())

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    am_i_in_range_of_player = am_i_really_in_range_of_player or (not only_activate_in_range)
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
    var count = 0
    for child in self.get_foreign_children():
        if child.visible:
            count += 1
    return count

func spawnEffect(_child):
    pass
        
func spawn(_with_flare = true):
    for child in self.get_foreign_children():
        child.visible = true
        spawnEffect(child)
    if spawned_object_res == null: return

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
        newObject.is_static_in_level = should_staticify_children

            
func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true

func myChildDied():
    pass
