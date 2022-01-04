extends Spatial

var id = null
onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
# String is a path to a file.
export(String, FILE) var path

export var is_passive = false

onready var doorSound = get_node("DoorSound")
onready var lockedSound = get_node("LockedSound")

onready var landing = get_node("landing")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
	if player == null:
		player = level.player
	return player

func _ready():
	landing.visible = false

	if is_passive:
		visible = false

	id = self.generateId()

	animationPlayer.clear_queue()
	animationPlayer.stop()
	if is_locked:
		animationPlayer.queue("doorClose")
		animationPlayer.queue("locked")
	else: 
		animationPlayer.play("doorOpen")

func isActive():
	return true

func generateId():
	return get_name()

func activate():
	if not is_passive:
		if not is_locked:
			goThroughDoor()
		else:
			if not lockedSound.is_playing():
				lockedSound.play()

func passiveActivate(delta):
	if is_passive:
		goThroughDoor()

func goThroughDoor():
	if not doorSound.is_playing() and not global.isRespawning:
		doorSound.play()
		
	global.memory["lastDoor"] = id
	global.memory["roomPath"] = get_tree().get_root().get_node("Game/Viewport/level").getLevelName()
	global.pauseGame = true

	global.isRespawning = true
	transition.long_fade_to(self.path)

func land():
	global.memory.erase("active_save_point_x")
	global.memory.erase("active_save_point_y")
	global.memory.erase("active_save_point_z")
	
	getPlayer().global_transform.origin.x = landing.global_transform.origin.x
	getPlayer().global_transform.origin.y = landing.global_transform.origin.y
