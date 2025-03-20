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
  level.gameCamera.initial_size = 40
  level.gameCamera.zoomed_size = 40
  yield(get_tree().create_timer(4.0), "timeout")
  level.get_node("PrimordialOozeBoss/PrimordialOozeNPC").activate(true)

func _process(delta):
  pass