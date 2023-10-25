extends Spatial

onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false

func isActive():
  return true

func passiveActivate(_delta, _is_player):
  get_node("..").queue_free()
