extends "GameMover.gd"

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10
var which_side_is_player_on = false

onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
onready var fallthroughSolid = get_node("FallthroughSolid") if has_node("FallthroughSolid") else null
onready var smallInteractionShape = get_node("SmallInteractionArea/CollisionShape") if has_node("SmallInteractionArea/CollisionShape") else null
onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite")
onready var triangleContainer = get_node("TriangleContainer")
onready var saveDiskSprite = get_node("TriangleContainer/Sprite3D")
onready var saveSporesSprite = get_node("SaveSpores")
onready var saveSound = get_node("SaveSound")
export var is_extra_life = false
var is_extra_life_active = false

func _ready():
  set_process(true)
  set_physics_process(false)
  spriteYAlignment = 0.5

  mySprite.material_override = mySprite.material_override.duplicate()
  spellbookGlitchSprite.material_override = spellbookGlitchSprite.material_override.duplicate()
  saveDiskSprite.material_override = saveDiskSprite.material_override.duplicate()

  glitch_form_before_nullification = glitch_form
  yield(TempTimer.idle_frame(self), "timeout")
  updateColor()

var has_swapped = false
var players_last_glitch_form = global.GlitchForm.NORMAL
var glitch_form_before_nullification = global.GlitchForm.NORMAL
var dist_to_player = 999
func _process(delta):
  # super._process(delta) implicit

  which_side_is_player_on = level.player.global_transform.origin.x > global_transform.origin.x
  dist_to_player = level.player.global_transform.origin.distance_to(self.global_transform.origin)
  processRendering(delta)
  if is_extra_life:
    on_ground = true
    grav = 0
  processGlitchFormTeleportation()

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      unsmack()

func processRendering(delta):
  triangleContainer.visible = is_extra_life

  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL and global.memory["colorblindMode"]
  if not isActive():
    triangleContainer.scale.x = 1.0
    triangleContainer.scale.y = 1.0
    triangleContainer.rotation_degrees.y = 0
    saveSporesSprite.visible = false
    disablePaletteCycle()
  else:
    if is_extra_life:
      triangleContainer.rotation_degrees.y -= delta*22*5
      triangleContainer.scale.x = 1.5
      triangleContainer.scale.y = 1.5
      enablePaletteCycle()
      # spawn_timer = spawn_time_limit
      triangleContainer.scale.x = 1.5
      triangleContainer.scale.y = 1.5
      saveSporesSprite.visible = true

    if glitch_form == global.GlitchForm.NORMAL:
      spellbookGlitchSprite.frame = 15
    else:
      triangleContainer.visible = false
      true_terminal_vel = 32
      # TODO(jaketrower): could dedupe with Player.gd 
      if glitch_form == global.GlitchForm.FEATHER:
        spellbookGlitchSprite.frame = 0
        true_terminal_vel = 16
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

func enablePaletteCycle():
  saveDiskSprite.material_override.set_shader_param("enable_palette_cycle", true)
  saveDiskSprite.material_override.set_shader_param("target_palette", global.base_palette)

func disablePaletteCycle():
  saveDiskSprite.material_override.set_shader_param("enable_palette_cycle", false)
  saveDiskSprite.material_override.set_shader_param("target_palette", global.grey_palette)

# this happens at time of room initialization
func preprocessGlitchFormTeleportation():
  if level.player.glitch_form == global.GlitchForm.NORMAL:
    return
  if level.player.glitch_form == glitch_form:
    # nullify me instead!
    glitch_form = global.GlitchForm.NORMAL
    updateColor()
    queue_free()
  

func processGlitchFormTeleportation():
  if not level.has_room_initialized:
    return

  if level.player.glitch_form == glitch_form:
    if not has_swapped:
      var last_on_ground = level.player.was_on_ground
      has_swapped = true
      if glitch_form != global.GlitchForm.NORMAL:
        var my_old_origin = self.global_transform.origin
        self.global_transform.origin = level.player.global_transform.origin
        level.player.global_transform.origin = my_old_origin
        level.summonSmokeClouds(level.player.global_transform.origin, 2, true, true)
        level.summonSmokeClouds(global_transform.origin, 2, false, true)
        level.player.on_ground = level.player.glitch_form == global.GlitchForm.FLOOR and on_ground
        glitch_form = players_last_glitch_form
        if glitch_form == global.GlitchForm.NORMAL:
          glitch_form_before_nullification = level.player.glitch_form
      elif glitch_form_before_nullification != global.GlitchForm.NORMAL:
        glitch_form = glitch_form_before_nullification
      updateColor()
      on_ground = glitch_form == global.GlitchForm.FLOOR and last_on_ground
  else:
    has_swapped = false
    players_last_glitch_form = level.player.glitch_form

func updateColor():
  var target_palette = level.levelTiles.grey_palette
  var sprite_palette = global.grey_player_palette
  mySprite.material_override.set_shader_param("enable_no_transparency", true)
  if is_extra_life:
    sprite_palette = global.NES_broom_palette
    target_palette = global.NES_broom_palette
    mySprite.material_override.set_shader_param("enable_no_transparency", false)
  elif glitch_form == global.GlitchForm.FLOOR:
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


func getSmacked(_broom_origin = Vector3(0, 0, 0), _silently = false):
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
  # tryApplyMyGlitch()

func passiveActivate(_delta, _is_player):
  # tryApplyMyGlitch()
  pass

func tryApplyMyGlitch():
  if level.player.glitch_form != glitch_form:
    level.player.applyGlitch(glitch_form)

export var max_dist_to_player = 30
func isActive(_debug = false):
  return visible and dist_to_player <= max_dist_to_player and (not is_extra_life or is_extra_life_active)
