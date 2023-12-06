extends "GameMover.gd"

# for backwards compatibility keep TextBox export var nextTextBoxPath if that is set (???)
# otherwise, try to set the textBox, and textBox->portrait.texture, textBox->text.bbtext to the set variables
export(NodePath) var nextTextBoxPath = NodePath("")
export(String, MULTILINE) var bbText = ""
export(Texture) var portrait
export var is_important = false # when dialogue is started, can't walk away until finished.
export var is_really_important = false # touching it will start the dialogue
export var can_be_activated_invisibly = false
export var can_activate = true
export var can_move = true
export var can_camera_zoom = true
export var is_fast_text = false
export var dont_recolor_me = false
export var is_immediate = false
export var is_a_body = true
export var floating_text = false

var is_smacked = false
var did_i_get_smacked = false
var smack_timer = 0
var smack_time_limit = 10

onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
onready var interactPrompt = get_node("InteractPrompt") if has_node("InteractPrompt") else null
onready var textBoxContainer = get_node("NPC TextBox")
onready var textBox = get_node("NPC TextBox").get_node("TextBox")
onready var fallthroughSolid = get_node("FallthroughSolid") if has_node("FallthroughSolid") else null
onready var smallerInteractionArea = get_node("SmallerInteractionArea") if has_node("SmallerInteractionArea") else null

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")

var pressing_jump = false
var just_pressed_jump = false 
export var is_active = true

export var tiny_textbox = false
export var is_static_in_level = true

var pressing_move_left = false
var pressing_move_right = false
export var is_wiggling_fast = false

# @override
func pressingMoveLeft():
  return pressing_move_left

# @override
func pressingMoveRight():
  return pressing_move_right

func _ready():
  set_process(true)
  set_physics_process(true)

  mySprite.material_override = mySprite.material_override.duplicate()
  mySprite.should_randomize_frame_delay = false
  if is_wiggling_fast:
    mySprite.frame_delay = 0.2

  if floating_text or not is_a_body and smallerInteractionArea:
    smallerInteractionArea.add_to_group("no_pushems")

  if bbText != "" and textBoxContainer.bbText == "":
    textBoxContainer.bbText = bbText
  if portrait and not textBoxContainer.portrait:
    textBoxContainer.portrait = portrait
  textBoxContainer.is_immediate = is_immediate
  textBoxContainer.floating_text = floating_text
  if floating_text:
    grav = 0
  if not nextTextBoxPath.is_empty() and textBoxContainer.nextTextBoxPath.is_empty():
    var nextTextBoxPathStr = "../"
    for i in range(nextTextBoxPath.get_name_count()):
      if i != 0:
        nextTextBoxPathStr += "/"
      nextTextBoxPathStr += nextTextBoxPath.get_name(i)
    textBoxContainer.nextTextBoxPath = NodePath(nextTextBoxPathStr)

  var my_memory = self.getMyStaticLevelZoneVar()
  if not is_static_in_level or not my_memory: 
    is_really_important = true
  textBoxContainer.setVars()

  textBox.is_important = is_important
  textBox.is_really_important = is_really_important
  textBox.can_camera_zoom = can_camera_zoom
  textBox.floating_text = floating_text
  if tiny_textbox or floating_text:
    textBox.tinify()
  textBox.is_fast_text = is_fast_text

  if is_static_in_level and my_memory:
    if (typeof(my_memory) == TYPE_INT or typeof(my_memory) == TYPE_REAL) and my_memory == global.DELETE_ME:
      queue_free()
    else:
      can_camera_zoom = false
      textBox.can_camera_zoom = false
      if not visible and can_activate:
        visible = true
        can_activate = false
      textBox.has_been_shown = true
      if textBox.has_been_shown: 
        textBox.is_important = false

func _process(delta):
  # super._process(delta) implicit

  which_side_is_player_on = level.player.global_transform.origin.x > global_transform.origin.x
  if floating_text:
    mySprite.visible = false

  if (floating_text or dont_recolor_me) and mySprite.is_in_group("sprite"):
    mySprite.remove_from_group("sprite")

  # don't you love math
  # if is_active and interactPrompt != null and not floating_text and textBox.text_final != "":
  #   interactPrompt.visible = interactionArea != null and interactionArea.wasTouchingPlayer and (
  #     (not textBox.is_really_important and not textBox.is_tiny) or textBox.has_been_shown) and (
  #     global.activeInteractor == null or (is_instance_valid(global.activeInteractor) and 
  #       global.activeInteractor == textBox and textBox.nextPrompt.visible
  #     )
  #   )
  #   if not interactPrompt.visible:
  #     interactPrompt.restart()

  if fallthroughSolid:
    if (not visible or floating_text) and fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.remove_from_group("fallthrough")
    elif visible and not floating_text and not fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.add_to_group("fallthrough")

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      var material = mySprite.material_override
      if material is ShaderMaterial:
        material.set_shader_param("time_influence", 3)
        # material.set_shader_param("y_div", 2.3)
        material.set_shader_param("normal_offset", .02)
        mySprite.material_override = material


func getSmacked(_broom_origin):
  if textBox.text_final == "":
    return false
  if floating_text or not is_active: 
    return false
  # don't get smacked if we're on the wrong side of a wind up
  if level.player.mySprite.flip_h != which_side_is_player_on and global.memory["broom"]:
    return false
  # don't start IMPORTANT dialog if you threw broom at me
  if is_important and not global.memory["broom"]:
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
  did_i_get_smacked = true

  if (global.activeInteractor == null and not textBox.text_final == "") or (global.activeInteractor == textBox and global.pauseGame):
    textBox.interact()

func setGlobalMemoryOfHasSpoken(set_vars = false):
  if set_vars:
    did_i_get_smacked = false
  global.setStaticLevelZoneLevelVar(level, self.name, true)

func isActive():
  return is_active and not floating_text and (visible or can_be_activated_invisibly)

func glitchOut():
  is_active = false
  var glitchEnemy = glitchEnemyRes.instance()
  level.add_child(glitchEnemy)
  glitchEnemy.global_transform.origin = self.global_transform.origin
  global.setStaticLevelZoneLevelVar(level, self.name, global.DELETE_ME)
  glitchEnemy.glitchOut()
  queue_free()

func activate(is_player):
  if not is_player:
    return
  if global.activeInteractor == null:
    textBox.interact()
  pass

var which_side_is_player_on = false
func passiveActivate(delta, is_player):
  if not is_player:
    return
  if can_move:
    mySprite.flip_h = which_side_is_player_on
  

  if not visible and can_activate:
    if aniPlayer:
      aniPlayer.play("flickerOn")
      var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
      add_child(newSpawnGlitchEffect)
    else:
      visible = true
    can_activate = false
  elif visible and (not aniPlayer or not aniPlayer.is_playing()):
    if global.activeInteractor == null or global.activeInteractor == textBox:
      textBox.passiveInteract(delta)

func stopPassiveActivate():
  if not level.player.is_pressing_horizontal_input:
    return

  # TODO(jaketrower): TODO on a timer...
  if global.activeInteractor != null and is_instance_valid(global.activeInteractor) and global.activeInteractor == textBox:
    global.activeInteractor.stopInteract()
  did_i_get_smacked = false
    
func justStopPassiveActivate():
  pass
  
export var dont_align_sprite = false
# @override
func alignMySprite():
  if dont_align_sprite:
    return
  var pixelSize = 0.125
  mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
  mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + 0.3

# @override
func processPhysics(delta):
  if grav == 0 and not just_pressed_jump and not pressing_jump and not pressing_move_left and not pressing_move_right:
    return
  else:
    # call GameMover.gd super method
    .processPhysics(delta)
  

func justPressedJump():
  return just_pressed_jump

func pressingJump():
  return pressing_jump

func idleTalk():
  if not is_wiggling_fast:
    mySprite.frame_delay = 1.6

func imAnNpc():
  return true

func appendNextTextCharacter():
  if not is_wiggling_fast:
    mySprite.frame_delay = 0.2
