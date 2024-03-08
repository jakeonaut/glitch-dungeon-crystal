extends Spatial

# String is a path to a file.
export(String, FILE) var spawned_object_path
var spawned_object_res = null
export var has_spawned = false
onready var bubbleSpawner = get_node("BubbleSpawner")

func _ready():
    set_process(true)
    spawned_object_res = load(spawned_object_path)

func _process(_delta):
    pass

func passiveActivate(_delta, _is_player):
    if not has_spawned:
        spawn()

func isActive(_debug=false):
    return true

func spawn():
    bubbleSpawner.is_active = false
    has_spawned = true
    get_node("Sprite3D").visible = false
    var newObject = spawned_object_res.instance()
    add_child(newObject)
    if newObject.has_method("setAsParent"):
        newObject.setAsParent(self)
