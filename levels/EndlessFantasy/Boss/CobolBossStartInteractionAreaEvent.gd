extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func isActive(_debug=false):
    return true

func passiveActivate(_delta, _is_player):
    level.gameCamera.initial_target = level.get_node("BossCameraTarget")

    var display_title = "beast o' many faces: COBOL"
    if level.uiLayer.display_title != display_title:
        level.uiLayer.setDisplayTitle(display_title)