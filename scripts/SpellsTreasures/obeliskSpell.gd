extends KinematicBody

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")
onready var sparkleSprite = get_node("SparkleSprite3D")
var spawn_timer = 0
var spawn_time_limit = 5
var num_sparkles_spawned = 0
var num_sparkles_spawned_limit = 5

export var my_glitch_form = 2
export var first_ever_glitch = false

var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
var is_active = true

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var has_frozen_input = false

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

var is_touching_player = false
var is_touching_player_timer = 0
var is_touching_player_time_limit = 5
var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

func _ready():
  set_process(true)
  original_position = mySprite.global_transform.origin
  # previous_point = original_position
  # interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  if first_ever_glitch:
    if global.memory.has("roomPath") and global.memory["roomPath"] != "res://levels/000Intro.tscn":
      first_ever_glitch = false
      level.gameCamera.initial_target = level.player.get_node("CameraTarget")
      level.gameCamera.actual_target = weakref(level.gameCamera.initial_target)
    else:
      level.uiLayer.statsTitleRect.visible = false
      level.uiLayer.get_node("EquipmentRect1").visible = false
      level.uiLayer.get_node("EquipmentStatusRect1").visible = false

func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  if is_active and not shouldIBeActive():
    is_active = false
    # mySprite.visible = false
    t = 0

  # if mySprite.visible and not is_active:
  #   mySprite.global_transform.origin = previous_point.linear_interpolate(interpolation_point, t)
  #   t += (delta*2)
  #   if t >= 1:
  #     mySprite.visible = false
  #     t = 0

  # if not mySprite.visible and shouldIBeActive() and not first_ever_glitch:
  #   mySprite.visible = true
  if is_touching_player:
    is_touching_player_timer += (delta*22)
    if is_touching_player_timer >= is_touching_player_time_limit:
      is_touching_player_timer = 0
      is_touching_player = false
  else:
    mySprite.global_transform.origin = original_position
    is_active = true

  if first_ever_glitch:
    if not has_frozen_input:
      global.pauseMoveInput = true
    if getPlayer().physics_state == getPlayer().PhysicsState.COLLAPSED:
      global.pauseMoveInput = false
      has_frozen_input = true

  if num_sparkles_spawned < num_sparkles_spawned_limit:
    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      newSprite.transform.origin = Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125),
          0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      add_child(newSprite)
      spawn_timer = 0
      num_sparkles_spawned += 1
    
func shouldIBeActive():
  if getPlayer().glitch_form == my_glitch_form:
    return false
  elif global.memory["mp"] == 0:
    return true
  elif level.spellbook_forbidden or not global.memory.has("spellbookPage") or global.memory["spellbookPage"].size() == 0:
    return true
  elif global.memory["spellbookPage"].has(my_glitch_form):
    return false
  else:
    return true

func isActive():
  return self.visible

func passiveActivate(_delta):
  is_touching_player = true
  is_touching_player_timer = 0
  mySprite.global_transform.origin.x = level.player.global_transform.origin.x
  mySprite.global_transform.origin.y = level.player.global_transform.origin.y + 1
  level.player.glitchTickle(global.memory["mp"] < global.memory["max_mp"])
  if not is_active:
    if global.memory["mp"] < global.memory["max_mp"]:
      if global.memory["mp"] < global.memory["max_mp"]-1:
        collectSound.pitch_scale = 0.5
        collectSound.play()
      if global.memory["mp"] == 0:
        level.player.restoreGlitchAndMP()
      num_sparkles_spawned = 0
      global.memory["mp"] = global.memory["max_mp"]
    return

  if global.memory.has("spellbookPage"):
    collectSound.pitch_scale = 0.9
    collectSound.play()
  is_active = false

  if first_ever_glitch:
    global.pauseGame = true
    getPlayer().mySprite.get_material_override().set_shader_param("enable_palette_cycle", true)
    getPlayer().mySprite.get_material_override().set_shader_param("enable_remove_skin_tone", true)
    getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", true)
    getLevelTiles().unrandomizeAllTiles()
    musicPlayer.tryToPlay(musicPlayer.wakeupPlayer)
    var NPC = level.get_node("NPC4")
    NPC.textBoxContainer.bbText = "•oh you're green.\n•um... hold UP or X \n longer to jump higher"
    NPC.textBoxContainer.setVars()
    NPC.textBoxContainer.textBox.has_been_shown = false
  else:
    getPlayer().applyObeliskGlitch(my_glitch_form, false, true)
    level.player.glitchTickle()
    # if level.player.glitch_death_timer == 0:
    #   level.player.glitch_death_timer = 5
    # level.player.should_turn_on_glitch_screen_effects = true
    global.memory["mp"] = global.memory["max_mp"]

  num_sparkles_spawned = 0
