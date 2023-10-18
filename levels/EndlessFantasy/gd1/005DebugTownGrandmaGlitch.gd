extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var aniPlayer = get_node("AnimationPlayer")

func _ready():
  mySprite.visible = false

func isActive():
  return true

var has_played_animation = false
func passiveActivate(_delta, _is_player):
  if not has_played_animation:
    has_played_animation = true
    aniPlayer.play("glitchOutGrandma")
