extends Spatial

onready var cubeContainer = get_node("CubeContainer")
onready var cubeSound = get_node("cubeSound")
onready var cubeSound2 = get_node("cubeSound2")
onready var cubeSound3 = get_node("cubeSound3")
onready var cubeSound4 = get_node("cubeSound4")
onready var aniPlayer = get_node("AnimationPlayer")

onready var meshInstance2 = get_node("CubeContainer/MeshInstance2")
onready var mySprite = get_node("Sprite3D")

onready var plusSpriteContainer = get_node("PlusSpriteContainer")
onready var plusSprite = get_node("PlusSpriteContainer/PlusSprite")
onready var plusSprite2 = get_node("PlusSpriteContainer/PlusSprite2")
onready var plusSpriteAniPlayer = get_node("PlusSpriteContainer/AnimationPlayer")

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var is_static_in_level = true
export var is_negative = false

export var MIN_STEP = -2
export var should_randomize_step = true
var MID_STEP = 5
var MAX_STEP = -12
var step = MIN_STEP

var disappearing2 = false
var disappearTimer = 0

func _ready():
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self):
    iAmAGhost()
    # addPlusSprite()
    # queue_free()
    
  set_process(true)

  var rand_init_step = rand_range(-90, -2)
  cubeContainer.rotate_y(rand_init_step)
  cubeContainer.rotate_x((rand_init_step/2))
  meshInstance2.material_override = meshInstance2.material_override.duplicate()

func _process(delta):
  delta = delta * global.time_dilation_multiplier
  aniPlayer.playback_speed = global.time_dilation_multiplier

  if visible:
    if disappearing2:
      step = MID_STEP
      translate(Vector3(0, 0.5*delta, 0))
      disappearTimer += (delta*22)
      cubeContainer.rotate_y(disappearTimer*delta)
      cubeContainer.rotate_x((disappearTimer/2)*delta)
      if "floatAway" in aniPlayer.assigned_animation and not aniPlayer.is_playing() and \
         not cubeSound.is_playing() and not cubeSound2.is_playing():
        queue_free()
    else:
      if should_randomize_step:
        step = rand_range(MIN_STEP-1, MIN_STEP+1)
      else:
        step = MIN_STEP
    cubeContainer.rotate_y(step*delta)
    cubeContainer.rotate_x((step/2)*delta)

func iAmAGhost():
  is_negative = true
  aniPlayer.play("ghostify")

func isActive(_debug=false):
  return visible and not disappearing2

func passiveActivate(_delta, _is_player, _is_local_broom = false):
  # musicPlayer.stopAll()
  if not disappearing2:
    if is_negative:
      cubeSound4.pitch_scale = rand_range(0.4, 0.7)
      cubeSound4.play()
    else:
      cubeSound.play()
      cubeSound2.pitch_scale = global.mini_cube_crystal_pitch
      cubeSound2.play()
      global.mini_cube_crystal_pitch_timer = 0
      global.mini_cube_crystal_pitch += 0.1
    
    if is_negative:
      aniPlayer.play("floatAway2")
    else:
      aniPlayer.play("floatAway")
    # if global.memory["max_mp"] == 0:
    #   level.uiLayer.get_node("GlitchStatusRect").visible = true
    #   level.uiLayer.get_node("GlitchStatusRect").rect_scale = Vector2(1.5, 1.5)
    #   level.uiLayer.get_node("GlitchStatusRect").rect_position = Vector2(300, 250)

    # global.memory["mp"] += 1
    # global.memory["max_mp"] += 1
    # global.memory["num_mini_crystal_cubes"] += 1
    if global.getThingFromAllLevelZonez("num_mini_crystal_cubes") == 0 and not is_negative:
      global.memory["tutorial_gem"] = 1
      level.uiLayer.get_node("GlitchStatusRect").visible = true
      level.uiLayer.get_node("GlitchStatusRect").rect_scale = Vector2(1.5, 1.5)
      level.uiLayer.get_node("GlitchStatusRect").rect_position = Vector2(200, 325)
    if not is_negative:
      global.incrementLevelZoneThing("num_mini_crystal_cubes", 1)


    if is_static_in_level:
      global.setStaticLevelZoneLevelVar(level, self, true)
      if not is_negative:
        addPlusSprite()

    disappearing2 = true

func addPlusSprite():
  pass
  # remove_child(plusSpriteContainer)
  # level.add_child(plusSpriteContainer)
  # plusSpriteContainer.visible = true
  # plusSpriteContainer.global_transform.origin = self.global_transform.origin
  # plusSprite.material_override = plusSprite.material_override.duplicate()
  # plusSprite2.material_override = plusSprite2.material_override.duplicate()
  # plusSpriteAniPlayer.play("byebye")

  # global.pauseGame = true
  # global.pauseMoveInput = true
  # player.global_transform.origin = self.global_transform.origin
