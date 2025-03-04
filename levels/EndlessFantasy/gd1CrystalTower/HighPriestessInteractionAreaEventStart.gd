extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return level.should_start_cutcene == 0

func passiveActivate(_delta, _is_player):
  level.should_start_cutcene = 1
