extends Spatial

# String is a path to a file.
export(String, FILE) var spawned_object_path
var spawned_object_res = null
var spawned_object_instance = null
var spawn_timer = 0
export var spawn_time_limit = 5
export var max_num_children = 10
export var x_range = Vector2(-5, 5)
export var y_range = Vector2(0, 0)
export var is_active = true
export var should_shake_screen = false

var am_i_in_range_of_player = false
var am_i_really_in_range_of_player = false
export var only_activate_in_range = true
var should_staticify_children = false  # this breaks dynamically created SmallKeys

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var mySprite = get_node("Sprite3D") if has_node("Sprite3D") else null

func _ready():
    set_process(true)
    for child in self.get_foreign_children():
        # print(child)
        child.visible = false
    if spawned_object_path.length() != 0:
        spawned_object_res = load(spawned_object_path)
    spawn_timer = spawn_time_limit if spawn_time_limit != null else 0
    

export var num_native_children = 1
func get_foreign_children():
  var spawned_object_child_addition = 0
  if spawned_object_instance:
    spawned_object_child_addition = 1
  return fakeSlice(self.get_children(), num_native_children, self.get_child_count() - spawned_object_child_addition)

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    processSpawningLogic(delta)

func processSpawningLogic(delta):
    am_i_in_range_of_player = am_i_really_in_range_of_player or (not only_activate_in_range)
    am_i_really_in_range_of_player = false
    
    if not am_i_in_range_of_player or not is_active:
        return

    var num_children = getNumForeignChildren()

    if num_children < max_num_children:
        spawn_timer += (delta*22)
        if spawn_timer >= spawn_time_limit:
            spawn()
            spawn_timer = 0
    else:
        spawn_timer = 0

func getNumForeignChildren():
    var count = 0
    for child in self.get_foreign_children():
        if child.visible:
            count += 1
    return count

func spawnEffect(_child):
    if should_shake_screen:
        level.gameCamera.miniShakeScreen()
        
func spawn(_with_flare = true):
    for child in self.get_foreign_children():
        child.visible = true
        spawnEffect(child)
    if spawned_object_res == null:
        return

    var newObject = spawned_object_res.instance()
    newObject.transform.origin = Vector3(
        stepify(rand_range(x_range.x, x_range.y), 0.125),
        stepify(rand_range(y_range.x, y_range.y), 0.125),
        0
    )
    newObject.name = self.name + "/" + newObject.name
    if "is_static_in_level" in newObject:
        newObject.is_static_in_level = should_staticify_children # this breaks dynamically created SmallKeys
        # newObject.is_static_in_level = false
    add_child(newObject)
    spawnEffect(newObject)
    if newObject.has_method("setAsParent"):
        newObject.setAsParent(self)
    spawned_object_instance = newObject

            
func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true

func myChildDied():
    pass


# https://github.com/godotengine/godot/issues/53495
func fakeSlice(array: Array, start = null, end = null, step = null):
    var stop = array.size()
    var sliced = []
    if step == null:
        step = 1
    if start == null:
        return array
    if start < 0:
        start = start + array.size()
    if end != null:
        if end >= 0:
            stop = end
        else:
            stop = array.size() + end
    for i in range(start, stop, step):
        sliced.push_back(array[i])
    return sliced

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles
func glitchTilesAroundMe(margin = 0.25, rand_timer = false):
  var lt = getLevelTiles()
  if not lt:
    return
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var tb = y + 4 + margin
  var bb = y - 4 - margin
  var lb = x - 4 - margin
  var rb = x + 4 + margin
  
  lt.clearRandomTileTimers()
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      lt.rerandomizeTile(coords, lt.getRandomGlitchType(), rand_timer)
