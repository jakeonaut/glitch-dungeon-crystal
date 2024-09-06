extends "NPC.gd"

var summonedBroom = null
var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
export var has_broom = false
onready var broomSpriteVisible = get_node("Sprite3DBroomVisible")
onready var broomSpriteAnimated = get_node("Sprite3DBroomAnimated")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

func _ready():
  set_process(true)

func _process(delta):
  processBroomRenderLogic(delta)


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