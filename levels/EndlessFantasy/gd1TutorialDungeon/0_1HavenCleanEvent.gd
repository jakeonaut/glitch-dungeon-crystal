extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var npc = weakref(get_node("../../NPC"))

func _ready():
  mySprite.visible = false

func isActive(_debug=false):
  return true

var has_played_animation = false
func passiveActivate(_delta, _is_player):
  if not has_played_animation:
    has_played_animation = true
    if npc.get_ref():
      npc.get_ref().textBox.hide()
      npc.get_ref().glitchOut()
