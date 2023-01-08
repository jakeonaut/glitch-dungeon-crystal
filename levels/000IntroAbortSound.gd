extends AudioStreamPlayer

onready var door = get_tree().get_root().get_node("Game/Viewport/level/Door")

var has_done_my_magick = false

func _ready():
    pass

func activateScript():
    door.goThroughDoor(false, true)