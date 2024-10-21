extends "GameMover.gd"

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10
var which_side_is_player_on = false

onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
onready var smallInteractionShape = get_node("SmallInteractionArea/CollisionShape") if has_node("SmallInteractionArea/CollisionShape") else null
onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite")
onready var streetlightGlitchAura  = get_node("StreetlightGlitchAura")
onready var cubeContainer = get_node("CubeContainer")

func _ready():
  set_process(true)
  set_physics_process(false)

  mySprite.material_override = mySprite.material_override.duplicate()
  spellbookGlitchSprite.material_override = spellbookGlitchSprite.material_override.duplicate()
  streetlightGlitchAura.mainTextureRect.material = streetlightGlitchAura.mainTextureRect.material.duplicate()
  var meshInstance2 = get_node("CubeContainer/MeshInstance2")
  meshInstance2.set_material_override(meshInstance2.get_material_override().duplicate())

  yield(TempTimer.idle_frame(self), "timeout")
  if glitch_form != global.GlitchForm.NORMAL:
      var target_palette = level.levelTiles.grey_palette
      if glitch_form == global.GlitchForm.FLOOR:
          target_palette = level.levelTiles.red_palette
      elif glitch_form == global.GlitchForm.LADDER:
          target_palette = level.levelTiles.yellow_palette
      elif glitch_form == global.GlitchForm.FEATHER:
          target_palette = level.levelTiles.green_palette
      elif glitch_form == global.GlitchForm.INVISIBLE:
          target_palette = level.levelTiles.black_palette
      elif glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
          target_palette = level.levelTiles.white_palette
      # mySprite.material_override.set_shader_param("target_palette", target_palette)
      spellbookGlitchSprite.material_override.set_shader_param("target_palette", target_palette)
      streetlightGlitchAura.mainTextureRect.material.set_shader_param("target_palette", target_palette)

func _process(delta):
  # super._process(delta) implicit

  cubeContainer.rotation_degrees.y += delta*22
  which_side_is_player_on = level.player.global_transform.origin.x > global_transform.origin.x
  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL # and global.memory["colorblindMode"]
  if not isActive():
    streetlightGlitchAura.mainTextureRect.visible = false
  else:
    if glitch_form == global.GlitchForm.NORMAL:
      streetlightGlitchAura.mainTextureRect.visible = false
    else:
      streetlightGlitchAura.mainTextureRect.visible = level.player.glitch_form != glitch_form
      # TODO(jaketrower): could dedupe with Player.gd 
      if glitch_form == global.GlitchForm.FEATHER:
        spellbookGlitchSprite.frame = 0
      elif glitch_form == global.GlitchForm.FLOOR:
        spellbookGlitchSprite.frame = 1
      elif glitch_form == global.GlitchForm.LADDER:
        spellbookGlitchSprite.frame = 2
      elif glitch_form == global.GlitchForm.INVISIBLE:
        spellbookGlitchSprite.frame = 3

    # if mySprite.material_override != null:
    #   if level.player.glitch_form == glitch_form:
    #       mySprite.material_override.set_shader_param("opacity", 1.0)
    #       mySprite.global_transform.origin.z = 1
    #   elif level.player.glitch_form != glitch_form:
    #       mySprite.material_override.set_shader_param("opacity", 0.05)
    #       mySprite.global_transform.origin.z = 0

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      unsmack()

func unsmack():
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 3)
    # material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .02)
    mySprite.material_override = material


func getSmacked(_broom_origin = Vector3(0, 0, 0), _silently = false):
  if is_smacked:
    return false
  # don't get smacked if we're on the wrong side of a wind up
  if level.player.mySprite.flip_h != which_side_is_player_on and global.memory["broom"]:
    return false
    
  if smackSound: smackSound.play()
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 35)
    material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .15)
    mySprite.material_override = material
  smack_timer = 0
  is_smacked = true
  tryApplyMyGlitch()

func passiveActivate(_delta, _is_player):
  # tryApplyMyGlitch()
  pass

func tryApplyMyGlitch():
  if level.player.glitch_form != glitch_form:
    level.player.applyGlitch(glitch_form)

func isActive(_debug = false):
  return visible
