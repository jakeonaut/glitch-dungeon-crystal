extends Spatial

onready var hookInteractionArea = get_node("HookInteractionArea")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
export(NodePath) var hookTargetPath = null
var hookTarget = null

func _ready():
  pass # Replace with function body.

func isActive(_debug=false):
  return true

func passiveActivate(_delta, is_player):
  if not hooked and is_player and level.player.canIGetCaught():
    level.clearOtherGrabbers()
    hooked = true
    hookTarget = weakref(level.player)
    level.player.hookSound.play()
    if not level.player.pauseAnimation or level.player.physics_state == level.player.PhysicsState.BEING_TOSSED:
      level.player.aniPlayer.play("hookCaught")
    level.player.pauseAnimation = true
    level.player.should_do_fallthrough_area_collision = false
    level.player.tryClearFallthroughCollisionSolid()
  