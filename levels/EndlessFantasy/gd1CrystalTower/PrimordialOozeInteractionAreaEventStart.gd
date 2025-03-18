extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var has_animated = false

func _ready():
  mySprite.visible = false
  global.shouldRenderAsCinematic = true
  set_process(true)

func isActive(_debug=false):
  return not has_animated

func passiveActivate(_delta, _is_player):
  has_animated = true
  level.get_node("AnimationPlayer").play("judgement")
  global.pauseGame = true

func _process(delta):
  pass