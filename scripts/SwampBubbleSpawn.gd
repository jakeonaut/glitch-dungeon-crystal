extends Spatial

# String is a path to a file.
export(String, FILE) var spawned_object_path
var spawned_object_res = null
var has_spawned = false
onready var bubbleSpawner = get_node("BubbleSpawner")

func _ready():
    set_process(true)
    spawned_object_res = load(spawned_object_path)

func _process(_delta):
    pass

func passiveActivate(_delta):
    if not has_spawned:
        spawn()

func isActive():
    return true

func spawn():
    bubbleSpawner.is_active = false
    has_spawned = true
    var newObject = spawned_object_res.instance()
    add_child(newObject)
    if newObject.has_method("setAsParent"):
        newObject.setAsParent(self)
