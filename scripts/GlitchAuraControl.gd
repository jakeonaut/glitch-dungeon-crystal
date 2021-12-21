extends Control

onready var target = get_node("../../NPC")
onready var mainColorRect = get_node("ColorRect")

# TODO(jaketrower): Probably best to load this once in the levelScript and reference from there
var green_palette_alt = preload("res://assets/palettes2D/green_palette_alt.png")

var has_set_position = false
var spawn_timer = 0
var spawn_time_limit = 3
var target_origin = Vector3(0, 0, 0)

onready var level = get_tree().get_root().get_node("level")

var levelTiles = null
func getLevelTiles():
	if levelTiles == null:
		levelTiles = level.levelTiles
	return levelTiles
	
var gameCamera = null
func getGameCamera():
	if gameCamera == null:
		gameCamera = level.gameCamera
	return gameCamera

func _ready():
	set_process(true)

func _process(delta):
	setPosition(not has_set_position)
	has_set_position = true

	spawn_timer += (delta*22)
	if spawn_timer >= spawn_time_limit:
		var children = self.get_children()
		var num_children = 0
		for i in children:
			num_children += 1

		if num_children < 20:
			var newRect = mainColorRect.duplicate()
			newRect.minSize = 1
			newRect.rect_size = Vector2(1, 1)
			newRect.maxSize = randi() % 25 + 15
			newRect.should_fizzle_out = true
			newRect.rect_position = Vector2(
				randi() % 150 - 100,
				randi() % 150 - 100
			)
			newRect.glow_dir = newRect.GlowDir.GROWING
			newRect.step = randi() % 30 + 50
			var material = newRect.material.duplicate(true)
			material.set_shader_param("base_palette", green_palette_alt)
			newRect.material = material

			add_child(newRect)
			spawn_timer = 0


func setPosition(should_set_target_origin):
	# https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
	if should_set_target_origin:
		target_origin = target.global_transform.origin
	var target_pos = getGameCamera().unproject_position(target_origin)
	self.rect_position.x = target_pos.x + 10
	self.rect_position.y = target_pos.y + 10
