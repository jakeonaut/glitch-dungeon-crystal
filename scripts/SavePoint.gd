extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var triangleContainer = get_node("TriangleContainer")
onready var myOtherSprite = get_node("TriangleContainer/Sprite3D")
onready var saveSound = get_node("SaveSound")

var MIN_STEP = 1
var MAX_STEP = -4
var step = MIN_STEP
var id = null
var is_active = false

var spawn_timer = 0
var spawn_time_limit = 5

func _ready():
	add_to_group("savepoints")
	id = self.generateId()

	set_process(true)

func _process(delta):
	if isOnSavePoint():
		triangleContainer.rotation_degrees.y -= delta*22*5
		if not is_active:
			enablePaletteCycle()
			spawn_timer = spawn_time_limit
		is_active = true
	else:
		triangleContainer.rotation_degrees.y += delta*22
		if is_active:
			disablePaletteCycle()
		is_active = false

	if is_active:
		spawn_timer += (delta*22)
		if spawn_timer >= spawn_time_limit:
			var children = self.get_children()
			var num_children = 0
			for i in children:
				num_children += 1

			if num_children < 20:
				var newSprite = mySprite.duplicate()
				newSprite.should_fizzle_out = true
				newSprite.visible = true
				newSprite.transform.origin = Vector3(
					stepify(rand_range(-1.0, 1.0), 0.12),
					stepify(rand_range(0.5, 1.5), 0.12),
					0
				)
				newSprite.updateBaseFrame(0, 0)
				newSprite.max_frames = 2
				add_child(newSprite)
				spawn_timer = 0

func isOnSavePoint():
	if not global.memory.has("active_save_point_x"):
		return false

	var origin = self.global_transform.origin
	var x = origin.x
	var y = origin.y
	var z = origin.z
	return int(round(x)) == int(round(global.memory["active_save_point_x"])) and \
			int(round(y)) == int(round(global.memory["active_save_point_y"])) and \
			int(round(z)) == int(round(global.memory["active_save_point_z"]))

func enablePaletteCycle():
	setPaletteCycle(myOtherSprite, true)

func disablePaletteCycle():
	setPaletteCycle(myOtherSprite, false)

func setPaletteCycle(sprite, value):
	var my_material = sprite.get_material_override()
	if my_material is ShaderMaterial:
		var new_material = my_material.duplicate()
		new_material.set_shader_param("enable_palette_cycle", value)
		sprite.set_material_override(new_material)

func generateId():
	return get_tree().get_root().get_node("Game/Viewport/level").getLevelName() + ":" + get_name()

func passiveActivate(delta):
	if not isOnSavePoint():
		saveSound.play()
		global.memory["active_save_point_x"] = self.translation.x
		global.memory["active_save_point_y"] = self.translation.y
		global.memory["active_save_point_z"] = self.translation.z
		global.memory["roomPath"] = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
		global.saveGame()

func isActive():
	return true
