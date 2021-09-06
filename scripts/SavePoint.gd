extends Spatial

onready var meshInstance = get_node("MeshInstance")
onready var saveSound = get_node("SaveSound")

var active_save_point_shader = preload("res://shaders/SavePointActive.shader")
var inactive_save_point_shader = preload("res://shaders/SavePoint.shader") 

var MIN_STEP = 1
var MAX_STEP = -4
var step = MIN_STEP
var id = null
var is_active = false

func _ready():
    add_to_group("savepoints")
    id = self.generateId()

    set_process(true)

func _process(delta):
    if global.memory.has("active_save_point") and global.memory["active_save_point"] == self.id:
        step = MAX_STEP
        if not is_active:
            var material = meshInstance.get_surface_material(0).duplicate(true)
            material.set_shader(active_save_point_shader) 
            meshInstance.set_surface_material(0, material)
        is_active = true
    else:
        step = MIN_STEP
        if is_active:
            var material = meshInstance.get_surface_material(0)
            material.set_shader(inactive_save_point_shader)
            meshInstance.set_surface_material(0, material)
        is_active = false
    rotate_y(step*delta)

func generateId():
    return get_tree().get_root().get_node("level").get_filename() + ":" + get_name()

func passiveActivate(delta):
    if not global.memory.has("active_save_point") or global.memory["active_save_point"] != self.id:
        saveSound.play()
        global.memory["active_save_point"] = self.id
        global.memory["active_save_point_x"] = self.translation.x
        global.memory["active_save_point_y"] = self.translation.y
        global.memory["active_save_point_z"] = self.translation.z
        global.memory["roomPath"] = get_tree().get_root().get_node("level").get_filename()
        global.saveGame()

func isActive():
    return true