extends Spatial


onready var hookInteractionArea = get_node("HookInteractionArea")
onready var lineSprite = get_node("LineSprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hooked = false
var is_reeled_in = false

var depth = 0
var vv = 0
var acc = 60
var max_speed = 8
var low_speed = 4

func _ready():
  depth = self.global_transform.origin.y - hookInteractionArea.global_transform.origin.y
  set_process(true)

func _process(delta):
  var diff = self.global_transform.origin.y - hookInteractionArea.global_transform.origin.y + 1
  lineSprite.global_transform.origin.y = self.global_transform.origin.y - (diff) / 2
  lineSprite.scale.y = (diff - .75) / 2

  if hooked:
    movePlayerToHook(delta)
    if not is_reeled_in:
      reelItIn(delta)
    else:
      if Input.is_action_just_pressed("jump_button"):
        hooked = false
        level.player.should_magic_jump = true
  elif is_reeled_in:
    reelItOut(delta)

func movePlayerToHook(delta):
  if is_reeled_in:
    level.player.global_transform.origin.x = hookInteractionArea.global_transform.origin.x
    level.player.global_transform.origin.y = hookInteractionArea.global_transform.origin.y
  else:
    var x = level.player.global_transform.origin.x
    var y = level.player.global_transform.origin.y
    x = x + (hookInteractionArea.global_transform.origin.x - x) * (delta * 10)
    y = y + (hookInteractionArea.global_transform.origin.y - y) * (delta * 10)
    if stepify(x, 0.1) == stepify(hookInteractionArea.global_transform.origin.x, 0.1):
      x = hookInteractionArea.global_transform.origin.x
    if stepify(y, 0.1) == stepify(hookInteractionArea.global_transform.origin.y, 0.1):
      y = hookInteractionArea.global_transform.origin.y
    level.player.global_transform.origin.x = x
    level.player.global_transform.origin.y = y

func reelItIn(delta):
  vv += acc * delta
  if vv >= max_speed:
    vv = max_speed
  hookInteractionArea.global_transform.origin.y += vv * delta
  if hookInteractionArea.global_transform.origin.y > self.global_transform.origin.y:
    hookInteractionArea.global_transform.origin.y = self.global_transform.origin.y
    is_reeled_in = true

func reelItOut(delta):
  hookInteractionArea.global_transform.origin.y -= low_speed * delta
  if hookInteractionArea.global_transform.origin.y < self.global_transform.origin.y - depth:
    hookInteractionArea.global_transform.origin.y = self.global_transform.origin.y - depth
    is_reeled_in = false

func isActive():
  return true

func passiveActivate(_delta):
  if not hooked and not is_reeled_in:
    hooked = true
  
