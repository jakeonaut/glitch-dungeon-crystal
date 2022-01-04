extends RichTextLabel


export var target_origin = Vector3(0, 0, 0)

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var gameCamera = null
func getGameCamera():
    if gameCamera == null:
        gameCamera = level.gameCamera
    return gameCamera

func _process(_delta):
    setPosition()


func setPosition():
    # https://godotengine.org/qa/64393/how-do-i-get-2d-coordinates-from-a-3d-scene
    var target_pos = getGameCamera().unproject_position(target_origin)
    self.rect_position.x = target_pos.x - 150
    self.rect_position.y = target_pos.y - 75