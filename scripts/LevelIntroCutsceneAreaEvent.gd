extends Spatial

# String is a path to a file.
export(String, FILE) var path
onready var mySprite = get_node("Sprite3D")

func _ready():
  mySprite.visible = false
  set_process(true)

func isActive(_debug=false):
  return true

var has_activated = false
onready var player = get_node("../Player") if has_node("../Player") else null
var transition_timer = 0
var transition_time_limit = 60
func passiveActivate(_delta, _is_player):
  if has_activated:
    return

  player.physics_state = player.PhysicsState.OCCUPIED
  player.pauseInput = true
  player.pauseAnimation = true
  player.pauseSelf = true
  has_activated = true

var is_transitioning = false
func _process(delta):
    if is_transitioning:
        return

    transition_timer += (delta*11)
    if transition_timer >= transition_time_limit:
        is_transitioning = true
        global.isEnteringRoom = true
        global.hasJustEnteredRoom = false
        transition.long_fade_to(self.path)