extends "../../../scripts/levelScript.gd"

onready var videoPlayer = get_node("../../Viewport2/VideoPlayer")

# @override
func setUpRoomInitializationOverride():
    pass

# @override
func _process(_delta):
    screenEffectsContainer.offset = Vector2(0, 0)
    viewportTexture.rect_position = Vector2(0, 0)

func tryToAddGameFrameBackground():
    pass