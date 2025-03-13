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
export var can_jump_or_fall = true
export var override_am_i_in_range_of_player = false

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
  if glitchGrandma.get_ref():
    glitchGrandma.get_ref().can_jump_or_fall = can_jump_or_fall
    glitchGrandma.get_ref().override_am_i_in_range_of_player = override_am_i_in_range_of_player
  processGlitchFormActivation()

var Y_OFFSET = 0.2
func processGlitchFormActivation():
  if not level.has_room_initialized:
    return

  if glitchGrandma.get_ref() == null or glitchGrandma.get_ref() == null:
    return
  
  if which_mode == WhichMode.STATUE:
    if glitch_form == level.player.glitch_form:
      glitchGrandma.get_ref().visible = true
      glitchGrandma.get_ref().global_transform.origin = cursedGrandmaStatue.get_ref().global_transform.origin
      glitchGrandma.get_ref().global_transform.origin.y += Y_OFFSET
      glitchGrandma.get_ref().mySprite.flip_h = cursedGrandmaStatue.get_ref().mySprite.flip_h
      cursedGrandmaStatue.get_ref().visible = false
      level.summonSmokeClouds(cursedGrandmaStatue.get_ref().global_transform.origin, 3, true, true)
      which_mode = WhichMode.ALIVE
  elif which_mode == WhichMode.ALIVE:
    if glitch_form != level.player.glitch_form:
      cursedGrandmaStatue.get_ref().visible = true
      cursedGrandmaStatue.get_ref().global_transform.origin = glitchGrandma.get_ref().global_transform.origin
      cursedGrandmaStatue.get_ref().global_transform.origin.y -= Y_OFFSET
      cursedGrandmaStatue.get_ref().mySprite.flip_h = glitchGrandma.get_ref().mySprite.flip_h
      if glitchGrandma.get_ref().glitch_form == global.GlitchForm.FLOOR:
        glitchGrandma.get_ref().on_ground = true
      glitchGrandma.get_ref().vv = 0
      glitchGrandma.get_ref().hv = Vector3(0, 0, 0)
      glitchGrandma.get_ref().lv = Vector3(0, 0, 0)
      glitchGrandma.get_ref().linear_velocity = Vector3(0, 0, 0)
      glitchGrandma.get_ref().visible = false
      level.summonSmokeClouds(cursedGrandmaStatue.get_ref().global_transform.origin, 3, true, true)
      which_mode = WhichMode.STATUE


func isActive():
  return visible

func playerActivationAreaPassiveActivate():
  pass
