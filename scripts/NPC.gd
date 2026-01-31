extends "GameMover.gd"

# for backwards compatibility keep TextBox export var nextTextBoxPath if that is set (???)
# otherwise, try to set the textBox, and textBox->portrait.texture, textBox->text.bbtext to the set variables
export(NodePath) var nextTextBoxPath = NodePath("")
export(String, MULTILINE) var bbText = ""
export(String, MULTILINE) var smackedBbText = ""
export var needs_to_talk_normal_first = false
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
export var can_move_player = false

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10

onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
onready var interactPrompt = get_node("InteractPrompt") if has_node("InteractPrompt") else null  # 835
onready var textBoxContainer = get_node("NPC TextBox")
onready var textBox = get_node("NPC TextBox").get_node("TextBox")
onready var fallthroughSolid = get_node("FallthroughSolid") if has_node("FallthroughSolid") else null
onready var fallthroughSolidCollisionShape = get_node("FallthroughSolid/CollisionShape") if has_node("FallthroughSolid/CollisionShape") else null
onready var smallInteractionShape = get_node("SmallInteractionArea/CollisionShape") if has_node("SmallInteractionArea/CollisionShape") else null
onready var smallerInteractionArea = get_node("SmallerInteractionArea") if has_node("SmallerInteractionArea") else null
onready var exclamationAniPlayer = get_node("ExclamationSprite/AnimationPlayer") if has_node("ExclamationSprite") else null

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")

var pressing_jump = false
var just_pressed_jump = false 
export var is_active = true

var am_i_sleepy = false
export var showYesNoOptions = false
export var tiny_textbox = false
export var is_static_in_level = true

# String is a path to a file.
export var randomlyMoo = false
var randomMooTimer = 0
var randomMooTimeLimit = 30

export var is_wiggling_fast = false
export var can_be_smacked = false
export var is_sprite_not_flipped = false
export var interact_prompt_offset = 0

func _ready():
  set_process(true)
  set_physics_process(false)

  mySprite.material_override = mySprite.material_override.duplicate()
  mySprite.should_randomize_frame_delay = false
  should_collide_ceil = false
  if is_wiggling_fast:
    mySprite.frame_delay = 0.2

  if floating_text or not is_a_body and smallerInteractionArea:
    smallerInteractionArea.add_to_group("no_pushems")

  setupTextBoxStuff()

  is_sprite_flipped = true
  if smallInteractionShape.shape is BoxShape and smallInteractionShape.shape.extents.x == 2 and round(smallInteractionShape.shape.extents.y) == 1:
    smallInteractionShape.shape.extents = Vector3(4, 2, 1.3)

func setupTextBoxStuff(override_text = ""):
  if override_text != "":
    textBoxContainer.bbText = override_text
  elif bbText != "" and textBoxContainer.bbText == "":
    textBoxContainer.bbText = bbText
  if smackedBbText != "":
    textBoxContainer.smackedBbText = smackedBbText
  textBoxContainer.needs_to_talk_normal_first = needs_to_talk_normal_first
  if portrait and not textBoxContainer.portrait:
    textBoxContainer.portrait = portrait
  textBoxContainer.is_immediate = is_immediate
  textBoxContainer.floating_text = floating_text
  textBoxContainer.showYesNoOptions = showYesNoOptions
  if floating_text:
    grav = Vector2(0, 0)
  if nextTextBoxPath != null and not nextTextBoxPath.is_empty() and textBoxContainer.nextTextBoxPath.is_empty():
    var nextTextBoxPathStr = "../"
    for i in range(nextTextBoxPath.get_name_count()):
      if i != 0:
        nextTextBoxPathStr += "/"
      nextTextBoxPathStr += nextTextBoxPath.get_name(i)
    textBoxContainer.nextTextBoxPath = NodePath(nextTextBoxPathStr)
  textBoxContainer.interact_prompt_offset = interact_prompt_offset

  var my_memory = self.getMyStaticLevelZoneVar()
  textBoxContainer.setVars()

  textBox.is_important = is_important
  textBox.is_really_important = is_really_important
  textBox.can_camera_zoom = can_camera_zoom
  textBox.floating_text = floating_text
  textBox.showYesNoOptions = showYesNoOptions
  if floating_text:
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
      textBox.has_talked_normal = true
      if textBox.has_been_shown: 
        textBox.is_important = false

  if interactPrompt != null:
    interactPrompt.offset.y = -interact_prompt_offset
    interactPrompt.max_frames = 1
  
  yield(get_tree().create_timer(0.1), "timeout")
  tryShowInteractPrompt(true)
  tryHideActiveInteractPrompt()
  # yield(get_tree().create_timer(0.1), "timeout")
  # stopPassiveActivate()

func _process(delta):
  # super._process(delta) implicit
  var trueDelta = delta
  if should_process_respect_time_dilation:
    delta = delta * global.time_dilation_multiplier

  if randomlyMoo:
    randomMooTimer += (delta*22)
    if randomMooTimer >= randomMooTimeLimit:
      randomMooTimer = 0
      randomMooTimeLimit = rand_range(60, 120)
      if randi() % 8 <= 0:
        textBox.dialogStartSound.volume_db = textBox.originalDialogStartSoundVolume - 10
        textBox.dialogStartSound.pitch_scale = rand_range(textBox.originalDialogStartSoundPitch - 0.5, textBox.originalDialogStartSoundPitch - 0.2)
        textBox.dialogStartSound.play()
        randomMooTimeLimit += 60

  if global.pauseGame:
    tryHideActiveInteractPrompt()

  which_side_is_player_on = level.player.global_transform.origin.x > global_transform.origin.x
  if floating_text:
    mySprite.visible = false

  if (floating_text or dont_recolor_me) and mySprite.is_in_group("sprite"):
    mySprite.remove_from_group("sprite")

  if fallthroughSolid:
    if (not visible or floating_text) and fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.remove_from_group("fallthrough")
    elif visible and not floating_text and not fallthroughSolid.is_in_group("fallthrough"):
      fallthroughSolid.add_to_group("fallthrough")

  if is_smacked:
    smack_timer += (trueDelta * 22)
    if smack_timer >= smack_time_limit:
      is_smacked = false
      unsmack()

func talkToMe():
  textBox.hideInteractPrompt()
  if not floating_text:
    textBox.untinify()
  textBox.interact(true) # was_smacked

func unsmack():
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 3)
    # material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .02)
    mySprite.material_override = material
  if was_smacked_and_should_talk and (
    (global.activeInteractor == null and (textBox.text_final != "" or textBox.smackedBbText != "")) or (global.activeInteractor == textBox and global.pauseGame)
  ):
    talkToMe()
  was_smacked_and_should_talk = false

export var is_merchant = false
func tryHideActiveInteractPrompt():
  textBox.hideInteractPrompt() # also handled by stopPassiveActivate...
  if interactPrompt == null:
    return
  if visible and is_active and not floating_text and textBox.text_final != "":
    interactPrompt.visible = true
    if is_merchant:
      interactPrompt.max_frames = 4
      interactPrompt.updateBaseFrame(13, 23)
    else:
      interactPrompt.max_frames = 4
      interactPrompt.updateBaseFrame(9, 23)
  else:
    interactPrompt.visible = false

func tryShowInteractPrompt(is_active_interact_prompt = false, is_comic_alert = false):
  if interactPrompt == null or was_smacked_and_should_talk:
    return

  # don't you love math
  # this should be bundled together with PlayerInteractionArea.gd likely
  if visible and is_active and not floating_text and textBox.text_final != "":
    interactPrompt.visible = true
    if is_active_interact_prompt and level.player.global_transform.origin.y < self.global_transform.origin.y + 0.5:
      interactPrompt.max_frames = 1
      if is_merchant:
        interactPrompt.updateBaseFrame(13, 23)
      else:
        interactPrompt.updateBaseFrame(9, 23)
      interactPrompt.visible = false
      textBox.showInteractPrompt(is_comic_alert)
    elif interactPrompt.max_frames == 1:
      interactPrompt.max_frames = 4
      if is_merchant:
        interactPrompt.updateBaseFrame(13, 23)
      else:
        interactPrompt.updateBaseFrame(9, 23)
  else:
    interactPrompt.visible = false

    # if not interactPrompt.visible:
    #   interactPrompt.restart()

func fallthroughCollisionActivate(_friend):
  # don't allow text interaction
  pass

var should_i_respond_to_smacks = true
var was_smacked_and_should_talk = false
export var is_very_tiny = false
func getSmacked(_broom_origin = null, silently = false, is_local_broom = true):
  # if not can_be_smacked:
  #   return false
  if not visible or is_very_tiny:
    return null
  if is_smacked:
    return null
  # don't get smacked if we're on the wrong side of a wind up
  if level.player.mySprite.flip_h != which_side_is_player_on and is_local_broom:
    return false

  if global.pauseGame or global.shouldRenderAsCinematic:
    return null
    
  if smackSound and not silently: smackSound.play()
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 35)
    material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .15)
    mySprite.material_override = material
  smack_timer = 0
  is_smacked = true

  if (textBox.text_final == "" or textBox.text_final == null) and (textBox.smackedBbText == "" or textBox.smackedBbText == null):
    return null
  if floating_text or not is_active: 
    return null
  # don't start dialog if you threw broom at me
  if not is_local_broom:
    return null
  
  if textBox.smackedBbText == "" or textBox.smackedBbText == null:
    talkToMe()
  else:
    was_smacked_and_should_talk = true

func setGlobalMemoryOfHasSpoken(set_vars = false):
  if set_vars:
    mySprite.transform.origin.z = 0
  global.setStaticLevelZoneLevelVar(level, self, true)

func isActive(_debug = false):
  return is_active and not floating_text and (visible or can_be_activated_invisibly)

func glitchOut():
  is_active = false
  var glitchEnemy = glitchEnemyRes.instance()
  level.add_child(glitchEnemy)
  glitchEnemy.global_transform.origin = self.global_transform.origin
  global.setStaticLevelZoneLevelVar(level, self, global.DELETE_ME)
  glitchEnemy.glitchOut()
  queue_free()

func activate(is_player, _is_local_broom = false):
  if textBox.text_final == "":
    can_be_smacked = true
    return false
  if not is_player: # and not is_local_broom:
    return false
  if global.activeInteractor == null:
    textBox.hideInteractPrompt()
    if not floating_text:
      textBox.untinify()
    textBox.interact()
    return true
  return false

var which_side_is_player_on = false
func passiveActivate(delta, is_player, _is_local_broom = false):
  if not is_player:
    return
  if can_move and level.player.global_transform.origin.y < self.global_transform.origin.y + 0.5:
    mySprite.flip_h = which_side_is_player_on
    if is_sprite_not_flipped:
      mySprite.flip_h = not mySprite.flip_h
  

  if not visible and can_activate:
    level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
    visible = true
    can_activate = false
  elif visible and (not aniPlayer or not aniPlayer.is_playing()):
    if global.activeInteractor == null or global.activeInteractor == textBox:
      textBox.passiveInteract(delta)

func stopPassiveActivate():
  if global.pauseGame:
    return
  textBox.hideInteractPrompt()
  if not level.player.is_pressing_horizontal_input:
    return
  if global.activeInteractor != null and is_instance_valid(global.activeInteractor) and global.activeInteractor == textBox:
    global.activeInteractor.tryStopInteractPassive()
    
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
  if grav == Vector2(0, 0) and not just_pressed_jump and not pressing_jump and not override_press_move_left and not override_press_move_right:
    return
  else:
    # call GameMover.gd super method
    .processPhysics(delta)
    if override_press_move_left and horizontal_collision:
      override_press_move_left = false
      override_press_move_right = true
    if override_press_move_right and horizontal_collision:
      override_press_move_left = true
      override_press_move_right = false
  

func justPressedJump():
  return just_pressed_jump or override_just_pressed_jump

func pressingJump():
  return pressing_jump or override_press_jump

func idleTalk():
  if not is_wiggling_fast:
    mySprite.frame_delay = 1.6

func imAnNpc():
  return true

export var bring_to_front = true
func appendNextTextCharacter():
  if not is_wiggling_fast:
    mySprite.frame_delay = 0.2
    if bring_to_front:
      mySprite.transform.origin.z = 1
