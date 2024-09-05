extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var cursedGrandmaStatue = weakref(get_node("CursedGrandmaStatue"))
onready var glitchGrandma = weakref(get_node("GlitchGrandma"))
onready var playerActivationArea = get_node("PlayerActivationArea")

enum GlitchForm {
  NORMAL,
  FLOOR,
  FEATHER,
  INVISIBLE,
  LADDER,
  WALK_THROUGH_WALLS,
}
export(GlitchForm) var glitch_form = GlitchForm.NORMAL

enum WhichMode {
  STATUE,
  ALIVE
}
var which_mode = WhichMode.STATUE

func _ready():
  glitchGrandma.get_ref().glitch_form = glitch_form
  glitchGrandma.get_ref().visible = false
  cursedGrandmaStatue.get_ref().glitch_form = glitch_form

func _process(_delta):
  processGlitchFormActivation()

var Y_OFFSET = 0.2
func processGlitchFormActivation():
  if not level.has_room_initialized:
    return
  
  if which_mode == WhichMode.STATUE:
    if playerActivationArea.touchingPlayer: #and glitch_form == level.player.glitch_form:
      glitchGrandma.get_ref().visible = true
      glitchGrandma.get_ref().global_transform.origin = cursedGrandmaStatue.get_ref().global_transform.origin
      glitchGrandma.get_ref().global_transform.origin.y += Y_OFFSET
      glitchGrandma.get_ref().mySprite.flip_h = cursedGrandmaStatue.get_ref().mySprite.flip_h
      cursedGrandmaStatue.get_ref().visible = false
      level.summonSmokeClouds(cursedGrandmaStatue.get_ref().global_transform.origin, 3, true, true)
      which_mode = WhichMode.ALIVE
  elif which_mode == WhichMode.ALIVE:
    pass
    # if glitch_form != level.player.glitch_form:
    #   cursedGrandmaStatue.get_ref().visible = true
    #   cursedGrandmaStatue.get_ref().global_transform.origin = glitchGrandma.get_ref().global_transform.origin
    #   cursedGrandmaStatue.get_ref().global_transform.origin.y -= Y_OFFSET
    #   cursedGrandmaStatue.get_ref().mySprite.flip_h = glitchGrandma.get_ref().mySprite.flip_h
    #   glitchGrandma.get_ref().visible = false
    #   level.summonSmokeClouds(cursedGrandmaStatue.get_ref().global_transform.origin, 3, true, true)
    #   which_mode = WhichMode.STATUE


func isActive():
  return visible

func playerActivationAreaPassiveActivate():
  pass
