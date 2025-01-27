extends AudioStreamPlayer


onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    pass

func activateScript():
    var door = level.get_node("Door")
    var door2 = level.get_node("Door2")
    if door.visible:
        door.visible = false
        door2.visible = true
    elif door2.visible:
        door.visible = true
        door2.visible = false

func isActive(_debug=false):
    return true
