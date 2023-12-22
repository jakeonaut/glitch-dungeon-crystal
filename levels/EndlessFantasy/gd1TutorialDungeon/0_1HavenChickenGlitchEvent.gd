extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var chickenNPC = weakref(get_node("../ChickenNPC"))

func _ready():
  mySprite.visible = false

func isActive():
  return true

var has_played_animation = false
func passiveActivate(_delta, _is_player):
  if not has_played_animation:
    has_played_animation = true
    if chickenNPC.get_ref():
      chickenNPC.get_ref().glitchOut()
