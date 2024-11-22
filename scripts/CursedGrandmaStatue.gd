extends "GameMover.gd"

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10
var which_side_is_player_on = false

onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
onready var fallthroughSolid = get_node("FallthroughSolid") if has_node("FallthroughSolid") else null
onready var smallInteractionShape = get_node("SmallInteractionArea/CollisionShape") if has_node("SmallInteractionArea/CollisionShape") else null
onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite")
onready var faceSprite = get_node("FaceSprite")

func _ready():
  set_process(true)
  set_physics_process(false)
  spriteYAlignment = 0.5

  mySprite.material_override = mySprite.material_override.duplicate()
  faceSprite.material_override = faceSprite.material_override.duplicate()
  spellbookGlitchSprite.material_override = spellbookGlitchSprite.material_override.duplicate()

  yield(TempTimer.idle_frame(self), "timeout")
  updateColor()

var dist_to_player = 999
func _process(delta):
  # super._process(delta) implicit

  which_side_is_player_on = level.player.global_transform.origin.x > global_transform.origin.x
  dist_to_player = level.player.global_transform.origin.distance_to(self.global_transform.origin)
  processRendering(delta)

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      unsmack()

var FACE_X_OFFSET = 0.127
var FACE_Y_OFFSET = 0.485
var FACE_Z_OFFSET = 0.25
func processRendering(_delta):
  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL # and global.userSettings["colorblindMode"]
  if not isActive():
    pass
  else:
    if glitch_form == global.GlitchForm.NORMAL:
      spellbookGlitchSprite.frame = 15
    else:
      true_terminal_vel = 32
      # TODO(jaketrower): could dedupe with Player.gd and GrandmaStatue.gd
      if glitch_form == global.GlitchForm.FEATHER:
        spellbookGlitchSprite.frame = 0
        true_terminal_vel = 16
      elif glitch_form == global.GlitchForm.FLOOR:
        spellbookGlitchSprite.frame = 1
      elif glitch_form == global.GlitchForm.LADDER:
        spellbookGlitchSprite.frame = 2
      elif glitch_form == global.GlitchForm.INVISIBLE:
        spellbookGlitchSprite.frame = 3

  if mySprite.flip_h:
    faceSprite.flip_h = true
    faceSprite.global_transform.origin = global_transform.origin + Vector3(FACE_X_OFFSET, FACE_Y_OFFSET, FACE_Z_OFFSET)
  else:
    faceSprite.flip_h = false
    faceSprite.global_transform.origin = global_transform.origin + Vector3(-FACE_X_OFFSET, FACE_Y_OFFSET, FACE_Z_OFFSET)

func updateColor():
  var target_palette = level.levelTiles.grey_palette
  var sprite_palette = global.grey_player_palette
  mySprite.material_override.set_shader_param("enable_no_transparency", true)
  if glitch_form == global.GlitchForm.FLOOR:
    sprite_palette = global.player_red_palette
    target_palette = level.levelTiles.red_palette
  elif glitch_form == global.GlitchForm.LADDER:
    sprite_palette = global.yellow_player_palette
    target_palette = level.levelTiles.yellow_palette
  elif glitch_form == global.GlitchForm.FEATHER:
    sprite_palette = global.green_dungeon_palette
    target_palette = level.levelTiles.green_palette
  elif glitch_form == global.GlitchForm.INVISIBLE:
    sprite_palette = global.black_player_palette
    target_palette = level.levelTiles.black_palette
  elif glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    sprite_palette = global.white_player_palette
    target_palette = level.levelTiles.white_palette
  mySprite.material_override.set_shader_param("target_palette", sprite_palette)
  faceSprite.material_override.set_shader_param("target_palette", sprite_palette)
  spellbookGlitchSprite.material_override.set_shader_param("target_palette", target_palette)

func unsmack():
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 3)
    # material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .02)
    mySprite.material_override = material

func isFallthroughCollisionActive():
  return level.player.glitch_form != self.glitch_form

func fallthroughCollisionActivate(_friend):
  # don't allow text interaction
  pass


func getSmacked(_broom_origin = null, _silently = false):
  return false
  # if is_smacked:
  #   return false
  # # don't get smacked if we're on the wrong side of a wind up
  # if level.player.mySprite.flip_h != which_side_is_player_on and global.memory["broom"]:
  #   return false
    
  # if smackSound: smackSound.play()
  # var material = mySprite.material_override
  # if material is ShaderMaterial:
  #   material.set_shader_param("time_influence", 35)
  #   material.set_shader_param("y_div", 2.3)
  #   material.set_shader_param("normal_offset", .15)
  #   mySprite.material_override = material
  # smack_timer = 0
  # is_smacked = true

func passiveActivate(_delta, _is_player):
  pass

export var max_dist_to_player = 30
func isActive(_debug = false):
  return visible#  and dist_to_player <= max_dist_to_player
