extends "NPC.gd"

var summonedBroom = null
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
export var has_broom = false
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")
onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var caneSprite = get_node("CaneSprite")
var am_i_sleepy = false
var am_i_glitchy = false

func _ready():
  set_process(true)

func _process(delta):
  processBroomRenderLogic(delta)
  if mySprite.flip_h:
    caneSprite.flip_h = true
    caneSprite.global_transform.origin.x = self.global_transform.origin.x + 1.814
  else:
    caneSprite.flip_h = false
    caneSprite.global_transform.origin.x = self.global_transform.origin.x - 1.814


func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.scale = broomSpriteAnimated.scale
  broomSpriteVisible.flip_h = true
  # broomSpriteVisible.material_override.set_shader_param("target_palette", global.player_red_palette)
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = false
    broomSpriteVisible.translation.x *= -1
  if physics_state == PhysicsState.OCCUPIED:
    broomSpriteVisible.visible = false
  elif summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif has_broom:
    broomSpriteVisible.visible = true
  else:
    broomSpriteVisible.visible = false

func adjustSummonedBroomSpritePosition():
  var xAddition = .875
  var yAddition = .625

  broomSpriteVisible.visible = false
  if mySprite.flip_h:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x - xAddition
    summonedBroom.rotation_degrees = Vector3(0, 180, 0)
  else:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x + xAddition
    summonedBroom.rotation_degrees = Vector3(0, 0, 0)

  if self.grav < 0:
    summonedBroom.rotation_degrees.x = 180
    yAddition *= -1
    # yAddition -= 3.146
  else:
    summonedBroom.rotation_degrees.x = 0

  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + yAddition
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func chickenifyPlayer():
  am_i_sleepy = false
  textBox.dialogStartSound.stream = null
  if smackSound: smackSound.play()
  # var temp = global.has_been_baba_yaga_cursed
  # global.has_been_baba_yaga_cursed = true
  # level.player.getChickenInfected()
  # global.has_been_baba_yaga_cursed = temp
  level.player.tumbleFall(Vector2(-1 if (not mySprite.flip_h) else 1, 0))
  global.pauseGame = false
  level.player.pauseInput = false
  # can_move = false

  if (global.activeInteractor == null and not textBox.text_final == "") or (global.activeInteractor == textBox and global.pauseGame):
    textBox.hideInteractPrompt()
    if not floating_text:
      textBox.untinify()
    textBox.interact(true) # was_smacked

# @override
func getSmacked(_broom_origin = Vector3(0, 0, 0), _silently = false):
  # if not can_be_smacked:
  #   return false
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

  # well... if you threw it at me.. i'm going to ignore that..
  if not global.memory["broom"]:
    return false

  secretAniPlayer.stop()
  secretAniPlayer.clear_queue()
  if am_i_sleepy:
    secretAniPlayer.play("smackPlayerFromSleep")
    mySprite.updateBaseFrame(0, 5)
  else:
    secretAniPlayer.play("smackPlayer")
  if am_i_glitchy:
    secretAniPlayer.queue("glitchTickle")
  mySprite.flip_h = which_side_is_player_on
  global.pauseGame = true
  level.player.pauseInput = true